import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language_provider.dart';

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String _translated = '';
  String _lastLang = '';

  @override
  void initState() {
    super.initState();
    _translated = widget.text;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langProvider = Provider.of<LanguageProvider>(context);
    if (langProvider.currentLanguage != _lastLang) {
      _lastLang = langProvider.currentLanguage;
      _translate();
    }
  }

  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translate();
    }
  }

  Future<void> _translate() async {
    // If it's English or empty, no need to call API
    if (_lastLang == 'en-IN' || widget.text.trim().isEmpty) {
      if (mounted) setState(() => _translated = widget.text);
      return;
    }
    
    // Slight loading indicator or keeping previous text
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final result = await langProvider.translateText(widget.text);
    
    if (mounted) {
      setState(() {
        _translated = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translated,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
