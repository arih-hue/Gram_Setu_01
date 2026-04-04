import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../core/user_provider.dart';
import '../services/location_service.dart';

class NewAshaRegistrationScreen extends StatefulWidget {
  const NewAshaRegistrationScreen({super.key});

  @override
  State<NewAshaRegistrationScreen> createState() => _NewAshaRegistrationScreenState();
}

class _NewAshaRegistrationScreenState extends State<NewAshaRegistrationScreen> {
  final _nameController = TextEditingController();
  final _ashaIdController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _village = '';
  String _block = '';
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ashaIdController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _fetchGPSLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final data = await LocationService.getCurrentLocationData();
      if (mounted) {
        _locationController.text = data['fullLocation']!;
        _village = data['village']!;
        _block = data['block']!;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location detected! 📍'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to fetch location. Please enter manually.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final ashaId = _ashaIdController.text.trim();
    final contact = _contactController.text.trim();
    final location = _locationController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || ashaId.isEmpty || contact.isEmpty || location.isEmpty || password.isEmpty || password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields correctly.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await AuthService.registerAsha(
        name: name,
        ashaId: ashaId,
        phone: contact,
        village: _village.isNotEmpty ? _village : location.split(',')[0].trim(),
        block: _block.isNotEmpty ? _block : (location.contains(',') ? location.split(',')[1].trim() : ''),
        fullLocation: location,
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
             content: SelectableText('ASHA Worker Account Created Successfully.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)),
             actions: [
               TextButton(
                 onPressed: () {
                   Navigator.of(context).pop();
                   Navigator.pushReplacementNamed(context, '/asha_worker', arguments: user);
                 },
                 child: const Text('OK', style: TextStyle(color: AppColors.ashaWorkerPink, fontSize: 16)),
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
        title: Text('ASHA Worker Registration', style: TextStyle(color: theme.textTheme.displayLarge?.color)),
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
              'Create ASHA Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your details and ASHA Registration ID to get started',
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),

            _buildLabel(theme, 'Full Name'),
            _buildTextField(controller: _nameController, hintText: 'Enter your full name', icon: Icons.person_outline),
            const SizedBox(height: 20),

            _buildLabel(theme, 'ASHA Registration ID'),
            _buildTextField(
              controller: _ashaIdController,
              hintText: 'Enter ASHA Registration ID',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 20),

            _buildLabel(theme, 'Contact Number'),
            _buildTextField(
              controller: _contactController,
              hintText: '10-digit Mobile Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),

            _buildLabel(
              theme, 
              'Location (Village / Block)',
              trailing: GestureDetector(
                onTap: _isFetchingLocation ? null : _fetchGPSLocation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isFetchingLocation)
                      const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ashaWorkerPink))
                    else
                      const Icon(Icons.gps_fixed, size: 16, color: AppColors.ashaWorkerPink),
                    const SizedBox(width: 4),
                    Text(
                      _isFetchingLocation ? 'Fetching...' : 'Fetch via GPS 📍',
                      style: const TextStyle(fontSize: 12, color: AppColors.ashaWorkerPink, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            _buildTextField(
              controller: _locationController,
              hintText: 'e.g. Rampur, Sitapur',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),
            
            _buildLabel(theme, 'Create Password'),
            _buildTextField(
              controller: _passwordController,
              hintText: 'Enter strong password',
              icon: Icons.lock_outline,
              isObscure: true,
            ),
            const SizedBox(height: 20),

            _buildLabel(theme, 'Confirm Password'),
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: 'Re-enter password',
              icon: Icons.lock_outline,
              isObscure: true,
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ashaWorkerPink,
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
      onChanged: (val) => setState(() {}),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.ashaWorkerPink),
        suffixIcon: icon == Icons.location_on_outlined && controller.text.isNotEmpty 
            ? const Icon(Icons.check_circle, color: AppColors.success, size: 20) 
            : null,
        counterText: '',
      ),
    );
  }
}
