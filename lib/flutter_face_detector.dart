import 'dart:typed_data';

import 'flutter_face_detector_platform_interface.dart';
import 'models/face_detection_result.dart';

export 'models/face_detection_result.dart';

class FlutterFaceDetector {
  Future<String?> getPlatformVersion() {
    return FlutterFaceDetectorPlatform.instance.getPlatformVersion();
  }

  Future<FaceDetectionResult> faceDetectionFromImage(Uint8List imageData) {
    return FlutterFaceDetectorPlatform.instance.faceDetectionFromImage(imageData);
  }
}
