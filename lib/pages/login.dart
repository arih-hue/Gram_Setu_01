import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../core/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _uidController = TextEditingController();
  final _passwordController = TextEditingController();

  String _role = 'patient';
  String get _roleLabel {
    switch (_role) {
      case 'doctor':
        return 'Doctor / Medical Professional';
      case 'asha':
        return 'ASHA Worker';
      case 'panchayat':
        return 'Panchayat Member';
      default:
        return 'Patient / Villager';
    }
  }

  Color get _roleColor {
    switch (_role) {
      case 'doctor':
        return AppColors.doctorGreen;
      case 'asha':
        return AppColors.ashaWorkerPink;
      case 'panchayat':
        return AppColors.panchayatPurple;
      default:
        return AppColors.patientBlue;
    }
  }

  String get _dashboardRoute {
    switch (_role) {
      case 'doctor':
        return '/doctor';
      case 'asha':
        return '/asha_worker';
      case 'panchayat':
        return '/panchayat';
      default:
        return '/patient';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _role = args;
    }
  }

  @override
  void dispose() {
    _uidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final identifier = _uidController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      String idLabel = 'Health UID';
      if (_role == 'doctor') idLabel = 'MCI ID';
      if (_role == 'asha') idLabel = 'ASHA ID';
      if (_role == 'panchayat') idLabel = 'Panchayat ID';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter $idLabel and Password')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final userData = await AuthService.loginWithPassword(
        identifier: identifier,
        password: password,
      );
      if (mounted && userData != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(userData);
        Navigator.pushReplacementNamed(context, _dashboardRoute, arguments: userData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String idLabel = 'Registration ID';
    String idHint = 'Enter your ID';
    if (_role == 'doctor') {
      idLabel = 'MCI Number';
      idHint = 'Enter your MCI registration number';
    } else if (_role == 'asha') {
      idLabel = 'ASHA ID';
      idHint = 'Enter your 8-digit ASHA ID';
    } else if (_role == 'panchayat') {
      idLabel = 'Panchayat ID';
      idHint = 'Enter your Panchayat Office ID';
    } else if (_role == 'patient') {
      idLabel = 'Patient UID / Phone';
      idHint = 'Enter health ID or mobile number';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: theme.textTheme.displayLarge?.color),
                style: IconButton.styleFrom(
                  backgroundColor: theme.cardTheme.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Logo placement
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => 
                      Icon(Icons.health_and_safety, size: 80, color: AppColors.primaryTeal),
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 24),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _roleLabel,
                  style: TextStyle(
                    color: _roleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ).animate().fadeIn().slideX(begin: -0.1),

              const SizedBox(height: 20),

              // Welcome text
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.displayLarge?.color,
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 8),
              Text(
                'Enter your details to continue to your dashboard',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 36),

              // UID Field
              Text(
                idLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _uidController,
                decoration: InputDecoration(
                  hintText: idHint,
                  prefixIcon: Icon(Icons.badge_outlined, color: _roleColor),
                ),
              ),

              const SizedBox(height: 20),

              // Password Field
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock_outline, color: _roleColor),
                ),
              ),

              const SizedBox(height: 32),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roleColor,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Register text button
              if (_role == 'patient' || _role == 'doctor' || _role == 'asha')
                Center(
                  child: TextButton(
                    onPressed: () {
                      if (_role == 'doctor') {
                        Navigator.pushNamed(context, '/doctor_registration');
                      } else if (_role == 'asha') {
                        Navigator.pushNamed(context, '/asha_registration');
                      } else if (_role == 'panchayat') {
                        Navigator.pushNamed(context, '/panchayat_registration');
                      } else {
                        Navigator.pushNamed(context, '/patient_registration');
                      }
                    },
                    child: Text(
                      _role == 'doctor' ? 'New Doctor? Register Here' : 
                      _role == 'asha' ? 'New ASHA Worker? Register Here' :
                      _role == 'panchayat' ? 'New Panchayat Member? Register Here' :
                      'New Patient? Register Here',
                      style: TextStyle(
                        color: _roleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Guest access for emergencies
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/emergency'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.emergencyRed),
                    foregroundColor: AppColors.emergencyRed,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Emergency? Continue Without Login'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Skip login (demo)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, _dashboardRoute);
                  },
                  child: Text(
                    'Skip Login (Demo Mode)',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}