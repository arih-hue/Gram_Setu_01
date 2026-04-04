import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/action_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

class PanchayatDashboard extends StatefulWidget {
  const PanchayatDashboard({super.key});

  @override
  State<PanchayatDashboard> createState() => _PanchayatDashboardState();
}

class _PanchayatDashboardState extends State<PanchayatDashboard> {
  int _currentIndex = 0;
  bool _isLoading = true;
  final Map<String, dynamic> _stats = {
    'totalPatients': 0,
    'activeCases': 0,
    'totalDoctors': 0,
    'totalAshaWorkers': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchSummaryStats();
  }

  Future<void> _fetchSummaryStats() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    
    final village = user['village'] ?? '';
    final block = user['block'] ?? '';
    
    try {
      final villageEncoded = Uri.encodeComponent(village);
      final blockEncoded = Uri.encodeComponent(block);
      final response = await ApiService.get('/stats/village?village=$villageEncoded&block=$blockEncoded');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _stats['totalPatients'] = data['totalPatients'] ?? 0;
            _stats['activeCases'] = data['activeCases'] ?? 0;
            _stats['totalDoctors'] = data['totalDoctors'] ?? 0;
            _stats['totalAshaWorkers'] = data['totalAshaWorkers'] ?? 0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Stats Fetch Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final userName = user?['name'] ?? 'Panchayat Representative';

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(
        roleLabel: 'Panchayat Dashboard',
        onLogoutTap: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchSummaryStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Namaste, $userName 🙏',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Panchayat Body • ID: ${user?['panchayatId'] ?? 'N/A'}', 
                      style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))
                    ),
                    Text(
                      '${user?['village'] ?? ''}${user?['village'] != null && user?['block'] != null ? ', ' : ''}${user?['block'] ?? ''}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Village Health Summary Cards
                const SectionHeader(title: 'Village Health Summary'),
                const SizedBox(height: 12),
                _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Patients', 
                        value: '${_stats['totalPatients']}', 
                        icon: Icons.people_outline, 
                        bgColor: AppColors.primaryTeal, 
                        textColor: Colors.white, 
                        iconColor: Colors.white, 
                        iconBgColor: Colors.white.withOpacity(0.2)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Active Cases', 
                        value: '${_stats['activeCases']}', 
                        icon: Icons.medical_services_outlined, 
                        bgColor: AppColors.emergencyRed, 
                        textColor: Colors.white, 
                        iconColor: Colors.white, 
                        iconBgColor: Colors.white.withOpacity(0.2)
                      ),
                    ),
                  ],
                ),
                if (!_isLoading) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Doctors',
                          value: '${_stats['totalDoctors']}',
                          icon: Icons.local_hospital_outlined,
                          bgColor: AppColors.doctorGreen,
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          iconBgColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'ASHAs',
                          value: '${_stats['totalAshaWorkers']}',
                          icon: Icons.volunteer_activism_outlined,
                          bgColor: AppColors.panchayatPurple,
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          iconBgColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),

                const SectionHeader(title: 'Administrative Controls'),
                ActionCard(
                  title: 'View Health Records',
                  subtitle: 'Enter Patient UID to retrieve historical data',
                  icon: Icons.history_edu_outlined,
                  isDark: true,
                  accentColor: AppColors.primaryTeal,
                  onTap: () => Navigator.pushNamed(context, '/search_patient'),
                ),
                ActionCard(
                  title: 'Village Statics',
                  subtitle: 'View overall village health analytics',
                  icon: Icons.analytics_outlined,
                  isDark: true,
                  accentColor: AppColors.softBlue,
                  onTap: () => Navigator.pushNamed(context, '/panchayat_records'),
                ),
                ActionCard(
                  title: 'View Prescriptions',
                  subtitle: 'Search & view patient prescription history',
                  icon: Icons.description_outlined,
                  isDark: true,
                  accentColor: AppColors.panchayatPurple,
                  onTap: () => Navigator.pushNamed(context, '/view_prescription_search'),
                ),
                const SizedBox(height: 80),
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
          _buildNavItem(Icons.manage_search_outlined, 'Search Patient', 1),
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

        if (index == 1) {
          await Navigator.pushNamed(context, '/search_patient');
        } else if (index == 2) {
          await Navigator.pushNamed(context, '/profile', arguments: 'panchayat');
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
