import 'package:flutter/material.dart';
import '../widgets/translated_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/constants.dart';
import '../core/theme_provider.dart';
import '../core/emergency_util.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Top Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText('Gram Setu',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.displayLarge?.color,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2),
                      const SizedBox(height: 8),
                      TranslatedText('Healthcare & Rural Network',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                    ],
                  ),
                  Row(
                    children: [
                      // Circular Theme Toggle Button
                      IconButton(
                        onPressed: () => themeProvider.toggleTheme(),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.cardTheme.color,
                          padding: const EdgeInsets.all(12),
                          shape: const CircleBorder(),
                        ),
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: themeProvider.isDarkMode
                              ? AppColors.accentYellow
                              : AppColors.primaryTeal,
                          size: 24,
                        ),
                      ).animate().scale(delay: 300.ms),
                      const SizedBox(width: 12),
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color, // Fixed: white to cardTheme.color
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          AppConstants.kLogoPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.health_and_safety,
                                color: AppColors.primaryTeal,
                                size: 32,
                              ),
                        ),
                      ).animate().scale(delay: 450.ms),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Roles Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildRoleCard(
                    context,
                    'Patient',
                    'Health & Consultations',
                    Icons.person,
                    AppColors.patientBlue,
                    'patient',
                  ),
                  _buildRoleCard(
                    context,
                    'ASHA Worker',
                    'Community Health',
                    Icons.favorite,
                    AppColors.ashaWorkerPink,
                    'asha',
                  ),
                  _buildRoleCard(
                    context,
                    'Doctor',
                    'Virtual Clinic',
                    Icons.medical_services,
                    AppColors.doctorGreen,
                    'doctor',
                  ),
                  _buildRoleCard(
                    context,
                    'Panchayat',
                    'Village Administration',
                    Icons.account_balance,
                    AppColors.panchayatPurple,
                    'panchayat',
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: GestureDetector(
            onTap: () => EmergencyUtil.callEmergency(context),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.emergencyGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergencyRed.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emergency_share, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      TranslatedText('EMERGENCY SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 20,
                    child: Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 16),
                  ),
                ],
              ),
            ),
          ),
        ).animate().slideY(begin: 1, duration: 800.ms, curve: Curves.easeOutQuart),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String role,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (role == 'panchayat') {
          Navigator.pushNamed(context, '/panchayat_auth');
        } else {
          Navigator.pushNamed(context, '/login', arguments: role);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textTheme.titleMedium?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
