import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/section_header.dart';

class HealthHistoryScreen extends StatelessWidget {
  const HealthHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Health History', showBack: true, showSos: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Vitals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
            const SizedBox(height: 6),
            Text('Your vitals history over time', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
            const SizedBox(height: 20),

            // Latest Vitals
            const SectionHeader(title: 'Latest Reading'),
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
                  Text('Recorded: Mar 10, 2026 by ASHA Worker', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _VitalTile(label: 'Blood Pressure', value: '128/82', unit: 'mmHg', icon: Icons.monitor_heart, color: AppColors.emergencyRed)),
                      const SizedBox(width: 10),
                      Expanded(child: _VitalTile(label: 'Heart Rate', value: '76', unit: 'bpm', icon: Icons.favorite, color: AppColors.ashaWorkerPink)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _VitalTile(label: 'SpO2', value: '97', unit: '%', icon: Icons.air, color: AppColors.softBlue)),
                      const SizedBox(width: 10),
                      Expanded(child: _VitalTile(label: 'Blood Sugar', value: '110', unit: 'mg/dL', icon: Icons.bloodtype, color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _VitalTile(label: 'Weight', value: '68', unit: 'kg', icon: Icons.fitness_center, color: AppColors.primaryTeal)),
                      const SizedBox(width: 10),
                      Expanded(child: _VitalTile(label: 'Temp', value: '98.4', unit: '°F', icon: Icons.thermostat, color: AppColors.doctorGreen)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // rPPG Quick Check
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_front, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Vitals Check', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Use camera to check heart rate & SpO2', style: TextStyle(color: AppColors.adaptiveTextSecondary(context), fontSize: 13)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () => _showRppgDemo(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryTeal,
                              minimumSize: const Size(0, 34),
                            ),
                            child: const Text('Start Scan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // History Timeline
            const SectionHeader(title: 'History Timeline'),
            _buildTimelineItem(context, 'Mar 10', 'Monthly checkup', 'BP: 128/82, HR: 76, SpO2: 97%', AppColors.success),
            _buildTimelineItem(context, 'Feb 10', 'Monthly checkup', 'BP: 132/85, HR: 80, SpO2: 96%', AppColors.warning),
            _buildTimelineItem(context, 'Jan 15', 'Emergency visit', 'High fever: 103°F, BP: 140/90', AppColors.warning),
            _buildTimelineItem(context, 'Jan 10', 'Monthly checkup', 'BP: 125/80, HR: 74, SpO2: 98%', AppColors.success),
            _buildTimelineItem(context, 'Dec 10', 'Monthly checkup', 'BP: 130/82, HR: 76, SpO2: 97%', AppColors.success),
            const SizedBox(height: 24),

            // Consultation History
            const SectionHeader(title: 'Consultation History'),
            _buildConsultItem(context, 'Dr. Sharma', 'Fever, headache', 'Mar 5, 2026', 'General consultation'),
            _buildConsultItem(context, 'Dr. Gupta', 'Diabetes review', 'Feb 20, 2026', 'Follow-up visit'),
            _buildConsultItem(context, 'Dr. Patel', 'Skin allergy', 'Feb 10, 2026', 'First consultation'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRppgDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.camera_front, color: AppColors.primaryTeal),
            SizedBox(width: 8),
            Text('rPPG Scan', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.face, size: 80, color: AppColors.primaryTeal),
            SizedBox(height: 16),
            Text('Camera-based vitals detection uses rPPG technology to read micro color changes in skin.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextSecondary(context))),
            SizedBox(height: 12),
            Text('Demo Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Heart Rate: 74 bpm', style: TextStyle(fontSize: 15, color: AppColors.primaryTeal)),
            Text('SpO2: 97%', style: TextStyle(fontSize: 15, color: AppColors.softBlue)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String date, String event, String details, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              Container(width: 2, height: 50, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.adaptiveSurface(context), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.adaptiveBorder(context))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(event, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                      Text(date, style: TextStyle(fontSize: 11, color: AppColors.adaptiveTextSecondary(context))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(details, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultItem(BuildContext context, String doctor, String issue, String date, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.adaptiveSurface(context), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.adaptiveBorder(context))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.doctorGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.medical_services, color: AppColors.doctorGreen, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                Text('$issue • $type', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
              ],
            ),
          ),
          Text(date, style: TextStyle(fontSize: 11, color: AppColors.adaptiveTextSecondary(context))),
        ],
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _VitalTile({required this.label, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
