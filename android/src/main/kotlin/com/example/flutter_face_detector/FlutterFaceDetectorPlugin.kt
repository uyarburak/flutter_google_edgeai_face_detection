package com.example.flutter_face_detector

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.facedetector.FaceDetector
import com.google.mediapipe.tasks.vision.facedetector.FaceDetectorResult
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage


class FlutterFaceDetectorPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_face_detector")
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val method = call.method

        if (method == "getPlatformVersion") {
            result.success("Android " + android.os.Build.VERSION.RELEASE)
            return
        }

        if (method == "faceDetectionFromImage") {
            val args = call.arguments
            if (args !is Map<*, *>) {
                result.error("ARG_ERROR", "Invalid arguments", null)
                return
            }

            val imageData = args["image"]
            if (imageData !is ByteArray) {
                result.error("NO_IMAGE", "No image data found", null)
                return
            }

            val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
            if (bitmap == null) {
                result.error("INVALID_IMAGE", "Unable to decode image", null)
                return
            }

            val startTime = System.currentTimeMillis()
            val faceDetectorResult = detectFaces(bitmap)
            val inferenceTime = System.currentTimeMillis() - startTime

            if (faceDetectorResult == null) {
                result.error("DETECTION_FAILED", "Face detection failed", null)
                return
            }

            // ✅ Extract all detected faces with their bounding boxes and confidence scores
            val facesList = mutableListOf<Map<String, Any>>()
            
            for (detection in faceDetectorResult.detections()) {
                val score = detection.categories().firstOrNull()?.score() ?: 0.0f
                val boundingBox = detection.boundingBox()
                
                val faceMap = HashMap<String, Any>()
                faceMap["confidence"] = score.toDouble()
                
                val boundingBoxMap = HashMap<String, Double>()
                boundingBoxMap["x"] = boundingBox.left().toDouble() / bitmap.width
                boundingBoxMap["y"] = boundingBox.top().toDouble() / bitmap.height
                boundingBoxMap["width"] = boundingBox.width().toDouble() / bitmap.width
                boundingBoxMap["height"] = boundingBox.height().toDouble() / bitmap.height
                
                faceMap["boundingBox"] = boundingBoxMap
                facesList.add(faceMap)
            }

            val response = HashMap<String, Any>()
            response["faces"] = facesList
            response["inferenceTime"] = inferenceTime.toDouble()

            result.success(response)
            return
        }

        result.notImplemented()
    }

    // ⭐ Mediapipe Tasks 臉部偵測
    private fun detectFaces(bitmap: Bitmap): FaceDetectorResult? {
        return try {
            // ✅ 1. 載入 blaze_face_short_range.tflite
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("blaze_face_short_range.tflite")
                .build()

            // ✅ 2. 建立 FaceDetector options
            val options = FaceDetector.FaceDetectorOptions.builder()
                .setBaseOptions(baseOptions)
                .setMinDetectionConfidence(0.5f)
                .setRunningMode(RunningMode.IMAGE)
                .build()

            // ✅ 3. 建立 FaceDetector 實例
            val detector = FaceDetector.createFromOptions(applicationContext, options)


            // ✅ 4. 將 bitmap 轉為 MPImage
            val mpImage = BitmapImageBuilder(bitmap).build()

            // ✅ 5. 執行推論
            val result = detector.detect(mpImage)

            // ✅ 6. 關閉資源
            detector.close()

            // 回傳結果
            result
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
