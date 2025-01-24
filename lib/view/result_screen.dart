import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/object_detection_controller.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final String metadata;

  ResultScreen({required this.imagePath, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final ObjectDetectionController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Captured Image'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (controller.capturedImages.isNotEmpty) {
                controller.capturedImages.removeLast();
                Get.back();
              }
            },
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;

          return Column(
            children: [
              Container(
                height: screenHeight * 0.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black12),
                ),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  metadata,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (controller.capturedImages.isEmpty) {
                    return Center(
                      child: Text(
                        'No images captured yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.capturedImages.length,
                    itemBuilder: (context, index) {
                      final capturedImage = controller.capturedImages[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(capturedImage.path),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            capturedImage.metadata,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Captured at: ${capturedImage.capturedAt}',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}