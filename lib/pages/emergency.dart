import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';
import '../core/emergency_util.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _sosTriggered = false;

  final List<Map<String, dynamic>> _symptoms = [
    {'label': 'Severe Chest Pain', 'icon': Icons.favorite, 'selected': false},
    {'label': 'Difficulty Breathing', 'icon': Icons.air, 'selected': false},
    {'label': 'High Fever (>103°F)', 'icon': Icons.thermostat, 'selected': false},
    {'label': 'Loss of Consciousness', 'icon': Icons.visibility_off, 'selected': false},
    {'label': 'Continuous Vomiting', 'icon': Icons.sick, 'selected': false},
    {'label': 'Severe Bleeding', 'icon': Icons.water_drop, 'selected': false},
    {'label': 'Snake/Animal Bite', 'icon': Icons.pest_control, 'selected': false},
    {'label': 'Accident / Injury', 'icon': Icons.personal_injury, 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sosTriggered ? const Color(0xFF7F1D1D) : AppColors.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.emergencyRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Emergency SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_sosTriggered) ...[
              const SizedBox(height: 20),

              // Large SOS Button
              GestureDetector(
                onTap: _triggerSos,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.emergencyGradient,
                    boxShadow: [
                      BoxShadow(color: AppColors.emergencyRed.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, color: Colors.white, size: 40),
                      SizedBox(height: 4),
                      Text('SOS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      Text('Tap for help', style: TextStyle(color: AppColors.adaptiveTextSecondary(context), fontSize: 12)),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms),
              ),

              const SizedBox(height: 24),
              Text('Press the SOS button to alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
              Text('Panchayat, doctors, and nearby hospitals', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),

              const SizedBox(height: 32),

              // Symptom checklist
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.adaptiveBorder(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What symptoms? (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                    const SizedBox(height: 4),
                    Text('Select to help doctors prepare', style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextSecondary(context))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _symptoms.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return FilterChip(
                          selected: s['selected'] as bool,
                          onSelected: (v) => setState(() => _symptoms[i]['selected'] = v),
                          label: Text(s['label'] as String, style: const TextStyle(fontSize: 12)),
                          avatar: Icon(s['icon'] as IconData, size: 16),
                          selectedColor: AppColors.emergencyRed.withOpacity(0.15),
                          checkmarkColor: AppColors.emergencyRed,
                          side: BorderSide(color: (s['selected'] as bool) ? AppColors.emergencyRed : AppColors.adaptiveBorder(context)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Call 108
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => EmergencyUtil.callEmergency(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.emergencyRed, width: 2),
                    foregroundColor: AppColors.emergencyRed,
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text('Call 108 Ambulance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 12),

              // Nearest hospital
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_hospital, color: AppColors.emergencyRed, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nearest Hospital', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                          Text('District Hospital, Bhopal — 12 km', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                        ],
                      ),
                    ),
                    Icon(Icons.directions, color: AppColors.primaryTeal),
                  ],
                ),
              ),
            ] else ...[
              // SOS Triggered view
              const SizedBox(height: 40),
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80)
                  .animate()
                  .fadeIn()
                  .scale(begin: const Offset(0.5, 0.5)),
              const SizedBox(height: 20),
              Text(
                'SOS Alert Sent!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                'Help is on the way',
                style: TextStyle(fontSize: 16, color: AppColors.adaptiveTextSecondary(context)),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),

              _buildAlertStatus(Icons.account_balance, 'Panchayat', 'Notified ✓', true),
              _buildAlertStatus(Icons.medical_services, 'Doctor on call', 'Connecting...', false),
              _buildAlertStatus(Icons.local_hospital, 'District Hospital', 'Alerted ✓', true),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text('Patient: Demo User', style: TextStyle(color: Colors.white, fontSize: 14)),
                    Text('UID: UID00VFYV3X3', style: TextStyle(color: AppColors.adaptiveTextSecondary(context), fontSize: 13)),
                    SizedBox(height: 8),
                    Text('Symptoms: Severe Chest Pain', style: TextStyle(color: AppColors.adaptiveTextSecondary(context), fontSize: 13)),
                    Text('Location: Rampur Village', style: TextStyle(color: AppColors.adaptiveTextSecondary(context), fontSize: 13)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => EmergencyUtil.callEmergency(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text('Call 108 Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertStatus(IconData icon, String title, String status, bool confirmed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
          Text(
            status,
            style: TextStyle(
              color: confirmed ? Colors.greenAccent : Colors.amber,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1);
  }

  void _triggerSos() {
    setState(() => _sosTriggered = true);
    EmergencyUtil.callEmergency(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 Emergency alert sent to Panchayat and doctors!'),
        backgroundColor: AppColors.emergencyRed,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
