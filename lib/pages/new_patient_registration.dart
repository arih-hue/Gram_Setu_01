import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../core/user_provider.dart';
import '../services/location_service.dart';

class NewPatientRegistrationScreen extends StatefulWidget {
  const NewPatientRegistrationScreen({super.key});

  @override
  State<NewPatientRegistrationScreen> createState() => _NewPatientRegistrationScreenState();
}

class _NewPatientRegistrationScreenState extends State<NewPatientRegistrationScreen> {
  final _nameController = TextEditingController();
  final _aadharController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  String _village = '';
  String _block = '';
  final _emergencyContactController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;
  bool _isFetchingLocation = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Others'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _aadharController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _emergencyContactController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
          SnackBar(content: Text('Unable to fetch location. Please enter manually.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final aadhar = _aadharController.text.trim();
    final contact = _contactController.text.trim();
    final location = _locationController.text.trim();
    final emergencyContact = _emergencyContactController.text.trim();
    final age = _ageController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final gender = _selectedGender;

    if (name.isEmpty ||
        aadhar.length != 12 ||
        contact.isEmpty ||
        location.isEmpty ||
        emergencyContact.isEmpty ||
        age.isEmpty ||
        password.isEmpty ||
        password != confirmPassword ||
        gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly, and ensure passwords match.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final random = Random();
      final newUid = 'PAT-${random.nextInt(999999).toString().padLeft(6, '0')}';
      
      final userData = await AuthService.registerPatient(
        name: name,
        uid: newUid,
        phone: contact,
        village: _village.isNotEmpty ? _village : location.split(',')[0].trim(),
        block: _block.isNotEmpty ? _block : (location.contains(',') ? location.split(',')[1].trim() : ''),
        fullLocation: location,
        gender: gender,
        age: age,
        emergencyContact: emergencyContact,
        password: password,
      );

      if (mounted) {
        if (userData != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(userData);
        }
        // Show dialog with generated UID instead of just redirecting silently
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
             backgroundColor: Theme.of(context).cardTheme.color,
             title: Text('Registration Successful', style: TextStyle(color: Theme.of(context).textTheme.displayLarge?.color)),
             content: SelectableText('Patient generated UID is:\n$newUid\n\nPlease safe keep this for your records.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)),
             actions: [
               TextButton(
                 onPressed: () {
                   Navigator.of(context).pop();
                   Navigator.pushReplacementNamed(context, '/patient', arguments: userData);
                 },
                 child: const Text('OK', style: TextStyle(color: AppColors.patientBlue, fontSize: 16)),
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
        title: Text('New Patient Registration', style: TextStyle(color: theme.textTheme.displayLarge?.color)),
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
              'Create Health ID',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your details to generate your unique Health UID',
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),

            // Name Field
            _buildLabel(theme, 'Full Name'),
            _buildTextField(controller: _nameController, hintText: 'Enter your full name', icon: Icons.person_outline),
            const SizedBox(height: 20),

            // Age Field
            _buildLabel(theme, 'Age'),
            _buildTextField(
              controller: _ageController,
              hintText: 'Enter age',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              maxLength: 3,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 4),

            // Aadhar Number Field
            _buildLabel(theme, 'Aadhar Number'),
            _buildTextField(
              controller: _aadharController,
              hintText: '12-digit Aadhar Number',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              maxLength: 12,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 4),

            // Contact Field
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

            // Emergency Contact Field
            _buildLabel(theme, 'Emergency Contact Name & Number'),
            _buildTextField(
              controller: _emergencyContactController,
              hintText: 'e.g., John Doe 9876543210',
              icon: Icons.contact_emergency_outlined,
            ),
            const SizedBox(height: 20),

            // Location Field
            _buildLabel(
              theme,
              'Location (Village / Block)',
              trailing: GestureDetector(
                onTap: _isFetchingLocation ? null : _fetchGPSLocation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isFetchingLocation)
                      const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.patientBlue),
                      )
                    else
                      const Icon(Icons.gps_fixed, size: 16, color: AppColors.patientBlue),
                    const SizedBox(width: 4),
                    Text(
                      _isFetchingLocation ? 'Fetching...' : 'Fetch GPS',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.patientBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildTextField(
              controller: _locationController,
              hintText: 'Enter your village or location',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),

            // Gender Dropdown
            _buildLabel(theme, 'Gender'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                color: theme.cardTheme.color,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  hint: Text('Select Gender', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  isExpanded: true,
                  dropdownColor: theme.cardTheme.color,
                  icon: Icon(Icons.keyboard_arrow_down, color: theme.iconTheme.color),
                  items: _genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender, style: TextStyle(color: theme.textTheme.displayLarge?.color)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Password Field
            _buildLabel(theme, 'Password'),
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
                  backgroundColor: AppColors.patientBlue,
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
    int? maxLength,
    bool isObscure = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: isObscure,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.patientBlue),
        suffixIcon: icon == Icons.location_on_outlined && controller.text.isNotEmpty 
            ? const Icon(Icons.check_circle, color: AppColors.success, size: 20) 
            : null,
        counterText: '',
      ),
    );
  }
}
