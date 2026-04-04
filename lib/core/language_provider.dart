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

  // Prevent redundant API calls by caching translations
  final Map<String, Map<String, String>> _translationCache = {};

  Future<String> translateText(String text) async {
    if (_currentLanguage == 'en-IN') return text;
    
    _translationCache.putIfAbsent(_currentLanguage, () => {});
    if (_translationCache[_currentLanguage]!.containsKey(text)) {
      return _translationCache[_currentLanguage]![text]!;
    }
    
    _isTranslating = true;
    // Debounce notifyListeners a bit or skip it here since it causes rebuild loops 
    // when multiple TranslatedText widgets mount. Just flip bool.
    // notifyListeners(); 
    
    try {
      final translated = await TranslationService.translate(
        text: text,
        targetLanguage: _currentLanguage,
      );
      
      // Do not cache string if it comes back exactly as English (usually indicates API failure/fallback)
      if (translated != text) {
        _translationCache[_currentLanguage]![text] = translated;
      }
      
      return translated;
    } finally {
      _isTranslating = false;
      // notifyListeners();
    }
  }
}
