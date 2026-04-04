import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../core/app_colors.dart';

import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';
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
  void initState() {
    super.initState();
  }

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
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${userName.split(' ').first} 👋',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color),
                      ),
                      const SizedBox(height: 4),
                      Text('How are you feeling today?', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
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
                        Text(uid, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Section
              const SectionHeader(title: 'Patient Portal'),
              ActionCard(
                title: 'Book Instant Consultation',
                subtitle: 'Request a session with a doctor now',
                icon: Icons.medical_services_outlined,
                isDark: true,
                accentColor: AppColors.primaryTeal,
                onTap: () => Navigator.pushNamed(context, '/consultation'),
              ),
              ActionCard(
                title: 'Medical History & Profile',
                subtitle: 'View your prescriptions and patient details',
                icon: Icons.account_circle_outlined,
                isDark: true,
                accentColor: AppColors.softBlue,
                onTap: () => Navigator.pushNamed(context, '/profile', arguments: 'patient'),
              ),
              const SizedBox(height: 40),
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
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      onTap: () async {
        if (index == 0) {
          setState(() => _currentIndex = index);
          return;
        }
        
        if (index == 1) {
          await Navigator.pushNamed(context, '/profile', arguments: 'patient');
        }
        
        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primaryTeal : theme.textTheme.bodySmall?.color, size: 24),
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
