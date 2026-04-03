import 'package:flutter/material.dart';
import 'package:gram_setu/pages/video_call_page.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/section_header.dart';
import 'package:provider/provider.dart';
import '../core/user_provider.dart';

class AshaWorkerDashboard extends StatefulWidget {
  const AshaWorkerDashboard({super.key});

  @override
  State<AshaWorkerDashboard> createState() => _AshaWorkerDashboardState();
}

class _AshaWorkerDashboardState extends State<AshaWorkerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;
    final name = user?['name'] ?? 'User';
    final village = user?['location'] ?? 'Rampur';
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(
        roleLabel: 'ASHA Worker Dashboard',
        onLogoutTap: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Namaste, ${name.split(' ').first} 🙏',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color),
              ),
              const SizedBox(height: 4),
              Text('Village: $village • ASHA ID: ${user?['ashaId'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(height: 20),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Patients Attended',
                      value: '42',
                      icon: Icons.people_outline,
                      bgColor: AppColors.ashaWorkerPink,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      iconBgColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Alerts Raised',
                      value: '2',
                      icon: Icons.warning_amber,
                      bgColor: AppColors.warning,
                      textColor: AppColors.adaptiveTextPrimary(context),
                      iconColor: AppColors.adaptiveTextPrimary(context),
                      iconBgColor: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const SectionHeader(title: 'Quick Actions'),
              ActionCard(
                title: 'Add New Patient',
                subtitle: 'Register a new villager with health ID',
                icon: Icons.person_add_outlined,
                isDark: true,
                accentColor: AppColors.ashaWorkerPink,
                onTap: () => Navigator.pushNamed(context, '/add_patient'),
              ),
              ActionCard(
                title: 'Book Consultation',
                subtitle: 'Book a doctor visit for a patient',
                icon: Icons.calendar_month_outlined,
                isDark: true,
                accentColor: AppColors.softBlue,
                onTap: () => Navigator.pushNamed(context, '/asha_consultation'),
              ),
              ActionCard(
                title: 'Doctor Video Call',
                subtitle: 'Connect patient to specialist',
                icon: Icons.videocam_outlined,
                isDark: true,
                accentColor: AppColors.ashaWorkerPink,
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
                title: 'Record Vitals',
                subtitle: 'Enter patient UID and log vitals',
                icon: Icons.monitor_heart_outlined,
                isDark: true,
                accentColor: AppColors.ashaWorkerPink,
                onTap: () => Navigator.pushNamed(context, '/vitals_recorder'),
              ),
              ActionCard(
                title: 'Report Emergency',
                subtitle: 'Flag urgent health cases',
                icon: Icons.emergency_outlined,
                isDark: true,
                accentColor: AppColors.emergencyRed,
                onTap: () => Navigator.pushNamed(context, '/emergency'),
              ),
              ActionCard(
                title: 'Health Awareness',
                subtitle: 'Look up disease info & preventive measures',
                icon: Icons.campaign_outlined,
                isDark: true,
                accentColor: AppColors.primaryTeal,
                onTap: () => Navigator.pushNamed(context, '/health_awareness'),
              ),
              const SizedBox(height: 24),

              // Recent Visits
              const SectionHeader(title: 'Recent Visits'),
              _buildVisitCard(theme, 'Ramesh Yadav', 'UID003829', 'BP: 130/85, HR: 78', '10:30 AM', false),
              _buildVisitCard(theme, 'Geeta Devi', 'UID004512', 'BP: 160/95, Sugar: 280', '11:15 AM', true),
              _buildVisitCard(theme, 'Mohan Lal', 'UID001837', 'BP: 120/80, HR: 72', '12:00 PM', false),
              _buildVisitCard(theme, 'Kavita Bai', 'UID005923', 'SpO2: 93%, Fever: 102°F', '1:30 PM', true),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildVisitCard(ThemeData theme, String name, String uid, String vitals, String time, bool hasAlert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasAlert ? AppColors.warning.withValues(alpha: 0.5) : theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasAlert ? AppColors.warning.withValues(alpha: 0.1) : AppColors.ashaWorkerPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasAlert ? Icons.warning_amber : Icons.person_outline,
              color: hasAlert ? AppColors.warning : AppColors.ashaWorkerPink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color)),
                    const SizedBox(width: 6),
                    if (hasAlert)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Alert', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning)),
                      ),
                  ],
                ),
                Text(uid, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                const SizedBox(height: 2),
                Text(vitals, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
        ],
      ),
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
        if (index == 1) Navigator.pushNamed(context, '/profile', arguments: 'asha');
        if (index == 2) Navigator.pushNamed(context, '/settings');
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ashaWorkerPink.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.ashaWorkerPink : theme.textTheme.bodySmall?.color,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.ashaWorkerPink,
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
}
