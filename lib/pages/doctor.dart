import 'package:flutter/material.dart';
import 'package:gram_setu/pages/video_call_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';
import 'package:provider/provider.dart';
import '../core/user_provider.dart';

import '../widgets/gram_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/section_header.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final userName = user?['name'] ?? 'Doctor';

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(
        roleLabel: 'Doctor Dashboard',
        onLogoutTap: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${userName.split(' ').first} 👨‍⚕️',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context)),
                  ),
                  const SizedBox(height: 4),
                  Text('${user?['hospitalName'] ?? 'District Hospital'} • MCI: ${user?['mciNumber'] ?? 'N/A'}', 
                    style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
                  const SizedBox(height: 20),

                  // Stats
                   Row(
                    children: [
                      Expanded(child: StatCard(title: 'Patients Seen', value: '47', icon: Icons.people_outline, bgColor: AppColors.doctorGreen, textColor: Colors.white, iconColor: Colors.white, iconBgColor: Colors.white.withValues(alpha: 0.2))),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(title: 'Hours Given', value: '12h', icon: Icons.schedule, bgColor: AppColors.softBlue, textColor: Colors.white, iconColor: Colors.white, iconBgColor: Colors.white.withValues(alpha: 0.2))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: StatCard(title: 'This Week', value: '3h', icon: Icons.trending_up, bgColor: AppColors.accentYellow, textColor: AppColors.adaptiveTextPrimary(context), iconColor: AppColors.adaptiveTextPrimary(context), iconBgColor: Colors.white.withValues(alpha: 0.4))),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(title: 'Rating', value: '4.8★', icon: Icons.star_outline, bgColor: AppColors.primaryTeal, textColor: Colors.white, iconColor: Colors.white, iconBgColor: Colors.white.withValues(alpha: 0.2))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const SectionHeader(title: 'Quick Actions'),
                  ActionCard(
                    title: 'Pending Consultations',
                    subtitle: '3 patients waiting',
                    icon: Icons.pending_actions,
                    isDark: true,
                    accentColor: AppColors.doctorGreen,
                    onTap: () {},
                  ),
                  ActionCard(
                    title: 'Start Consultation',
                    subtitle: 'Begin a new session',
                    icon: Icons.videocam_outlined,
                    isDark: true,
                    accentColor: AppColors.doctorGreen,
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
                    title: 'Patient Records',
                    subtitle: 'View patient history by UID',
                    icon: Icons.folder_shared_outlined,
                    isDark: true,
                    accentColor: AppColors.softBlue,
                    onTap: () {},
                  ),
                  ActionCard(
                    title: 'Write Prescription',
                    subtitle: 'Prescribe medicines',
                    icon: Icons.edit_note,
                    isDark: true,
                    accentColor: AppColors.primaryTeal,
                    onTap: () {},
                  ),
                  ActionCard(
                    title: 'My Schedule',
                    subtitle: 'Manage consultation slots',
                    icon: Icons.calendar_month_outlined,
                    isDark: true,
                    accentColor: AppColors.panchayatPurple,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),

                  // Today's Schedule
                  const SectionHeader(title: "Today's Schedule"),
                  _buildScheduleItem('9:00 AM', 'Rajesh Kumar', 'Fever, headache', 'Completed', AppColors.success),
                  _buildScheduleItem('10:30 AM', 'Priya Devi', 'Follow-up visit', 'Completed', AppColors.success),
                  _buildScheduleItem('2:00 PM', 'Amit Singh', 'Chest pain (Urgent)', 'Upcoming', AppColors.warning),
                  _buildScheduleItem('4:00 PM', 'Sunita Bai', 'Diabetes review', 'Upcoming', AppColors.info),
                  const SizedBox(height: 24),

                  // Recognition
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.doctorGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Community Champion', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text('Thank you for 12 hours of service! 🎉', style: TextStyle(color: AppColors.adaptiveTextSecondary(context), fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context).withAlpha(229),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.people_outline, 'Patients', 1),
          _buildNavItem(Icons.person_outline, 'Profile', 2),
        ],
      ),
    ).animate().slideY(begin: 1, delay: 800.ms, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 2) Navigator.pushNamed(context, '/profile', arguments: 'doctor');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.adaptiveTextPrimary(context) : AppColors.adaptiveTextSecondary(context),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.adaptiveTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String patientName, String description, String status, Color statusColor) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(time, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.titleMedium?.color)),
                Text(description, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

