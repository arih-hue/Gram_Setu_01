import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';
import '../widgets/translated_text.dart';
import '../widgets/gram_app_bar.dart';

class PharmacyGateScreen extends StatelessWidget {
  const PharmacyGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GramAppBar(
        roleLabel: 'Pharmacy Portal',
        showBack: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const TranslatedText(
                'Welcome to Pharmacy',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideX(begin: -0.2),
              const SizedBox(height: 8),
              const TranslatedText(
                'Select an option below to proceed',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
              const SizedBox(height: 48),
              
              _buildOptionCard(
                context,
                'Pharmacist',
                'Manage your store and inventory',
                Icons.admin_panel_settings,
                AppColors.primaryTeal,
                () => Navigator.pushNamed(context, '/pharmacist_auth'),
              ),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                'Buy Medicines',
                'Browse and shop medicines from local chemists',
                Icons.shopping_bag_outlined,
                AppColors.softBlue,
                () => Navigator.pushNamed(context, '/browse_medicines'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TranslatedText(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}
