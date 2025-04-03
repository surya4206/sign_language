from flask import Flask, request, jsonify
import cv2
import mediapipe as mp
import numpy as np
from tensorflow.keras.models import load_model
from PIL import Image
import io
import gc
import torch
import torch.nn as nn
import os
import tempfile
from collections import deque
from typing import Callable, List
from flask import Flask, request, jsonify


model = load_model('mediapipe_lstm_model.h5')

app = Flask(__name__)

class LSTMNet(nn.Module):
    def __init__(self, input_size=126, hidden_size=256, num_layers=2, num_classes=33):
        super(LSTMNet, self).__init__()

        self.lstm = nn.LSTM(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True,
            dropout=0.2
        )

        self.fc1 = nn.Linear(hidden_size, 128)
        self.relu = nn.ReLU()
        self.dropout = nn.Dropout(0.3)
        self.fc2 = nn.Linear(128, num_classes)

    def forward(self, x):
        # x shape: (batch, seq_len, input_size)
        lstm_out, _ = self.lstm(x)

        # Use last sequence output
        out = lstm_out[:, -1, :]

        out = self.fc1(out)
        out = self.relu(out)
        out = self.dropout(out)
        out = self.fc2(out)

        return out

class GRUNet(nn.Module):
    def __init__(self, input_size=126, hidden_size=256, num_layers=2, num_classes=33):
        super(GRUNet, self).__init__()

        self.gru = nn.GRU(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True,
            dropout=0.3,
            bidirectional=True  # Use bidirectional GRU
        )

        # Double hidden size due to bidirectional GRU
        self.fc1 = nn.Linear(hidden_size * 2, 128)
        self.relu = nn.ReLU()
        self.dropout = nn.Dropout(0.3)
        self.batch_norm = nn.BatchNorm1d(128)
        self.fc2 = nn.Linear(128, num_classes)

    def forward(self, x):
        # x shape: (batch, seq_len=30, input_size=126)

        # GRU output shape: (batch, seq_len, hidden_size * 2)
        gru_out, _ = self.gru(x)

        # Use last sequence output
        out = gru_out[:, -1, :]

        # Fully connected layers
        out = self.fc1(out)
        out = self.batch_norm(out)
        out = self.relu(out)
        out = self.dropout(out)
        out = self.fc2(out)

        return out

class RNNGestureNet(nn.Module):
    def __init__(self, input_size=126, hidden_size=256, num_layers=2, num_classes=33, dropout=0.3):
        """
        RNN network for gesture recognition.

        Args:
            input_size (int): Number of input features per frame (default: 126 for flattened landmarks)
            hidden_size (int): Size of RNN hidden layers
            num_layers (int): Number of RNN layers
            num_classes (int): Number of output classes
            dropout (float): Dropout rate
        """
        super(RNNGestureNet, self).__init__()

        self.rnn = nn.RNN(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True,
            dropout=0.3,
            bidirectional=True  # Use bidirectional RNN
        )

        # Double hidden size due to bidirectional RNN
        self.fc1 = nn.Linear(hidden_size * 2, 128)
        self.relu = nn.ReLU()
        self.dropout = nn.Dropout(0.3)
        self.batch_norm = nn.BatchNorm1d(128)
        self.fc2 = nn.Linear(128, num_classes)

    def forward(self, x):
        # x shape: (batch, seq_len=30, input_size=126)

        # RNN output shape: (batch, seq_len, hidden_size * 2)
        rnn_out, _ = self.rnn(x)

        # Use last sequence output
        out = rnn_out[:, -1, :]

        # Fully connected layers
        out = self.fc1(out)
        out = self.batch_norm(out)
        out = self.relu(out)
        out = self.dropout(out)
        out = self.fc2(out)

        return out

class EnsembleNet(nn.Module):
    def __init__(self, model1, model2, model3):
        super(EnsembleNet, self).__init__()
        self.model1 = model1
        self.model2 = model2
        self.model3 = model3

    def forward(self, x):
        out1 = self.model1(x)
        out2 = self.model2(x)
        out3 = self.model3(x)
        return (out1 + out2 + out3) / 3

