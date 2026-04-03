import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/section_header.dart';
import 'package:provider/provider.dart';
import '../core/user_provider.dart';
import 'asha_consultation_screen.dart';
import 'view_prescription_search_screen.dart';

class PanchayatDashboard extends StatefulWidget {
  const PanchayatDashboard({super.key});

  @override
  State<PanchayatDashboard> createState() => _PanchayatDashboardState();
}

class _PanchayatDashboardState extends State<PanchayatDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final village = user?['village'] ?? user?['location']?.split(',')?.first?.trim() ?? 'Rampur';
    final block = user?['block'] ?? user?['location']?.split(',')?.last?.trim() ?? 'Bhopal';

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(
        roleLabel: 'Panchayat Dashboard',
        onLogoutTap: () {
          Provider.of<UserProvider>(context, listen: false).setUser({});
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Village Dashboard 🏛️',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context)),
            ),
            const SizedBox(height: 4),
            Text(
              'Village: $village • Block: $block',
              style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context)),
            ),
            const SizedBox(height: 20),

            // Village health stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.panchayatGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Village Health Summary', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _VillageStat(label: 'Registered', value: '342'),
                      _VillageStat(label: 'Active Cases', value: '12'),
                      _VillageStat(label: 'Emergencies', value: '2'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
             Row(
              children: [
                Expanded(child: StatCard(title: 'Consultations', value: '8', icon: Icons.medical_services_outlined, bgColor: AppColors.panchayatPurple, textColor: Colors.white, iconColor: Colors.white, iconBgColor: Colors.white.withValues(alpha: 0.2))),
                const SizedBox(width: 12),
                Expanded(child: StatCard(title: 'Critical Alerts', value: '2', icon: Icons.warning_amber_outlined, bgColor: AppColors.emergencyRed, textColor: Colors.white, iconColor: Colors.white, iconBgColor: Colors.white.withValues(alpha: 0.2))),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const SectionHeader(title: 'Patient Management'),
            ActionCard(
              title: 'Book Consultation',
              subtitle: 'Search UID and book doctor for patient',
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
            ActionCard(
              title: 'View Prescription',
              subtitle: 'Search patient UID and view medical records',
              icon: Icons.description_outlined,
              isDark: true,
              accentColor: AppColors.softBlue,
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewPrescriptionSearchScreen(themeColor: AppColors.panchayatPurple),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Admin Actions'),
            ActionCard(
              title: 'Register New Patient',
              subtitle: 'Create health ID for a villager',
              icon: Icons.person_add_outlined,
              isDark: true,
              accentColor: AppColors.panchayatPurple,
              onTap: () => _showPatientRegistration(context),
            ),
            ActionCard(
              title: 'Emergency Alert',
              subtitle: 'Send urgent alert to doctors',
              icon: Icons.emergency_outlined,
              isDark: true,
              accentColor: AppColors.emergencyRed,
              onTap: () => Navigator.pushNamed(context, '/emergency'),
            ),
            ActionCard(
              title: 'Health Campaigns',
              subtitle: 'Schedule awareness programs',
              icon: Icons.campaign_outlined,
              isDark: true,
              accentColor: AppColors.warning,
              onTap: () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.adaptiveBackground(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.adaptiveSurface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.person_add_outlined, Icons.person_add, 'Register'),
              _buildNavItem(2, Icons.medical_services_outlined, Icons.medical_services, 'Consult'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 4) Navigator.pushNamed(context, '/profile', arguments: 'panchayat');
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.panchayatPurple.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.panchayatPurple : AppColors.adaptiveTextSecondary(context), size: 24),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.panchayatPurple, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }

  void _showPatientRegistration(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: const BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.all(Radius.circular(2)))),
            ),
            const SizedBox(height: 20),
            Text('Register New Patient', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
            const SizedBox(height: 6),
            Text('A unique Health UID will be generated', style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextSecondary(context))),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(hintText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Age', prefixIcon: Icon(Icons.cake_outlined)))),
                SizedBox(width: 12),
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Gender', prefixIcon: Icon(Icons.wc_outlined)))),
              ],
            ),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(hintText: 'Village', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(hintText: 'Phone (optional)', prefixIcon: Icon(Icons.phone_outlined)), keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient registered! UID: UID007892'), backgroundColor: AppColors.success),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.panchayatPurple),
                child: const Text('Register & Generate UID', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _VillageStat extends StatelessWidget {
  final String label;
  final String value;
  const _VillageStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }
}
