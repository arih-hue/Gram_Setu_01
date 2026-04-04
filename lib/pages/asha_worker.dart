import 'dart:convert';
import 'package:flutter/material.dart';
import 'vitals_history_screen.dart';
import '../widgets/translated_text.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/action_card.dart';
import '../widgets/section_header.dart';

class AshaWorkerDashboard extends StatefulWidget {
  const AshaWorkerDashboard({super.key});

  @override
  State<AshaWorkerDashboard> createState() => _AshaWorkerDashboardState();
}

class _AshaWorkerDashboardState extends State<AshaWorkerDashboard> {
  int _currentIndex = 0;
  bool _isLoading = true;
  final Map<String, dynamic> _stats = {
    'villagePatients': 0,
    'bookedConsultations': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchAshaStats();
  }

  Future<void> _fetchAshaStats() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    
    final ashaId = user['ashaId']?.toString() ?? '';
    final rawVillage = user['location']?['village'] ?? user['village'] ?? '';
    
    final village = rawVillage is String ? rawVillage : '';

    try {
      final ashaIdEnc = Uri.encodeComponent(ashaId.trim());
      final villageEnc = Uri.encodeComponent(village.trim());
      final response = await ApiService.get('/stats/asha?ashaId=$ashaIdEnc&village=$villageEnc');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _stats['villagePatients'] = data['villagePatients'] ?? 0;
            _stats['bookedConsultations'] = data['bookedConsultations'] ?? 0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('ASHA Stats Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSearchVitalsDialog() {
    final TextEditingController uidCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslatedText('Search Patient Vitals'),
        content: TextField(
          controller: uidCtrl,
          decoration: const InputDecoration(hintText: 'Enter Patient UID'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TranslatedText('Cancel')),
          ElevatedButton(
            onPressed: () {
              final uid = uidCtrl.text.trim();
              if (uid.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => VitalsHistoryScreen(patientUID: uid)),
                );
              }
            },
            child: const TranslatedText('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final userName = user?['name'] ?? 'ASHA Worker';

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(
        roleLabel: 'ASHA Dashboard',
        onLogoutTap: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    'Village Service • ID: ${user?['ashaId'] ?? 'N/A'}', 
                    style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))
                  ),
                  Text(
                    '${user?['location']?['village'] ?? user?['village'] ?? ''}${ (user?['location']?['village'] ?? user?['village']) != null && (user?['location']?['block'] ?? user?['block']) != null ? ', ' : ''}${user?['location']?['block'] ?? user?['block'] ?? ''}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ASHA Stats Board
              _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Village Patients', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text('${_stats['villagePatients']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.ashaWorkerPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.ashaWorkerPink.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your Bookings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text('${_stats['bookedConsultations']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.ashaWorkerPink)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              const SectionHeader(title: 'Community Care'),
              ActionCard(
                title: 'Book Consultation',
                subtitle: 'Request a doctor session for a patient',
                icon: Icons.add_box_outlined,
                isDark: true,
                accentColor: AppColors.primaryTeal,
                onTap: () => Navigator.pushNamed(context, '/asha_consultation'),
              ),
              ActionCard(
                title: 'Add New Patient',
                subtitle: 'Register a village member into the system',
                icon: Icons.person_add_outlined,
                isDark: true,
                accentColor: AppColors.softBlue,
                onTap: () => Navigator.pushNamed(context, '/patient_registration', arguments: {'asWorker': true}),
              ),
              ActionCard(
                title: 'View Prescriptions',
                subtitle: 'Search & view patient prescription history',
                icon: Icons.description_outlined,
                isDark: true,
                accentColor: AppColors.panchayatPurple,
                onTap: () => Navigator.pushNamed(context, '/view_prescription_search'),
              ),
              ActionCard(
                title: 'Patient Vitals History',
                subtitle: 'Search vitals by Patient UID',
                icon: Icons.health_and_safety_outlined,
                isDark: true,
                accentColor: Colors.orange,
                onTap: _showSearchVitalsDialog,
              ),
              ActionCard(
                title: 'Manual Vitals Entry',
                subtitle: 'Record BP, Sugar, Temp, etc. for patient',
                icon: Icons.edit_note_outlined,
                isDark: true,
                accentColor: AppColors.primaryTeal,
                onTap: () => Navigator.pushNamed(context, '/vitals_recorder'),
              ),

              
              const SizedBox(height: 80),
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
          _buildNavItem(Icons.person_search_outlined, 'Search Patient', 1),
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
          await Navigator.pushNamed(context, '/profile', arguments: 'asha');
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
