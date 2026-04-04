import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/section_header.dart';
import 'asha_consultation_screen.dart';

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
    
    String villageText = 'Local';
    if (user != null && user['location'] != null) {
      if (user['location'] is Map) {
        villageText = user['location']['village'] ?? 'Local';
      } else {
        villageText = user['location']?.split(',')?.first?.trim() ?? 'Local';
      }
    }
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(
        roleLabel: 'ASHA Worker Dashboard',
        onLogoutTap: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Namaste, ${name.split(' ').first} 🙏',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color),
              ),
              const SizedBox(height: 4),
              Text('Village: $villageText • ASHA ID: ${user?['ashaId'] ?? 'N/A'}', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
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
                      title: 'Home Visits',
                      value: '12',
                      icon: Icons.home_outlined,
                      bgColor: AppColors.primaryTeal,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      iconBgColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const SectionHeader(title: 'Patient Management'),
              ActionCard(
                title: 'Book Consultation',
                subtitle: 'Register symptoms and book doctor for patient',
                icon: Icons.calendar_month_outlined,
                isDark: true,
                accentColor: AppColors.ashaWorkerPink,
                onTap: () async {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AshaConsultationScreen(bookedBy: 'asha'),
                    ),
                  );
                },
              ),
              ActionCard(
                title: 'Search Patient',
                subtitle: 'Find patient by UID to view complete profile',
                icon: Icons.person_search_outlined,
                isDark: true,
                accentColor: AppColors.primaryTeal,
                onTap: () => Navigator.pushNamed(context, '/search_patient'),
              ),
              ActionCard(
                title: 'View Health Records',
                subtitle: 'Check history and standardized prescriptions',
                icon: Icons.history_edu_outlined,
                isDark: true,
                accentColor: AppColors.softBlue,
                onTap: () => Navigator.pushNamed(context, '/search_patient'),
              ),
              ActionCard(
                title: 'Add New Patient',
                subtitle: 'Register a new villager with health ID',
                icon: Icons.person_add_outlined,
                isDark: true,
                accentColor: AppColors.ashaWorkerPink,
                onTap: () => Navigator.pushNamed(context, '/add_patient'),
              ),
              const SizedBox(height: 60),
            ],
          ),
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
              _buildNavItem(1, Icons.search, Icons.search, 'Search'),
              _buildNavItem(2, Icons.person_outline, Icons.person, 'Profile'),
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
          await Navigator.pushNamed(context, '/search_patient');
        } else if (index == 2) {
          await Navigator.pushNamed(context, '/profile', arguments: 'asha');
        }
        
        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ashaWorkerPink.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.ashaWorkerPink : theme.textTheme.bodySmall?.color, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.ashaWorkerPink, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
