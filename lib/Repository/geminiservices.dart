import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  late Gemini _gemini;

  void init({required String apiKey, required String model}) {
    _gemini = Gemini.init(
      apiKey: apiKey,
    );
  }

  Gemini get gemini => _gemini;
}
