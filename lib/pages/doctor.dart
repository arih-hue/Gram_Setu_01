import 'dart:convert';
import 'package:flutter/material.dart';
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
  
  final Map<String, dynamic> _stats = {
    'patientsSeen': '0',
    'hoursGiven': '0.0',
    'thisWeekHours': '0.0'
  };
  
  Map<String, dynamic>? _topDoctor;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      final doctorId = user['id'] ?? user['_id'];
      
      // 1. Fetch Stats
      final statsRes = await ApiService.get('/doctor/stats/$doctorId');
      if (statsRes.statusCode == 200) {
        final data = jsonDecode(statsRes.body);
        _stats['patientsSeen'] = data['patientsSeen']?.toString() ?? '0';
        _stats['hoursGiven'] = data['hoursGiven']?.toString() ?? '0.0';
        _stats['thisWeekHours'] = data['thisWeekHours']?.toString() ?? '0.0';
      }

      // 2. Fetch Leaderboard for Champion
      final lbRes = await ApiService.get('/doctor/leaderboard');
      if (lbRes.statusCode == 200) {
        final lbData = jsonDecode(lbRes.body)['leaderboard'] as List;
        if (lbData.isNotEmpty) {
          _topDoctor = lbData[0];
        }
      }
    } catch (e) {
      print('Doctor Dashboard Error: $e');
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
          onRefresh: _fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${userName.split(' ').first} 👨‍⚕️',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user?['hospitalName'] ?? 'District Hospital'} • MCI: ${user?['mciNumber'] ?? 'N/A'}', 
                      style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))
                    ),
                    Text(
                      '${user?['village'] ?? ''}${user?['village'] != null && user?['block'] != null ? ', ' : ''}${user?['block'] ?? ''}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.doctorGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Live Stats Section
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Patients Seen', 
                        value: _stats['patientsSeen'], 
                        icon: Icons.people_outline, 
                        bgColor: AppColors.doctorGreen, 
                        textColor: Colors.white, 
                        iconColor: Colors.white, 
                        iconBgColor: Colors.white.withOpacity(0.2)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Hours Given', 
                        value: '${_stats['hoursGiven']}h', 
                        icon: Icons.schedule, 
                        bgColor: AppColors.softBlue, 
                        textColor: Colors.white, 
                        iconColor: Colors.white, 
                        iconBgColor: Colors.white.withOpacity(0.2)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: 'Contribution This Week', 
                  value: '${_stats['thisWeekHours']} hours spent', 
                  icon: Icons.trending_up, 
                  bgColor: AppColors.accentYellow, 
                  textColor: AppColors.adaptiveTextPrimary(context), 
                  iconColor: AppColors.adaptiveTextPrimary(context), 
                  iconBgColor: Colors.white.withOpacity(0.4)
                ),
                const SizedBox(height: 32),

                // Dashboard Actions
                const SectionHeader(title: 'Consultation Management'),
                ActionCard(
                  title: 'New Requests',
                  subtitle: 'Accept incoming patient sessions',
                  icon: Icons.pending_actions_outlined,
                  isDark: true,
                  accentColor: AppColors.doctorGreen,
                  onTap: () => Navigator.pushNamed(context, '/consultation_requests'),
                ).animate().fadeIn(delay: 100.ms),
                
                ActionCard(
                  title: 'Active Consultations',
                  subtitle: 'Start sessions & write prescriptions',
                  icon: Icons.play_circle_outline,
                  isDark: true,
                  accentColor: AppColors.primaryTeal,
                  onTap: () => Navigator.pushNamed(context, '/accepted_consultations'),
                ).animate().fadeIn(delay: 200.ms),

                ActionCard(
                  title: 'Search Patient',
                  subtitle: 'Enter Patient UID to retrieve the complete medical profile',
                  icon: Icons.person_search_outlined,
                  isDark: true,
                  accentColor: AppColors.softBlue,
                  onTap: () => Navigator.pushNamed(context, '/search_patient'),
                ).animate().fadeIn(delay: 300.ms),

                ActionCard(
                  title: 'View Prescriptions',
                  subtitle: 'Search & view patient prescription history',
                  icon: Icons.description_outlined,
                  isDark: true,
                  accentColor: AppColors.panchayatPurple,
                  onTap: () => Navigator.pushNamed(context, '/view_prescription_search'),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 32),

                // Community Champion Card
                const SectionHeader(title: 'Community Champion 🏆'),
                if (_topDoctor != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.doctorGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.doctorGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                      ],
                      border: (_topDoctor!['doctorId'] == user?['id'] || _topDoctor!['doctorId'] == user?['_id'])
                        ? Border.all(color: Colors.amber, width: 2)
                        : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Text('🥇', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _topDoctor!['doctorId'] == (user?['id'] ?? user?['_id']) 
                                  ? 'You are the Champion!' 
                                  : 'Dr. ${_topDoctor!['doctorName']}', 
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                              ),
                              Text(
                                '${_topDoctor!['hospital']}', 
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_topDoctor!['totalHours']} hours contributed', 
                                style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 400.ms),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        child: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context).withAlpha(240),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.workspace_premium_outlined, 'Rewards', 1),
          _buildNavItem(Icons.person_outline, 'Profile', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () async {
        if (index == 0) {
          setState(() => _currentIndex = index);
          return;
        }

        switch (index) {
          case 1:
            await Navigator.pushNamed(context, '/leaderboard');
            break;
          case 2:
            await Navigator.pushNamed(context, '/profile', arguments: 'doctor');
            break;
        }

        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.accentYellow : AppColors.adaptiveTextSecondary(context), size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
