import 'package:flutter/material.dart';
import 'package:gram_setu/pages/video_call_page.dart';

import '../core/app_colors.dart';
import 'package:provider/provider.dart';
import '../core/user_provider.dart';

import '../widgets/gram_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/section_header.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;
    final userName = user?['name'] ?? 'User';
    final uid = user?['uid'] ?? 'N/A';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(
        roleLabel: 'Patient Dashboard',
        onLogoutTap: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Row (no theme toggle)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${userName.split(' ').first} 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.displayLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Your UID', style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color)),
                      Text(
                        uid,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Active Rx',
                    value: '2 Units',
                    icon: Icons.medication_outlined,
                    bgColor: AppColors.doctorGreen,
                    textColor: Colors.white,
                    iconBgColor: Colors.white.withValues(alpha: 0.2),
                    iconColor: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Consultations',
                    value: '3 Done',
                    icon: Icons.calendar_today_outlined,
                    bgColor: AppColors.accentYellow,
                    textColor: AppColors.adaptiveTextPrimary(context),
                    iconBgColor: Colors.white.withValues(alpha: 0.4),
                    iconColor: AppColors.adaptiveTextPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const SectionHeader(title: 'Quick Actions'),
            ActionCard(
              title: 'Book Consultation',
              subtitle: 'Talk to a doctor now',
              icon: Icons.medical_services_outlined,
              isDark: true,
              accentColor: AppColors.primaryTeal,
              onTap: () => Navigator.pushNamed(context, '/consultation'),
            ),
            ActionCard(
              title: 'Join Video Call',
              subtitle: 'Start secure session',
              icon: Icons.videocam_outlined,
              isDark: true,
              accentColor: AppColors.softBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoCallPage(roomName: 'doctor_consultation_room'),
                  ),
                );
              },
            ),
            ActionCard(
              title: 'View Prescriptions',
              subtitle: 'Check your medicines',
              icon: Icons.description_outlined,
              isDark: true,
              accentColor: AppColors.softBlue,
              onTap: () => Navigator.pushNamed(context, '/prescriptions'),
            ),
            ActionCard(
              title: 'Medicine Reminders',
              subtitle: 'Set and manage alarms',
              icon: Icons.notifications_none,
              isDark: true,
              accentColor: AppColors.warning,
              onTap: () => Navigator.pushNamed(context, '/medicine_reminder'),
            ),
            ActionCard(
              title: 'Health Vitals',
              subtitle: 'Check heart rate & SpO2',
              icon: Icons.monitor_heart_outlined,
              isDark: true,
              accentColor: AppColors.emergencyRed,
              onTap: () => Navigator.pushNamed(context, '/vitals_recorder'),
            ),
            ActionCard(
              title: 'AI Health Assistant',
              subtitle: 'Preventive health tips',
              icon: Icons.health_and_safety_outlined,
              isDark: true,
              accentColor: AppColors.doctorGreen,
              onTap: () => Navigator.pushNamed(context, '/health_assistant'),
            ),

            const SizedBox(height: 20),

            // Active Prescriptions
            SectionHeader(
              title: 'Active Prescriptions',
              actionText: 'View All',
              onAction: () => Navigator.pushNamed(context, '/prescriptions'),
            ),
            _buildPrescriptionCard(context, 'Paracetamol 500mg', 'Twice daily after meals', 'Next dose: 2:00 PM'),
            _buildPrescriptionCard(context, 'Amoxicillin 250mg', 'Thrice daily', 'Next dose: 6:00 PM'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.person_outline, Icons.person, 'Profile'),
              _buildNavItem(2, Icons.settings_outlined, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) {
          Navigator.pushNamed(context, '/profile', arguments: {
          'role': 'patient',
          'user': ModalRoute.of(context)?.settings.arguments,
        });
        }
        if (index == 2) Navigator.pushNamed(context, '/settings');
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryTeal : theme.textTheme.bodySmall?.color,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, String name, String dosage, String nextDose) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication_outlined, color: AppColors.primaryTeal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                Text(dosage, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 2),
                Text(nextDose, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Mark Taken', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
