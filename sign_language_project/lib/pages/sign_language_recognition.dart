import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:isolate';

class SignLanguageRecognitionPage extends StatefulWidget {
  @override
  _SignLanguageRecognitionPageState createState() => _SignLanguageRecognitionPageState();
}

class _SignLanguageRecognitionPageState extends State<SignLanguageRecognitionPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isModelLoaded = false;
  Interpreter? _interpreter;
  int _selectedCameraIndex = 0;
  
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  String _latestPrediction = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera(_selectedCameraIndex);
    _loadModel();
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(_cameras![cameraIndex], ResolutionPreset.high);
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

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/Sign-Language-Recognition.tflite');
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print('Error loading model: $e');
      setState(() {
        _isModelLoaded = false;
      });
    }
  }

  void _startImageStream() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_predictFrame, _receivePort!.sendPort);
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

  static void _predictFrame(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is CameraImage) {
        // Implement your sign language recognition logic here
        // This is a placeholder prediction
        String prediction = "Predicted Sign";
        sendPort.send(prediction);
      }
    });
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

  String $_prediction() {
    return _latestPrediction;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
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

    if (!_isModelLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text('Sign Language Recognition')),
        body: Center(child: Text('Loading model...')),
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
            stream: Stream.periodic(Duration(milliseconds: 100)),
            builder: (context, snapshot) {
              return Text(
                'Prediction: ${$_prediction()}',
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