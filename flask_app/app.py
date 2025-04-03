from flask import Flask, request, jsonify
import cv2
import mediapipe as mp
import numpy as np
from tensorflow.keras.models import load_model
from PIL import Image
import io
import gc

model = load_model('mediapipe_lstm_model.h5')

app = Flask(__name__)

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
