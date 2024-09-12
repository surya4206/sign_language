import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:isolate';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignLanguageRecognitionPage extends StatefulWidget {
  @override
  _SignLanguageRecognitionPageState createState() => _SignLanguageRecognitionPageState();
}

class _SignLanguageRecognitionPageState extends State<SignLanguageRecognitionPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;
  
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  String _latestPrediction = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera(_selectedCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(_cameras![cameraIndex], ResolutionPreset.medium);
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
        _startImageStream();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startImageStream() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_processFrame, _receivePort!.sendPort);
    _receivePort!.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else {
        setState(() {
          _latestPrediction = message;
        });
      }
    });

    await _cameraController!.startImageStream((CameraImage image) {
      if (_sendPort != null) {
        _sendPort!.send(image);
      }
    });
  }

  static void _processFrame(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is CameraImage) {
        String prediction = await _sendFrameToServer(message);
        sendPort.send(prediction);
      }
    });
  }

  static Future<String> _sendFrameToServer(CameraImage image) async {
    try {
      // Convert image to byte array
      List<int> imageBytes = [];
      for (Plane plane in image.planes) {
        imageBytes.addAll(plane.bytes);
      }

      // Send POST request to Flask server
      var response = await http.post(
        Uri.parse('http://192.168.0.106:5000/predict'),  // Use 10.0.2.2 for Android emulator, localhost for iOS
        headers: {'Content-Type': 'application/octet-stream'},
        body: imageBytes,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['prediction'];
      } else {
        return 'Error: ${response.statusCode}';
      }
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
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
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
          CameraPreview(_cameraController!),
          StreamBuilder<void>(
            stream: Stream.periodic(Duration(milliseconds: 2000)),
            builder: (context, snapshot) {
              return Text(
                'Prediction: $_latestPrediction',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}