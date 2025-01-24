import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/object_detection_controller.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ObjectDetectionController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: controller.objects.length,
                itemBuilder: (context, index) {
                  final object = controller.objects[index];
                  final objectIcon = controller.objectsIcons[index];
                  return Obx(() {
                    final isSelected = controller.selectedObject.value == object;

                    return GestureDetector(
                      onTap: () {
                        controller.updateSelectedObject(object);
                        print("object:::$object");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: isSelected ? 3.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              objectIcon,
                              size: 48.0,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              object,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Get.to(() => CameraDetectionScreen()),
              child: Text('Get Started'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}