import Flutter
import UIKit
//import os

public class FlutterFaceDetectorPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "flutter_face_detector", binaryMessenger: registrar.messenger())
    let instance = FlutterFaceDetectorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result(InferenceConfigurationManager.sharedInstance.modelPath ?? "")

    case "faceDetectionFromImage":
      // 取得 imageData
      guard let args = call.arguments as? [String: Any],
        let imageData = args["image"] as? FlutterStandardTypedData
      else {
        result(FlutterError(code: "NO_IMAGE", message: "No image data found", details: nil))
        return
      }

      guard let uiImage = UIImage(data: imageData.data) else {
        result(FlutterError(code: "INVALID_IMAGE", message: "Unable to decode image", details: nil))
        return
      }

      // 初始化偵測服務
      guard
        let service = FaceDetectorService.stillImageDetectorService(
          modelPath: InferenceConfigurationManager.sharedInstance.modelPath,
          minDetectionConfidence: InferenceConfigurationManager.sharedInstance
            .minDetectionConfidence,
          minSuppressionThreshold: InferenceConfigurationManager.sharedInstance
            .minSuppressionThreshold,
          delegate: InferenceConfigurationManager.sharedInstance.delegate
        )
      else {
        result(
          FlutterError(
            code: "INIT_FAILED", message: "Failed to initialize FaceDetectorService", details: nil))
        return
      }

      // 執行臉部偵測
      guard let resultBundle = service.detect(image: uiImage) else {
        result(
          FlutterError(code: "DETECTION_FAILED", message: "No face detection result", details: nil))
        return
      }

      // ✅ Extract all detected faces with their bounding boxes and confidence scores
      var facesList: [[String: Any]] = []
      
      if let firstResult = resultBundle.faceDetectorResults.first,
         let faceDetectorResult = firstResult {
        let detections = faceDetectorResult.detections
        let imageWidth = uiImage.size.width
        let imageHeight = uiImage.size.height
        
        for detection in detections {
          guard let score = detection.categories.first?.score else { continue }
          
          let boundingBox = detection.boundingBox
          
          var faceMap: [String: Any] = [:]
          faceMap["confidence"] = Double(score)
          
          var boundingBoxMap: [String: Double] = [:]
          boundingBoxMap["x"] = Double(boundingBox.origin.x) / Double(imageWidth)
          boundingBoxMap["y"] = Double(boundingBox.origin.y) / Double(imageHeight)
          boundingBoxMap["width"] = Double(boundingBox.width) / Double(imageWidth)
          boundingBoxMap["height"] = Double(boundingBox.height) / Double(imageHeight)
          
          faceMap["boundingBox"] = boundingBoxMap
          facesList.append(faceMap)
        }
      }

      // ✅ Return all faces with inference time
      result([
        "faces": facesList,
        "inferenceTime": resultBundle.inferenceTime,
      ])

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
