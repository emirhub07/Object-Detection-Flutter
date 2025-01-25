import 'package:flutter/material.dart';
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
    super.initState();
    controller.initializeCamera();
    controller.initializeImageLabeler();
    controller.initializeObjectDetector();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    controller.cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(
            "Selected Object: ${controller.selectedObject}",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          );
        }),
      ),
      body: Stack(
        children: [
          // Camera Preview with Bounding Boxes
          Obx(() {
            if (!controller.cameraController.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                // Camera preview
                CameraPreview(controller.cameraController),
                // Bounding boxes
                CustomPaint(
                  painter: BoundingBoxPainter(
                    controller.boundingBoxes.value,
                    controller.labels.value,
                    controller.labelPositions.value,
                  ),
                ),
              ],
            );
          }),

          // Information Section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(() => Text(
                    "Detected object: ${controller.labels.join(', ')}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  )),
                  const SizedBox(height: 10),
                  Obx(() => Text(
                    "Confidence: ${controller.objectConfidences}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
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
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(color: Colors.white, fontSize: 12);

    for (int i = 0; i < boundingBoxes.length; i++) {
      final box = boundingBoxes[i];
      final label = labels[i];
      final labelPosition = labelPositions[i];

      canvas.drawRect(box, paint);

      // Draw label background
      canvas.drawRect(
        Rect.fromLTWH(labelPosition.dx, labelPosition.dy, 100, 20),
        labelPaint,
      );

      // Draw label text
      final textSpan = TextSpan(text: label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(labelPosition.dx + 5, labelPosition.dy + 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
