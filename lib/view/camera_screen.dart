import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/object_detection_controller.dart';
import 'package:camera/camera.dart';

class CameraDetectionScreen extends StatefulWidget {
  @override
  State<CameraDetectionScreen> createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> {
  final ObjectDetectionController controller =
      Get.put(ObjectDetectionController());

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    controller.initializeCamera();
    controller.initializeImageLabeler();
    controller.initializeObjectDetector();
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  // DeviceOrientation.portraitDown,
]);
  }

  @override
  void dispose() {
// TODO: implement dispose
    super.dispose();
    controller.cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Selected Object: ${controller.selectedObject}",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              if (!controller.cameraController.value.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    CameraPreview(controller.cameraController),
                    CustomPaint(
                      painter: BoundingBoxPainter(
                          controller.boundingBoxes.value,
                          controller.labels.value,
                          controller.labelPositions.value),
                    ),
                  ],
                ),
              );
            }),
            Container(
              child: Column(
                children: [
                  Obx(() => Text(
                    "Detected object: ${controller.labels}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  )),
                  SizedBox(
                    height: 15,
                  ),
                  Obx(() => Text(
                    "Confidence: ${controller.objectConfidences} ",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  )),
                  SizedBox(
                    height: 15,
                  ),
                  Obx(() => Text(
                    "${controller.objectConfidences}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ))
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Rect> boundingBoxes;
  final List<String> labels;
  final List<Offset> labelPositions;

  BoundingBoxPainter(this.boundingBoxes, this.labels, this.labelPositions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final labelPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(color: Colors.black, fontSize: 16);

    for (int i = 0; i < boundingBoxes.length; i++) {
      final box = boundingBoxes[i];
      final label = labels[i];
      final labelPosition = labelPositions[i];

      canvas.drawRect(box, paint);

      canvas.drawRect(
        Rect.fromLTWH(labelPosition.dx, labelPosition.dy, 100, 30),
        labelPaint,
      );

      final textSpan = TextSpan(text: label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, labelPosition);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
