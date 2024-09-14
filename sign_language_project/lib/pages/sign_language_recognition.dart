import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:isolate';
import 'dart:convert';
import 'package:image/image.dart' as img;
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
        _cameraController = CameraController(_cameras![cameraIndex], ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.bgra8888);
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
           
      // Step 2: Encode the RGB image data (e.g., to PNG)
      List<int>? pngBytes = _convertYUVtoRGB(image);
      if (pngBytes == null) {
        return 'Error: Failed to convert image';
      } 
      // Send POST request to Flask server
      var response = await http.post(
        Uri.parse('http://192.168.0.106:5000/predict'),  // Use 10.0.2.2 for Android emulator, localhost for iOS
        headers: {'Content-Type': 'application/octet-stream'},
        body: pngBytes,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        print(data['prediction']);
        return data['prediction'];
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  static List<int>? _convertYUVtoRGB(CameraImage image) {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    var rgb = img.Image(height:height, width:width);

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        const shift = (0xFF << 24);
        if (rgb.isBoundsSafe(height-y, x)){ 
              rgb.setPixelRgba(height-y, x, r , g ,b ,shift); 
        } 
          }
        }

        img.PngEncoder pngEncoder = new img.PngEncoder(level: 0);
        List<int> png = pngEncoder.encode(rgb);
        return png;  
      } catch (e) {
        print(">>>>>>>>>>>> ERROR:" + e.toString());
      }
      return null;

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