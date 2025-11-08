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
  Future<FaceDetectionResult> faceDetectionFromImage(
      Uint8List imageData) async {
    final result = await methodChannel.invokeMethod<dynamic>(
      'faceDetectionFromImage',
      <dynamic, dynamic>{'image': imageData},
    );

    if (result is Map) {
      return FaceDetectionResult.fromMap(_convertMap(result));
    } else {
      throw PlatformException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid response from native',
        details: result,
      );
    }
  }

  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _convertMap(value));
      } else if (value is List) {
        return MapEntry(key.toString(), _convertList(value));
      } else {
        return MapEntry(key.toString(), value);
      }
    });
  }

  List<dynamic> _convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertMap(item);
      } else if (item is List) {
        return _convertList(item);
      } else {
        return item;
      }
    }).toList();
  }
}
