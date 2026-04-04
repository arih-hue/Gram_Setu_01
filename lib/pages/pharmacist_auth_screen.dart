import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../services/auth_service.dart';
import '../widgets/translated_text.dart';

class PharmacistAuthScreen extends StatefulWidget {
  const PharmacistAuthScreen({super.key});

  @override
  State<PharmacistAuthScreen> createState() => _PharmacistAuthScreenState();
}

class _PharmacistAuthScreenState extends State<PharmacistAuthScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _idController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TranslatedText('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService.loginWithPassword(
        identifier: identifier,
        password: password,
        role: 'pharmacist',
      );

      if (mounted && user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.pushReplacementNamed(context, '/pharmacist');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: AppBar(
        title: const TranslatedText('Pharmacist Login'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.adaptiveTextPrimary(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication, size: 80, color: AppColors.primaryTeal),
            ),
            const SizedBox(height: 32),
            const TranslatedText(
              'Welcome Back Pharmacist',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const TranslatedText(
              'Manage your pharmacy inventory easily',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Pharmacist ID',
                prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primaryTeal),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryTeal),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const TranslatedText('Secure Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TranslatedText("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/pharmacist_registration'),
                  child: const Text(
                    'Register Now',
                    style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
