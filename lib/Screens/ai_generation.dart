import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_pick/Repository/ai_controller.dart';


class ImageGenExample extends StatelessWidget {
  const ImageGenExample({super.key});

  @override
  Widget build(BuildContext context) {
    final AiController controller = Get.put(AiController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Image Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
              children: [
                TextField(
                  controller: controller.promptController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your image prompt (e.g., "a futuristic city at sunset")',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: controller.generateImage,
                        child: const Text('Generate Image'),
                      ),
                const SizedBox(height: 20),
                Text(controller.statusMessage.value),
                const SizedBox(height: 20),
                Expanded(
                  child: controller.generatedImageBytes.value != null
                      ? Image.memory(
                          controller.generatedImageBytes.value!,
                          fit: BoxFit.contain,
                        )
                      : const Center(
                          child: Text('Image will appear here.'),
                        ),
                ),
              ],
            )),
      ),
    );
  }
}
