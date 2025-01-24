import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

import '../view/result_screen.dart';

class ObjectDetectionController extends GetxController {
  late CameraController cameraController;
  late ObjectDetector objectDetector;
  late ImageLabeler imageLabeler;
  var objectConfidences = "".obs;

  RxBool isProcessing = false.obs;
  RxList<Rect> boundingBoxes = <Rect>[].obs;
  RxList<String> labels = <String>[].obs;
  RxList<Offset> labelPositions = <Offset>[].obs;
  var selectedObject = ''.obs;
  var detectedObjectName = ''.obs;
  var clearFrameMessage = "".obs;
  var isLowLight = false.obs;

  RxBool imageCaptured = false.obs;
  RxBool isCameraInitialized = false.obs;
  RxList<CapturedImage> capturedImages = <CapturedImage>[].obs;

  final objectsIcons = [
    Icons.laptop,
    Icons.shield_moon_outlined,
    Icons.mouse,
    Icons.eco_outlined,
  ];

  final objects = ['Glasses', 'Helmet', 'Mobile phone', 'Flower'];

  @override
  void onInit() {
    super.onInit();
  }

  void updateSelectedObject(String object) {
    selectedObject.value = object;
    imageCaptured.value = false;
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras available.');
        return;
      }

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController.initialize();
      await cameraController.lockCaptureOrientation();

      isCameraInitialized.value = true;
      cameraController.startImageStream(processCameraImage);
    } catch (e) {
      print('Camera initialization error: $e');
      isCameraInitialized.value = false;
      Get.snackbar('Error', 'Failed to initialize camera: $e');
    }
  }

  void initializeObjectDetector() {
    final options = ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: true,
      mode: DetectionMode.stream,
    );
    objectDetector = ObjectDetector(options: options);
  }

  void initializeImageLabeler() {
    final options = ImageLabelerOptions(confidenceThreshold: 0.6);
    imageLabeler = ImageLabeler(options: options);
  }

  Future<void> processCameraImage(CameraImage image) async {
    if (imageCaptured.value || isProcessing.value) return;
    isProcessing.value = true;

    try {
      Uint8List yChannel = image.planes[0].bytes;
      double avgBrightness = yChannel.reduce((a, b) => a + b) / yChannel.length;

      if (avgBrightness < 50) {
        if (!isLowLight.value) {
          isLowLight.value = true;
          Fluttertoast.showToast(
            msg: "Please use the camera in a well-lit condition",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
      } else {
        isLowLight.value = false;
      }

      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final InputImageMetadata metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);

      final List<DetectedObject> objects = await objectDetector.processImage(inputImage);
      final List<ImageLabel> imageLabels = await imageLabeler.processImage(inputImage);

      List<String> detectedLabels = [];
      List<double> confidences = [];
      for (var label in imageLabels) {
        detectedLabels.add(label.label);
        confidences.add(label.confidence);

        if (label.confidence < 0.8) {
          clearFrameMessage.value = 'Keep object in camera frame: ${label.label}';
        }

        if (label.label == selectedObject.value && label.confidence > 0.8) {
          await captureImage();
          break;
        }
      }

      objectConfidences.value = confidences.toString();
      boundingBoxes.value = objects.map((obj) => obj.boundingBox).toList();
      labels.value = detectedLabels;
      labelPositions.value = List.generate(
        imageLabels.length,
            (index) => Offset(50.0, 50.0 * (index + 1)),
      );

    } catch (e) {
      print('Error processing image: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> captureImage() async {
    try {
      await cameraController.stopImageStream();
      final XFile imageFile = await cameraController.takePicture();
      String metadata = 'Captured ${selectedObject.value} at ${DateTime.now()}';
      final capturedImage = CapturedImage(
          path: imageFile.path,
          metadata: metadata,
          capturedAt: DateTime.now()
      );
      capturedImages.add(capturedImage);
      imageCaptured.value = true;
      Get.to(() => ResultScreen(imagePath: imageFile.path, metadata: metadata));
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    objectDetector.close();
    imageLabeler.close();
    super.onClose();
  }
}

class CapturedImage {
  final String path;
  final String metadata;
  final DateTime capturedAt;

  CapturedImage({
    required this.path,
    required this.metadata,
    required this.capturedAt
  });
}