class GesturePredictor:
    def __init__(self, model_path, device='cuda' if torch.cuda.is_available() else 'cpu'):
        self.device = device
        
        # Load the saved model
        checkpoint = torch.load(model_path, map_location=device)
        self.class_mapping = checkpoint['class_mapping']
        self.idx_to_class = {v: k for k, v in self.class_mapping.items()}
        
        # Initialize model (use the same model architecture as training)
        num_classes = len(self.class_mapping)
        self.model = EnsembleNet(
            LSTMNet(num_classes=num_classes).to(device), 
            GRUNet(num_classes=num_classes).to(device), 
            RNNGestureNet(num_classes=num_classes).to(device)
        ).to(device)
        self.model.load_state_dict(checkpoint['model_state_dict'])
        self.model.eval()
        
        # Initialize MediaPipe
        self.mp_hands = mp.solutions.hands
        self.mp_pose = mp.solutions.pose
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=2,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        
        print(f"Loaded model with classes: {self.class_mapping}")

    def process_video(self, video_path):
        """Process a video file and return the predicted gesture."""
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            return {"error": "Could not open video file"}
        
        frames = []
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            frames.append(frame)
        
        cap.release()
        
        if len(frames) == 0:
            return {"error": "No frames extracted from video"}
        
        return self.process_frames(frames)
    
    def process_frames(self, frames):
        """Process a list of frames and return the predicted gesture."""
        frame_interval = max(1, len(frames) // 30)
        landmarks_sequence = np.zeros((30, 2, 21, 3))
        frame_count = 0
        processed_frames = 0

        while processed_frames < 30 and frame_count < len(frames):
            # Process only every nth frame
            if frame_count % frame_interval != 0:
                frame_count += 1
                continue

            # Initialize arrays to hold the flattened landmarks for this frame
            frame_rgb = cv2.cvtColor(frames[frame_count], cv2.COLOR_BGR2RGB)

            # Process frame with MediaPipe
            results = self.hands.process(frame_rgb)

            if results.multi_hand_landmarks:
                for hand_idx, hand_landmarks in enumerate(results.multi_hand_landmarks[:2]):  # Process up to 2 hands
                    for landmark_idx, landmark in enumerate(hand_landmarks.landmark):
                        landmarks_sequence[processed_frames, hand_idx, landmark_idx] = [
                            landmark.x, landmark.y, landmark.z
                        ]
            
            del frame_rgb
            del results
            processed_frames += 1
            frame_count += 1

        if processed_frames < 30:
            print(f"Warning: Only processed {processed_frames} frames out of 30 required")
            # Repeat the last frame to fill the sequence if needed
            for i in range(processed_frames, 30):
                landmarks_sequence[i] = landmarks_sequence[processed_frames-1]
        
        # Reshape for model input (batch_size=1, seq_len=30, features)
        model_input = torch.FloatTensor(landmarks_sequence.reshape(1, 30, 126)).to(self.device)
        
        # Get prediction
        with torch.no_grad():
            outputs = self.model(model_input)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
            pred_idx = torch.argmax(outputs, dim=1).item()
            confidence = probabilities[0, pred_idx].item()
        
        predicted_class = self.idx_to_class[pred_idx]
        
        # Get top 3 predictions
        topk_values, topk_indices = torch.topk(probabilities[0], k=min(3, len(self.idx_to_class)))
        top_predictions = [
            {
                "class": self.idx_to_class[idx.item()],
                "confidence": conf.item()
            }
            for idx, conf in zip(topk_indices, topk_values)
        ]
        
        return {
            "prediction": predicted_class,
            "confidence": confidence,
            "top_predictions": top_predictions
        }

# Initialize the predictor globally (will be loaded when the app starts)
MODEL_PATH = os.environ.get('MODEL_PATH', 'best_model.pth')
predictor = None

@app.route('/predict', methods=['POST'])
def predict():
    # Receive image data
    image_data = request.data
    mp_hands = mp.solutions.hands
    hands = mp_hands.Hands(static_image_mode=False, max_num_hands=2, min_detection_confidence=0.5, min_tracking_confidence=0.5)
    nparr = np.frombuffer(image_data, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    #cv2.imwrite('new_image.jpg', image)
    label = {0:'ಚ', 1:'ಛ', 2:' ಡ', 3:'ಢ', 4:'ಧ', 5:'ದ', 6:'ಗ', 7:'ಘ', 8:'ಜ', 9:'ಝ', 10:'ಕ', 11:'ಖ', 12:'ಙ', 13:'ಞ', 14:'ಣ', 15:'ನ', 16:'ಟ', 17:'ತ', 18:' ಠ', 19:'ಥ'}

    
    #Process the image and find hands
    results = hands.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
    if results.multi_hand_landmarks:
        keypoints = []
        for hand_landmarks in results.multi_hand_landmarks:
            # Extract x and y coordinates of the landmarks
            for landmark in hand_landmarks.landmark:
                keypoints.extend([landmark.x, landmark.y])
        
        # Check the number of keypoints extracted
        if len(keypoints) == 42:
            # Only one hand detected, pad the remaining 42 keypoints with zeros
            pass
        else:
            print("Unexpected number of keypoints detected.")
        
        # Ensure keypoints are of the correct shape [1, 1, 84]
        keypoints = np.array(keypoints).reshape(1, 1, 42)
        
        # Predict the label
        prediction = model.predict(keypoints)
        predicted_label = np.argmax(prediction, axis=1)
        print(predicted_label)
        gc.collect();
        return jsonify({'prediction': label[predicted_label[0]]})
    return jsonify({'prediction': 'None'})

# Changed from @app.before_first_request to avoid conflict
def initialize_model():
    global predictor
    try:
        predictor = GesturePredictor(MODEL_PATH)
        print(f"Model loaded successfully from {MODEL_PATH}")
    except Exception as e:
        print(f"Error loading model: {e}")
        return False
    return True
    
@app.route('/predict_video', methods=['POST'])
def predict_video():
    global predictor
    
    # Initialize model if not already done
    if predictor is None:
        success = initialize_model()
        if not success:
            return jsonify({"error": "Failed to initialize model"}), 500

    if 'video' not in request.files:
        return jsonify({"error": "No video file provided"}), 400
    
    video_file = request.files['video']
    
    if video_file.filename == '':
        return jsonify({"error": "No selected video file"}), 400
    
    # Save the uploaded video to a temporary file
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.mp4')
    video_path = temp_file.name
    temp_file.close()
    
    try:
        video_file.save(video_path)
        
        # Make sure the predictor is initialized
        if predictor is None:
            load_model()
            if predictor is None:
                return jsonify({"error": "Model not initialized"}), 500
        
        # Process the video
        result = predictor.process_video(video_path)
        
        # Cleanup
        os.unlink(video_path)
        
        return jsonify(result)
    
    except Exception as e:
        # Cleanup in case of error
        if os.path.exists(video_path):
            os.unlink(video_path)
        
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
