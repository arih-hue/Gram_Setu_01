import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final List<Map<String, dynamic>> _reminders = [
    {'name': 'Paracetamol 500mg', 'time': '8:00 AM', 'taken': true, 'period': 'Morning'},
    {'name': 'Amoxicillin 250mg', 'time': '8:00 AM', 'taken': true, 'period': 'Morning'},
    {'name': 'Paracetamol 500mg', 'time': '2:00 PM', 'taken': false, 'period': 'Afternoon'},
    {'name': 'Amoxicillin 250mg', 'time': '2:00 PM', 'taken': false, 'period': 'Afternoon'},
    {'name': 'Metformin 500mg', 'time': '2:00 PM', 'taken': false, 'period': 'Afternoon'},
    {'name': 'Amoxicillin 250mg', 'time': '8:00 PM', 'taken': false, 'period': 'Night'},
    {'name': 'Amlodipine 5mg', 'time': '8:00 PM', 'taken': false, 'period': 'Night'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Medicine Reminders', showBack: true, showSos: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s Schedule', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
            const SizedBox(height: 6),
            Text('Never miss a dose!', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
            const SizedBox(height: 16),



            // Morning
            ..._buildPeriod('Morning ☀️', 'Morning'),
            const SizedBox(height: 16),

            // Afternoon
            ..._buildPeriod('Afternoon 🌤️', 'Afternoon'),
            const SizedBox(height: 16),

            // Night
            ..._buildPeriod('Night 🌙', 'Night'),

            const SizedBox(height: 24),

            // Add Reminder button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Custom Reminder'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPeriod(String label, String period) {
    final periodMeds = _reminders.where((r) => r['period'] == period).toList();
    return [
      Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
      const SizedBox(height: 8),
      ...periodMeds.asMap().entries.map((entry) {
        final i = _reminders.indexOf(entry.value);
        final r = entry.value;
        final taken = r['taken'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: taken ? AppColors.success.withOpacity(0.05) : AppColors.adaptiveSurface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: taken ? AppColors.success.withOpacity(0.3) : AppColors.adaptiveBorder(context)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _reminders[i]['taken'] = !taken),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: taken ? AppColors.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: taken ? AppColors.success : Colors.grey.shade400, width: 2),
                  ),
                  child: taken ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: taken ? AppColors.adaptiveTextHint(context) : AppColors.adaptiveTextPrimary(context),
                        decoration: taken ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(r['time'] as String, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                  ],
                ),
              ),
              if (!taken)
                TextButton(
                  onPressed: () => setState(() => _reminders[i]['taken'] = true),
                  child: const Text('Take', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              if (taken)
                const Icon(Icons.check_circle, color: AppColors.success, size: 22),
            ],
          ),
        );
      }),
    ];
  }
}
