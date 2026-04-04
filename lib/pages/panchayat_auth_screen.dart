import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class PanchayatAuthScreen extends StatelessWidget {
  const PanchayatAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon/Logo Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.panchayatPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance,
                  size: 80,
                  color: AppColors.panchayatPurple,
                ),
              ),
              const SizedBox(height: 32),
              
              // Header
              Text(
                'Panchayat Office',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.displayLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Manage village health records and community consultations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const Spacer(),
              
              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login', arguments: 'panchayat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.panchayatPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Login to Office',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/panchayat_registration'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.panchayatPurple, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Register New ID',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.panchayatPurple),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Back Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Home',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
