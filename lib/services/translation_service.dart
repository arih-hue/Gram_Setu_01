import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String apiKey = 'sk_4ms70hk5_L6gqAZ8bAz8THDPo6QYKvaUJ';
  static const String baseUrl = 'https://api.sarvam.ai/translate';

  static Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en-IN',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'api-subscription-key': apiKey,
        },
        body: jsonEncode({
          'input': text,
          'source_language_code': sourceLanguage,
          'target_language_code': targetLanguage,
          'speaker_gender': 'Male', // Sarvam API is strict about Title Case
          'mode': 'formal', // Optional
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] ?? text;
      } else {
        print('Translation Error: ${response.statusCode} - ${response.body}');
        return text;
      }
    } catch (e) {
      print('Translation Exception: $e');
      return text;
    }
  }
}
