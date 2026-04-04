import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gram_setu/pages/video_call_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../services/api_service.dart';
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
  
  Map<String, dynamic> _stats = {
    'patientsSeen': '0',
    'hoursGiven': '0.0',
    'thisWeekHours': '0.0'
  };
  
  Map<String, dynamic>? _topDoctor;
  int _userRank = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      final doctorId = user['_id'];
      
      // Fetch stats
      final statsRes = await ApiService.get('/doctor/stats/$doctorId');
      if (statsRes.statusCode == 200) {
        final data = jsonDecode(statsRes.body);
        _stats['patientsSeen'] = data['patientsSeen']?.toString() ?? '0';
        _stats['hoursGiven'] = data['hoursGiven']?.toString() ?? '0.0';
        _stats['thisWeekHours'] = data['thisWeekHours']?.toString() ?? '0.0';
      }

      // Fetch leaderboard for Community Champion
      final lbRes = await ApiService.get('/doctor/leaderboard');
      if (lbRes.statusCode == 200) {
        final lbData = jsonDecode(lbRes.body)['leaderboard'] as List;
        if (lbData.isNotEmpty) {
          _topDoctor = lbData[0];
          final myIndex = lbData.indexWhere((d) => d['doctorId'] == doctorId);
          _userRank = myIndex != -1 ? myIndex + 1 : 0;
        }
      }
    } catch (e) {
      print('Doctor Stats Error: $e');
    } finally {
      if (mounted) setState(() {});
    }
  }

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
        child: RefreshIndicator(
          onRefresh: _fetchStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    Text('${user?['hospitalName'] ?? 'District Hospital'} • MCI: ${user?['mciNumber'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats
                Row(
                  children: [
                    Expanded(child: StatCard(title: 'Patients Seen', value: _stats['patientsSeen'], icon: Icons.people_outline, bgColor: AppColors.doctorGreen, textColor: Colors.white, iconColor: Colors.white, iconBgColor: Colors.white.withValues(alpha: 0.2))),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(title: 'Hours Given', value: '${_stats['hoursGiven']}h', icon: Icons.schedule, bgColor: AppColors.softBlue, textColor: Colors.white, iconColor: Colors.white, iconBgColor: Colors.white.withValues(alpha: 0.2))),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(title: 'This Week', value: '${_stats['thisWeekHours']}h', icon: Icons.trending_up, bgColor: AppColors.accentYellow, textColor: AppColors.adaptiveTextPrimary(context), iconColor: AppColors.adaptiveTextPrimary(context), iconBgColor: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(height: 24),

                // Quick Actions
                const SectionHeader(title: 'Consultation Management'),
                ActionCard(
                  title: 'New Requests',
                  subtitle: 'View and accept pending sessions',
                  icon: Icons.pending_actions_outlined,
                  isDark: true,
                  accentColor: AppColors.doctorGreen,
                  onTap: () => Navigator.pushNamed(context, '/consultation_requests'),
                ).animate().fadeIn(delay: 100.ms),
                ActionCard(
                  title: 'Search Patient',
                  subtitle: 'Enter Patient UID to retrieve complete medical profile',
                  icon: Icons.person_search_outlined,
                  isDark: true,
                  accentColor: AppColors.primaryTeal,
                  onTap: () => Navigator.pushNamed(context, '/search_patient'),
                ).animate().fadeIn(delay: 200.ms),
                ActionCard(
                  title: 'View Prescriptions',
                  subtitle: 'Search patient by UID to view past prescriptions',
                  icon: Icons.history_edu_outlined,
                  isDark: true,
                  accentColor: AppColors.softBlue,
                  onTap: () => Navigator.pushNamed(context, '/search_patient'), // Using same search page logic
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),

                // Community Champion
                const SectionHeader(title: 'Community Champion 🏆'),
                if (_topDoctor != null) 
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.doctorGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: AppColors.doctorGreen.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: const Text('🥇', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _topDoctor!['doctorId'] == user?['_id'] 
                                  ? 'You are the Champion!' 
                                  : 'Top Hero: Dr. ${_topDoctor!['doctorName']}', 
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                              Text(
                                '${_topDoctor!['totalHours']} hours contributed this month', 
                                style: const TextStyle(color: Colors.white70, fontSize: 13)
                              ),
                            ],
                          ),
                        ),
                        if (_userRank > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text('Rank: #$_userRank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                      ],
                    ),
                  ).animate().scale(delay: 400.ms),
                const SizedBox(height: 40),
              ],
            ),
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
          _buildNavItem(Icons.workspace_premium_outlined, 'Rewards', 1),
          _buildNavItem(Icons.person_outline, 'Profile', 2),
        ],
      ),
    ).animate().slideY(begin: 1, delay: 500.ms, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () async {
        if (index == 0) {
           setState(() => _currentIndex = index);
           return;
        }

        if (index == 1) {
          await Navigator.pushNamed(context, '/leaderboard');
        } else if (index == 2) {
          await Navigator.pushNamed(context, '/profile', arguments: 'doctor');
        }

        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

