import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AiController extends GetxController {
  final TextEditingController promptController = TextEditingController();
  final RxBool isLoading = false.obs;
  final Rx<Uint8List?> generatedImageBytes = Rx<Uint8List?>(null);
  final RxString statusMessage = "Enter a prompt and generate an image!".obs;

  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<void> generateImage() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      statusMessage.value = "Please enter a prompt.";
      return;
    }

    isLoading.value = true;
    statusMessage.value = "Generating image...";
    generatedImageBytes.value = null;

    try {
      final url =
          '$_baseUrl/gemini-2.0-flash-exp-image-generation:generateContent?key=$_apiKey';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'responseModalities': ['TEXT', 'IMAGE'],
          'temperature': 0.7,
          'maxOutputTokens': 100,
        },
      };

      debugPrint("Making HTTP request to: $url");
      debugPrint("Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response headers: ${response.headers}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("Response data: $responseData");

        Uint8List? imageBytes = await _extractImageFromResponse(responseData);

        if (imageBytes != null) {
          generatedImageBytes.value = imageBytes;
          statusMessage.value = "Image generated successfully!";
          await _logImageInfo(imageBytes);
        } else {
          statusMessage.value = "No image data found in response.";
          _debugResponse(responseData);
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        statusMessage.value =
            "API Error: ${errorResponse['error']['message'] ?? 'Unknown error'}";
        debugPrint("Error response: $errorResponse");
      }
    } catch (e, stack) {
      statusMessage.value = "Network Error: ${e.toString()}";
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stack");
    } finally {
      isLoading.value = false;
    }
  }

  Future<Uint8List?> _extractImageFromResponse(
    Map<String, dynamic> responseData,
  ) async {
    try {
      final candidates = responseData['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        debugPrint("No candidates in response");
        return null;
      }

      for (final candidate in candidates) {
        final content = candidate['content'];
        if (content == null) continue;

        final parts = content['parts'] as List?;
        if (parts == null) continue;

        for (int i = 0; i < parts.length; i++) {
          final part = parts[i];
          debugPrint("Part $i: ${part.keys}");

          // Check for inline_data (this is how images are returned in the REST API)
          if (part.containsKey('inline_data') ||
              part.containsKey('inlineData')) {
            final inlineData = part['inline_data'] ?? part['inlineData'];
            final mimeType = inlineData['mime_type'] ?? inlineData['mimeType'];

            debugPrint("Found inline data with mimeType: $mimeType");

            if (mimeType != null && mimeType.toString().startsWith('image/')) {
              final base64Data = inlineData['data'];
              if (base64Data != null) {
                return base64Decode(base64Data);
              }
            }
          }

          // Also check for text content
          if (part.containsKey('text')) {
            debugPrint("Text part: ${part['text']}");
          }
        }
      }
    } catch (e) {
      debugPrint("Error extracting image: $e");
    }

    return null;
  }

  void _debugResponse(Map<String, dynamic> responseData) {
    debugPrint("=== FULL RESPONSE DEBUG ===");
    debugPrint("Response structure: ${responseData.keys}");

    final candidates = responseData['candidates'] as List?;
    if (candidates != null) {
      for (int i = 0; i < candidates.length; i++) {
        debugPrint("Candidate $i: ${candidates[i].keys}");
        final content = candidates[i]['content'];
        if (content != null) {
          debugPrint("Content keys: ${content.keys}");
          final parts = content['parts'] as List?;
          if (parts != null) {
            for (int j = 0; j < parts.length; j++) {
              debugPrint("Part $j keys: ${parts[j].keys}");
              debugPrint("Part $j content: ${parts[j]}");
            }
          }
        }
      }
    }
    debugPrint("=== END DEBUG ===");
  }

  Future<void> _logImageInfo(Uint8List imageBytes) async {
    try {
      final decoded = await decodeImageFromList(imageBytes);
      debugPrint("Generated image size: ${decoded.width}x${decoded.height}");
    } catch (e) {
      debugPrint("Image decode failed: $e");
    }
  }
}
