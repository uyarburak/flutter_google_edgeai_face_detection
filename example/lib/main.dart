import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_detector/flutter_face_detector.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _detector = FlutterFaceDetector();

  double _confidenceValue = 0.0;
  String _inferenceTime = '0ms';
  Uint8List? _imageBytes;

  Future<void> _pickImageAndDetect() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _confidenceValue = 0;
    });

    try {
      final FaceDetectionResult result =
          await _detector.faceDetectionFromImage(bytes);

      final confidence = result.faces
          .map((face) => face.confidence)
          .reduce((a, b) => a > b ? a : b);

      setState(() {
        _confidenceValue = confidence.clamp(0.0, 1.0);
        _inferenceTime = result.inferenceTime.toString();
      });
    } catch (e) {
      debugPrint('Face detection error: $e');
    }
  }

  String get _statusText {
    if (_imageBytes == null) return '請先選擇照片';
    if (_confidenceValue <= 0.2) return '完全不像人臉呀';
    if (_confidenceValue <= 0.6) return '你確定是證件照嗎？';
    if (_confidenceValue < 0.8) return '臉部辨識不出來';
    return '可上傳';
  }

  Color get _statusColor {
    if (_confidenceValue < 0.6) return Colors.redAccent;
    if (_confidenceValue < 0.8) return Colors.orangeAccent;
    return Colors.green;
  }

  bool get _canUpload => _confidenceValue >= 0.8;

  void _onUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('模擬上傳成功 ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('KYC 臉部辨識上傳模擬'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                // 頭像顯示卡片
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (_imageBytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _imageBytes!,
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                            ),
                            child: const Icon(Icons.person_outline,
                                size: 100, color: Colors.grey),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          'Confidence：${(_confidenceValue * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text('Inference Time：$_inferenceTime',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _statusText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 選擇照片按鈕
                ElevatedButton.icon(
                  onPressed: _pickImageAndDetect,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('選擇照片進行辨識'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                    backgroundColor: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // 上傳按鈕
                ElevatedButton.icon(
                  onPressed: _canUpload ? _onUpload : null,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(_canUpload ? '上傳' : _statusText),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                    backgroundColor:
                        _canUpload ? Colors.green : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
