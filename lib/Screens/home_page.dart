import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_pick/Repository/image_controller.dart';
import 'package:quick_pick/Screens/ai_generation.dart';


class HomePage extends StatelessWidget {
  final ImageController controller = Get.put(ImageController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Image Picker'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(controller.selectedImages.length, (
                  index,
                ) {
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          image: DecorationImage(
                            image: FileImage(controller.selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            controller.selectedImages.removeAt(index);
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),

              SizedBox(height: Get.height * 0.4),
              if (controller.selectedImages.length < 5)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: controller.pickImage,
                    icon: const Icon(Icons.add),
                    label: Text(
                      controller.selectedImages.isEmpty
                          ? 'Add Image'
                          : 'Add More',
                    ),
                  ),
                ),
              SizedBox(height: 10),
              Center(child: Text("Or")),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => ImageGenExample());
                  },
                  child: Text("Generate Image with AI"),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
