import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../core/app_colors.dart';

import '../core/user_provider.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;
  int _consultationCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    
    setState(() => _isLoading = true);
    try {
      final uid = user['uid'];
      final consResponse = await ApiService.get('/consultation/count/$uid');
      if (consResponse.statusCode == 200) {
        _consultationCount = jsonDecode(consResponse.body)['count'];
      }
    } catch (e) {
      print('Dashboard Data Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;
    final userName = user?['name'] ?? 'User';
    final uid = user?['uid'] ?? 'N/A';

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(
        roleLabel: 'Patient Dashboard',
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
                // Greeting and UID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${userName.split(' ').first} 👋',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context)),
                        ),
                        const SizedBox(height: 4),
                        Text('How are you feeling today?', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.adaptiveSurface(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.adaptiveBorder(context)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Your UID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context))),
                          Text(uid, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Active Rx',
                        value: '0 Units',
                        icon: Icons.medication_outlined,
                        bgColor: Colors.teal,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        iconBgColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Consultations',
                        value: '$_consultationCount Done',
                        icon: Icons.calendar_month_outlined,
                        bgColor: Colors.orange,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        iconBgColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Quick Actions
                Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
                const SizedBox(height: 16),
                ActionCard(
                  title: 'Book Consultation',
                  subtitle: 'Talk to a doctor now',
                  icon: Icons.add_box_outlined,
                  isDark: true,
                  accentColor: AppColors.primaryTeal,
                  onTap: () => Navigator.pushNamed(context, '/consultation'),
                ),
                ActionCard(
                  title: 'View Prescriptions',
                  subtitle: 'Check your medicines',
                  icon: Icons.description_outlined,
                  isDark: true,
                  accentColor: AppColors.softBlue,
                  onTap: () => Navigator.pushNamed(context, '/prescriptions'),
                ),
                
                const SizedBox(height: 60),
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
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.person_outline, 'Profile', 1),
          _buildNavItem(Icons.settings_outlined, 'Settings', 2),
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

        if (index == 1) {
          // Open Profile as new page (Navigator.push)
          await Navigator.pushNamed(context, '/profile', arguments: 'patient');
        } else if (index == 2) {
          // Open Settings as new page (Navigator.push)
          await Navigator.pushNamed(context, '/settings');
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
                color: AppColors.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryTeal : AppColors.adaptiveTextSecondary(context), size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
