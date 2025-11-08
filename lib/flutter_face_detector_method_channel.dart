import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_face_detector_platform_interface.dart';
import 'models/face_detection_result.dart';

/// An implementation of [FlutterFaceDetectorPlatform] that uses method channels.
class MethodChannelFlutterFaceDetector extends FlutterFaceDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_face_detector');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<FaceDetectionResult> faceDetectionFromImage(Uint8List imageData) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'faceDetectionFromImage',
      <dynamic, dynamic>{'image': imageData},
    );

    if (result is Map) {
      return FaceDetectionResult.fromMap(Map<String, dynamic>.from(result));
    } else {
      throw PlatformException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid response from native',
        details: result,
      );
    }
  }
}
