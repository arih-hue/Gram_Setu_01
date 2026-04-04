import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/action_card.dart';
import '../widgets/section_header.dart';
import 'asha_consultation_screen.dart';

class PanchayatDashboard extends StatefulWidget {
  const PanchayatDashboard({super.key});

  @override
  State<PanchayatDashboard> createState() => _PanchayatDashboardState();
}

class _PanchayatDashboardState extends State<PanchayatDashboard> {
  int _currentIndex = 0;
  Map<String, dynamic> _stats = {
    'totalPatients': 0,
    'activeCases': 0,
    'doctors': 0,
    'ashaWorkers': 0
  };
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVillageStats();
  }

  Future<void> _fetchVillageStats() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    
    final village = user?['village'] ?? '';
    final block = user?['block'] ?? '';
    
    try {
      final res = await ApiService.get('/stats/village?village=$village&block=$block');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _stats = data['stats'];
            _statsLoading = false;
          });
        }
      }
    } catch (e) {
      print('Village Stats Error: $e');
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(
        roleLabel: 'Panchayat Dashboard',
        onLogoutTap: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchVillageStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Village Snapshot 🏛️',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color),
              ),
              const SizedBox(height: 16),

              // Village health stats - 4 blocks
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _VillageStatBlock(label: 'Total Patients', value: _stats['totalPatients'].toString(), icon: Icons.people, color: Colors.blue, isLoading: _statsLoading),
                  _VillageStatBlock(label: 'Active Cases', value: _stats['activeCases'].toString(), icon: Icons.healing, color: Colors.orange, isLoading: _statsLoading),
                  _VillageStatBlock(label: 'Doctors', value: _stats['doctors'].toString(), icon: Icons.medical_services, color: AppColors.doctorGreen, isLoading: _statsLoading),
                  _VillageStatBlock(label: 'ASHA Workers', value: _stats['ashaWorkers'].toString(), icon: Icons.badge, color: AppColors.ashaWorkerPink, isLoading: _statsLoading),
                ],
              ),
              const SizedBox(height: 24),

              const SectionHeader(title: 'Administrative Actions'),
              ActionCard(
                title: 'Register New Patient',
                subtitle: 'Create health ID for a villager',
                icon: Icons.person_add_outlined,
                isDark: true,
                accentColor: AppColors.panchayatPurple,
                onTap: () => Navigator.pushNamed(context, '/add_patient'),
              ),
              ActionCard(
                title: 'View Health Records',
                subtitle: 'Search patient by UID to view prescriptions',
                icon: Icons.history_edu_outlined,
                isDark: true,
                accentColor: AppColors.softBlue,
                onTap: () => Navigator.pushNamed(context, '/search_patient'),
              ),
              ActionCard(
                title: 'Book Consultation',
                subtitle: 'Help villager connect with a doctor',
                icon: Icons.calendar_month_outlined,
                isDark: true,
                accentColor: AppColors.panchayatPurple,
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AshaConsultationScreen(bookedBy: 'panchayat'),
                    ),
                  );
                },
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
          await Navigator.pushNamed(context, '/profile', arguments: 'panchayat');
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
          color: isSelected ? AppColors.panchayatPurple.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.panchayatPurple : theme.textTheme.bodySmall?.color, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.panchayatPurple, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

class _VillageStatBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _VillageStatBlock({
    required this.label, 
    required this.value, 
    required this.icon, 
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color)),
              Text(label, style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
