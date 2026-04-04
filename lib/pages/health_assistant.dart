import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';

class HealthAssistantScreen extends StatefulWidget {
  const HealthAssistantScreen({super.key});

  @override
  State<HealthAssistantScreen> createState() => _HealthAssistantScreenState();
}

class _HealthAssistantScreenState extends State<HealthAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      isBot: true,
      text: 'Namaste! 🙏 I am your Gram Setu Health Assistant.\n\nI can provide preventive health guidance for minor symptoms like fever, cold, headache, or dehydration.\n\n⚠️ I cannot diagnose diseases or prescribe medicines. For serious symptoms, please consult a doctor.',
    ),
  ];

  final Map<String, String> _responses = {
    'fever': '🌡️ Preventive Guidance for Fever:\n\n• Drink plenty of fluids (water, ORS, coconut water)\n• Rest properly — avoid physical exertion\n• Use a cold compress on forehead\n• Monitor temperature every 4 hours\n• Wear light, comfortable clothing\n\nIf fever exceeds 103°F or persists for more than 3 days → Consult a doctor immediately.',
    'cold': '🤧 Preventive Guidance for Cold:\n\n• Drink warm water throughout the day\n• Steam inhalation 2-3 times daily\n• Gargle with warm salt water\n• Eat warm soups and easily digestible food\n• Rest well and avoid cold beverages\n\nIf cold persists for more than a week → Consult a doctor.',
    'headache': '🤕 Preventive Guidance for Headache:\n\n• Rest in a quiet, dark room\n• Drink water — dehydration often causes headaches\n• Apply a cold or warm compress\n• Gently massage temples\n• Avoid screen time for a while\n\nIf headache is severe, sudden, or accompanied by vision problems → Press SOS or consult a doctor.',
    'dehydration': '💧 Preventive Guidance for Dehydration:\n\n• Drink small sips of water frequently\n• Use ORS (Oral Rehydration Solution)\n• Eat water-rich fruits (watermelon, cucumber)\n• Avoid caffeine and alcohol\n• Rest in a cool place\n\nIf dizziness, confusion, or dark urine persists → Seek medical help.',
    'stomach': '🤢 Preventive Guidance for Stomach Issues:\n\n• Eat light, bland food (khichdi, dalia)\n• Drink water and ORS frequently\n• Avoid spicy, oily, and heavy food\n• Rest your stomach — eat small portions\n• Wash hands before eating\n\nIf vomiting or diarrhea continues for more than 24 hours → Consult a doctor.',
    'fatigue': '😴 Preventive Guidance for Fatigue:\n\n• Get 7-8 hours of sleep\n• Eat nutritious meals with iron-rich foods\n• Stay hydrated throughout the day\n• Take short breaks during work\n• Light exercise like walking can help\n\nIf fatigue persists for more than 2 weeks → Consult a doctor.',
    'chest pain': '🚨 ALERT: Chest pain can be a medical emergency!\n\nThis requires immediate medical attention.\n\n🔴 Press the SOS button\n🔴 Contact your Panchayat\n🔴 Call 108 ambulance immediately\n\nDo not delay seeking help.',
    'breathing': '🚨 ALERT: Breathing difficulty is a serious symptom!\n\nThis requires immediate medical attention.\n\n🔴 Press the SOS button\n🔴 Sit upright — do not lie flat\n🔴 Contact Panchayat or call 108\n\nDo not wait — get help now.',
  };

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _messages.add(_ChatMessage(isBot: false, text: text)));
    _controller.clear();

    // Find matching response
    String response = '🤔 I understand you mentioned "$text".\n\nI can help with preventive advice for: fever, cold, headache, dehydration, stomach issues, and fatigue.\n\nFor specific medical concerns, please consult a doctor through the consultation feature.\n\n⚠️ This is preventive guidance and not a medical diagnosis.';

    for (final entry in _responses.entries) {
      if (text.toLowerCase().contains(entry.key)) {
        response = entry.value;
        break;
      }
    }

    // Check for emergency keywords
    final emergencyKeywords = ['chest pain', 'breathing', 'unconscious', 'vomiting blood', 'severe'];
    final isEmergency = emergencyKeywords.any((k) => text.toLowerCase().contains(k));

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _messages.add(_ChatMessage(isBot: true, text: response));
        if (!isEmergency) {
          _messages.add(_ChatMessage(isBot: true, text: '⚠️ This is preventive guidance and not a medical diagnosis.', isDisclaimer: true));
        }
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.adaptiveSurface(context),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFD1FAE5),
              radius: 16,
              child: Icon(Icons.health_and_safety, size: 18, color: AppColors.doctorGreen),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
                Text('Preventive guidance only', style: TextStyle(fontSize: 11, color: AppColors.adaptiveTextSecondary(context))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/emergency'),
            child: const Text('SOS', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Quick symptom buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.adaptiveSurface(context),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Fever', 'Cold', 'Headache', 'Dehydration', 'Stomach pain', 'Fatigue'].map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(s, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextPrimary(context))),
                      onPressed: () {
                        _controller.text = s;
                        _sendMessage();
                      },
                      backgroundColor: AppColors.adaptiveBackground(context),
                      side: BorderSide(color: AppColors.adaptiveBorder(context)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.adaptiveSurface(context),
              border: Border(top: BorderSide(color: AppColors.adaptiveBorder(context))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: AppColors.adaptiveTextPrimary(context)),
                    decoration: InputDecoration(
                      hintText: 'Describe your symptoms...',
                      hintStyle: TextStyle(color: AppColors.adaptiveTextSecondary(context)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded, color: AppColors.primaryTeal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (msg.isBot) ...[
            CircleAvatar(
              backgroundColor: msg.isDisclaimer ? AppColors.warning.withOpacity(0.1) : const Color(0xFFD1FAE5),
              radius: 14,
              child: Icon(
                msg.isDisclaimer ? Icons.warning_amber : Icons.health_and_safety,
                size: 14,
                color: msg.isDisclaimer ? AppColors.warning : AppColors.doctorGreen,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: msg.isBot
                    ? (msg.isDisclaimer ? AppColors.warning.withOpacity(0.08) : AppColors.adaptiveSurface(context))
                    : AppColors.primaryTeal,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(msg.isBot ? 4 : 14),
                  bottomRight: Radius.circular(msg.isBot ? 14 : 4),
                ),
                border: msg.isBot ? Border.all(color: msg.isDisclaimer ? AppColors.warning.withOpacity(0.3) : AppColors.adaptiveBorder(context)) : null,
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 14,
                  color: msg.isBot
                      ? (msg.isDisclaimer ? AppColors.warning : AppColors.adaptiveTextPrimary(context))
                      : Colors.white,
                  height: 1.4,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool isBot;
  final String text;
  final bool isDisclaimer;

  _ChatMessage({required this.isBot, required this.text, this.isDisclaimer = false});
}
