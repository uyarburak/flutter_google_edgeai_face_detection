/// Model class representing a single detected face
class FaceDetection {
  /// Confidence score of the detection (0.0 to 1.0)
  final double confidence;

  /// Bounding box coordinates
  final BoundingBox boundingBox;

  FaceDetection({
    required this.confidence,
    required this.boundingBox,
  });

  factory FaceDetection.fromMap(Map<String, dynamic> map) {
    return FaceDetection(
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      boundingBox: BoundingBox.fromMap(
        (map['boundingBox'] as Map<dynamic, dynamic>?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'confidence': confidence,
      'boundingBox': boundingBox.toMap(),
    };
  }

  @override
  String toString() {
    return 'FaceDetection(confidence: ${(confidence * 100).toStringAsFixed(2)}%, boundingBox: $boundingBox)';
  }
}

/// Bounding box coordinates for a detected face
class BoundingBox {
  /// X coordinate of the top-left corner (normalized 0.0 to 1.0)
  final double x;

  /// Y coordinate of the top-left corner (normalized 0.0 to 1.0)
  final double y;

  /// Width of the bounding box (normalized 0.0 to 1.0)
  final double width;

  /// Height of the bounding box (normalized 0.0 to 1.0)
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromMap(Map<String, dynamic> map) {
    return BoundingBox(
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      width: (map['width'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  @override
  String toString() {
    return 'BoundingBox(x: ${x.toStringAsFixed(3)}, y: ${y.toStringAsFixed(3)}, width: ${width.toStringAsFixed(3)}, height: ${height.toStringAsFixed(3)})';
  }
}

/// Complete face detection result containing all detected faces and metadata
class FaceDetectionResult {
  /// List of all detected faces
  final List<FaceDetection> faces;

  /// Inference time in milliseconds
  final double inferenceTime;

  /// Total number of faces detected
  int get faceCount => faces.length;

  FaceDetectionResult({
    required this.faces,
    required this.inferenceTime,
  });

  factory FaceDetectionResult.fromMap(Map<String, dynamic> map) {
    final facesList = (map['faces'] as List<dynamic>?)
            ?.map((face) {
              if (face is Map) {
                return FaceDetection.fromMap(
                  face.map(
                    (key, value) => MapEntry(key.toString(), value),
                  ),
                );
              }
              return null;
            })
            .whereType<FaceDetection>()
            .toList() ??
        [];

    return FaceDetectionResult(
      faces: facesList,
      inferenceTime: (map['inferenceTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'faces': faces.map((face) => face.toMap()).toList(),
      'inferenceTime': inferenceTime,
    };
  }

  @override
  String toString() {
    return 'FaceDetectionResult(faceCount: $faceCount, inferenceTime: ${inferenceTime.toStringAsFixed(2)}ms)';
  }
}
