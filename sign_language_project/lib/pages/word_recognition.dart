import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordRecognition extends StatefulWidget {
  @override
  _WordRecognitionState createState() => _WordRecognitionState();
}

class _WordRecognitionState extends State<WordRecognition> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;
  String _latestPrediction = "";
  bool _isRecording = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(_selectedCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![cameraIndex],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      await _startRecording();
    } else {
      await _stopRecordingAndProcess();
    }
  }

  Future<void> _startRecording() async {
    try {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecordingAndProcess() async {
    try {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      
      String prediction = await _sendVideoToServer(videoFile);
      setState(() {
        _latestPrediction = prediction;
        _isProcessing = false;
      });
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() => _isProcessing = false);
    }
  }

Future<String> _sendVideoToServer(XFile videoFile) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.214.58:5000/predict_video')
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('video', videoFile.path)
    );
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['prediction'] ?? 'No prediction';
    }
    return 'Error: ${response.statusCode}';
  } catch (e) {
    return 'Error: $e';
  }
}

  void _switchCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      setState(() {
        _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
        _isCameraInitialized = false;
        _initializeCamera(_selectedCameraIndex);
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Sign Language Recognition')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Language Recognition'),
        actions: [
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isProcessing 
                      ? 'Waiting for Response...'
                      : 'Prediction: $_latestPrediction',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRecording ? Icons.stop : Icons.videocam,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        _isRecording ? 'STOP RECORDING' : 'START RECORDING',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
