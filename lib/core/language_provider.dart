import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en-IN'; // Default language
  bool _isTranslating = false;

  String get currentLanguage => _currentLanguage;
  bool get isTranslating => _isTranslating;

  final Map<String, String> _languageNames = {
    'en-IN': 'English',
    'hi-IN': 'Hindi',
    'ta-IN': 'Tamil',
    'te-IN': 'Telugu',
    'bn-IN': 'Bengali',
  };

  String get currentLanguageName => _languageNames[_currentLanguage] ?? 'English';

  void setLanguage(String langCode) {
    if (_currentLanguage != langCode) {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  Future<String> translateText(String text) async {
    if (_currentLanguage == 'en-IN') return text;
    
    _isTranslating = true;
    notifyListeners();
    
    try {
      final translated = await TranslationService.translate(
        text: text,
        targetLanguage: _currentLanguage,
      );
      return translated;
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }
}
