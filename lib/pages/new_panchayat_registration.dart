import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../core/user_provider.dart';
import '../services/location_service.dart';

class NewPanchayatRegistrationScreen extends StatefulWidget {
  const NewPanchayatRegistrationScreen({super.key});

  @override
  State<NewPanchayatRegistrationScreen> createState() => _NewPanchayatRegistrationScreenState();
}

class _NewPanchayatRegistrationScreenState extends State<NewPanchayatRegistrationScreen> {
  final _panchayatIdController = TextEditingController();
  final _villageController = TextEditingController();
  final _blockController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _panchayatIdController.dispose();
    _villageController.dispose();
    _blockController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchGPSLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final location = await LocationService.getCurrentLocation();
      if (mounted) {
        final parts = location.split(', ');
        if (parts.length >= 2) {
          _villageController.text = parts[0];
          _blockController.text = parts[1];
        } else {
          _villageController.text = location;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final panchayatId = _panchayatIdController.text.trim();
    final village = _villageController.text.trim();
    final block = _blockController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (panchayatId.isEmpty ||
        village.isEmpty ||
        block.isEmpty ||
        password.isEmpty ||
        password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly, and ensure passwords match.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.registerPanchayat(
        name: 'Panchayat Member', // Default name as user didn't request a name field
        panchayatId: panchayatId,
        phone: '', 
        village: village,
        block: block,
        position: 'Member', 
        password: password,
      );

      if (mounted) {
        if (user != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);
        }
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
             backgroundColor: Theme.of(context).cardTheme.color,
             title: Text('Registration Successful', style: TextStyle(color: Theme.of(context).textTheme.displayLarge?.color)),
             content: SelectableText('Panchayat Account Created Successfully.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)),
             actions: [
               TextButton(
                 onPressed: () {
                   Navigator.of(context).pop();
                   Navigator.pushReplacementNamed(context, '/panchayat', arguments: user);
                 },
                 child: const Text('OK', style: TextStyle(color: AppColors.panchayatPurple, fontSize: 16)),
               )
             ],
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Panchayat Registration', style: TextStyle(color: theme.textTheme.displayLarge?.color)),
        backgroundColor: theme.cardTheme.color,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join Panchayat Network',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your official details to monitor village health',
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),

            // Panchayat ID Field
            _buildLabel(theme, 'Panchayat ID'),
            _buildTextField(
              controller: _panchayatIdController,
              hintText: 'Enter official ID',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 20),

            // Village Field
            _buildLabel(
              theme,
              'Village',
              trailing: GestureDetector(
                onTap: _isFetchingLocation ? null : _fetchGPSLocation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isFetchingLocation)
                      const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.panchayatPurple),
                      )
                    else
                      const Icon(Icons.gps_fixed, size: 16, color: AppColors.panchayatPurple),
                    const SizedBox(width: 4),
                    Text(
                      _isFetchingLocation ? 'Fetching...' : 'Fetch GPS',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.panchayatPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildTextField(
              controller: _villageController,
              hintText: 'Enter Village name',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),

            // Block Field
            _buildLabel(theme, 'Block / District'),
            _buildTextField(
              controller: _blockController,
              hintText: 'Enter block name',
              icon: Icons.map_outlined,
            ),
            const SizedBox(height: 32),
            
            // Password Field
            _buildLabel(theme, 'Create Password'),
            _buildTextField(
              controller: _passwordController,
              hintText: 'Enter strong password',
              icon: Icons.lock_outline,
              isObscure: true,
            ),
            const SizedBox(height: 20),

            // Confirm Password Field
            _buildLabel(theme, 'Confirm Password'),
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: 'Re-enter password',
              icon: Icons.lock_outline,
              isObscure: true,
            ),
            const SizedBox(height: 40),

            // Register Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.panchayatPurple,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Complete Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Login Link
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login', arguments: 'panchayat'),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(color: AppColors.panchayatPurple, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isObscure = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isObscure,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.panchayatPurple),
        counterText: '',
      ),
    );
  }
}
