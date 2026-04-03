
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';
import '../core/constants.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    
    // As requested, always route to role selection (/home) when opening
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                AppConstants.kLogoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.health_and_safety, color: AppColors.primaryTeal, size: 60),
              ),
            ).animate()
             .fadeIn(duration: 800.ms)
             .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
             .shimmer(delay: 1.seconds, duration: 1.5.seconds, color: Colors.white30),
            
            const SizedBox(height: 32),
            
            Text(
              'Gram Setu',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.adaptiveTextPrimary(context),
              ),
            ).animate()
             .fadeIn(delay: 500.ms, duration: 800.ms)
             .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
            
            const SizedBox(height: 8),
            
            Text(
              'Swasthya Seva Aapke Dwar',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 4,
                color: AppColors.adaptiveTextSecondary(context),
                fontWeight: FontWeight.w300,
              ),
            ).animate()
             .fadeIn(delay: 1.seconds, duration: 800.ms),
            
            const SizedBox(height: 60),
            
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              ),
            ).animate().fadeIn(delay: 1.5.seconds),
          ],
        ),
      ),
    );
  }
}
