import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _ageController = TextEditingController();
  final _villageController = TextEditingController();
  final _blockController = TextEditingController();
  final _mciController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _ashaIdController = TextEditingController();
  final _panchayatIdController = TextEditingController();
  final _pharmacistIdController = TextEditingController();
  String? _selectedGender;
  bool _isFetchingLocation = false;
  
  Map<String, dynamic>? _userData;
  bool _isInit = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Others'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _userData = args;
        Map<String, dynamic>? loc;
        if (_userData?['location'] is Map) {
          loc = Map<String, dynamic>.from(_userData?['location'] as Map);
        }
        
        String fullLoc = '';
        if (_userData?['location'] is String) {
          fullLoc = _userData?['location'] as String;
        } else if (loc != null) {
          fullLoc = loc['fullLocation'] ?? loc['village'] ?? '';
        }

        _nameController.text = _userData?['name'] ?? '';
        _contactController.text = _userData?['phone'] ?? '';
        _locationController.text = fullLoc;
        _emergencyContactController.text = _userData?['emergencyContact'] ?? '';
        _ageController.text = _userData?['age']?.toString() ?? '';
        _villageController.text = _userData?['village'] ?? loc?['village'] ?? '';
        _blockController.text = _userData?['block'] ?? loc?['block'] ?? '';
        _mciController.text = _userData?['mciNumber'] ?? '';
        _hospitalController.text = _userData?['hospitalName'] ?? '';
        _ashaIdController.text = _userData?['ashaId'] ?? '';
        _panchayatIdController.text = _userData?['panchayatId'] ?? '';
        _pharmacistIdController.text = _userData?['pharmacistId'] ?? '';
        _selectedGender = _userData?['gender'];
        if (!_genders.contains(_selectedGender)) {
           _selectedGender = null; // reset if invalid
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _emergencyContactController.dispose();
    _ageController.dispose();
    _villageController.dispose();
    _blockController.dispose();
    _mciController.dispose();
    _hospitalController.dispose();
    _ashaIdController.dispose();
    _panchayatIdController.dispose();
    _pharmacistIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchGPSLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final location = await LocationService.getCurrentLocation();
      if (mounted) {
        final role = _userData?['role'] ?? 'patient';
        if (role == 'patient') {
          _locationController.text = location;
        } else if (role == 'panchayat') {
          final parts = location.split(', ');
          if (parts.length >= 2) {
            _villageController.text = parts[0];
            _blockController.text = parts[1];
          } else {
            _villageController.text = location;
          }
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

  Future<void> _handleUpdate() async {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final role = _userData?['role'] ?? 'patient';

    if (name.isEmpty || contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Name and Contact Number.')),
      );
      return;
    }

    final hasIdentifier = _userData?['_id'] != null ||
        _userData?['uid'] != null ||
        _userData?['mciNumber'] != null ||
        _userData?['ashaId'] != null ||
        _userData?['panchayatId'] != null ||
        _userData?['pharmacistId'] != null;

    if (!hasIdentifier) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User ID is missing, cannot update')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        '_id': _userData?['_id'],
        'uid': _userData?['uid'],
        'mciNumber': _userData?['mciNumber'],
        'ashaId': _userData?['ashaId'],
        'panchayatId': _userData?['panchayatId'],
        'pharmacistId': _userData?['pharmacistId'],
        'name': name,
        'phone': contact,
      };

      // Role-specific fields in payload
      if (role == 'patient') {
        payload['location'] = {
           'fullLocation': _locationController.text.trim(),
           'village': _locationController.text.trim(), // simplified
        };
        payload['emergencyContact'] = _emergencyContactController.text.trim();
        payload['age'] = _ageController.text.trim();
        payload['gender'] = _selectedGender;
      }
      
      if (role == 'doctor') {
        payload['mciNumber'] = _mciController.text.trim();
        payload['hospitalName'] = _hospitalController.text.trim();
        payload['location'] = {
          'village': _villageController.text.trim(),
          'block': _blockController.text.trim()
        };
      }

      if (role == 'asha') {
        payload['ashaId'] = _ashaIdController.text.trim();
        payload['village'] = _villageController.text.trim();
        payload['block'] = _blockController.text.trim();
        payload['location'] = {
          'village': _villageController.text.trim(),
          'block': _blockController.text.trim()
        };
      }

      if (role == 'panchayat') {
        payload['panchayatId'] = _panchayatIdController.text.trim();
        payload['village'] = _villageController.text.trim();
        payload['block'] = _blockController.text.trim();
        payload['location'] = {
          'village': _villageController.text.trim(),
          'block': _blockController.text.trim()
        };
      }

      if (role == 'pharmacist') {
        payload['pharmacistId'] = _pharmacistIdController.text.trim();
        payload['village'] = _villageController.text.trim();
        payload['block'] = _blockController.text.trim();
        payload['location'] = {
          'village': _villageController.text.trim(),
          'block': _blockController.text.trim()
        };
      }

      final updatedData = await AuthService.updateProfile(payload);

      if (mounted && updatedData != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.doctorGreen)
        );
        Provider.of<UserProvider>(context, listen: false).setUser(updatedData);

        // Route to the correct dashboard based on role
        final String route;
        switch (role) {
          case 'doctor': route = '/doctor'; break;
          case 'asha': route = '/asha_worker'; break;
          case 'panchayat': route = '/panchayat'; break;
          case 'pharmacist': route = '/pharmacist'; break;
          default: route = '/patient'; break;
        }

        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route, arguments: updatedData);
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Profile Information', style: TextStyle(color: theme.textTheme.displayLarge?.color)),
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
              'Update Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Update your personal information saved in Gram Setu',
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),

            // Name Field (all roles)
            _buildLabel(theme, 'Full Name'),
            _buildTextField(controller: _nameController, hintText: 'Enter your full name', icon: Icons.person_outline),
            const SizedBox(height: 20),

            // Contact Number (all roles)
            _buildLabel(theme, 'Contact Number'),
            _buildTextField(
              controller: _contactController,
              hintText: '+91 XXXXX XXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Patient-only fields
            if ((_userData?['role'] ?? 'patient') == 'patient') ...[
              // Age Field
              _buildLabel(theme, 'Age'),
              _buildTextField(
                controller: _ageController,
                hintText: 'Enter age',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                maxLength: 3,
              ),
              const SizedBox(height: 4),

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
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                        )
                      else
                        const Icon(Icons.gps_fixed, size: 16, color: AppColors.primaryTeal),
                      const SizedBox(width: 4),
                      Text(
                        _isFetchingLocation ? 'Fetching...' : 'Fetch GPS',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryTeal,
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
                  border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
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
            ],

            // Doctor fields
            if ((_userData?['role'] ?? 'patient') == 'doctor') ...[
               _buildLabel(theme, 'MCI Registration Number'),
               _buildTextField(controller: _mciController, hintText: 'Enter MCI Number', icon: Icons.badge_outlined),
               const SizedBox(height: 20),
               _buildLabel(theme, 'Hospital Name'),
               _buildTextField(controller: _hospitalController, hintText: 'Enter Hospital Name', icon: Icons.apartment_outlined),
               const SizedBox(height: 20),
               _buildLabel(theme, 'Village'),
               _buildTextField(controller: _villageController, hintText: 'Enter Village', icon: Icons.home_outlined),
               const SizedBox(height: 20),
               _buildLabel(theme, 'Block'),
               _buildTextField(controller: _blockController, hintText: 'Enter Block', icon: Icons.map_outlined),
            ],

            // ASHA fields
            if ((_userData?['role'] ?? 'patient') == 'asha') ...[
               _buildLabel(theme, 'ASHA ID'),
               _buildTextField(controller: _ashaIdController, hintText: 'Enter ASHA ID', icon: Icons.badge_outlined),
               const SizedBox(height: 20),
               _buildLabel(theme, 'Assigned Village'),
               _buildTextField(controller: _villageController, hintText: 'Enter Village', icon: Icons.home_outlined),
               const SizedBox(height: 20),
               _buildLabel(theme, 'Assigned Block'),
               _buildTextField(controller: _blockController, hintText: 'Enter Block', icon: Icons.map_outlined),
            ],

            // Panchayat fields
            if ((_userData?['role'] ?? 'patient') == 'panchayat') ...[
              _buildLabel(theme, 'Panchayat ID'),
              _buildTextField(controller: _panchayatIdController, hintText: 'Enter Panchayat ID', icon: Icons.badge_outlined),
              const SizedBox(height: 20),
              _buildLabel(theme, 'Village'),
              _buildTextField(controller: _villageController, hintText: 'Enter Village', icon: Icons.home_outlined),
              const SizedBox(height: 20),
              _buildLabel(theme, 'Block'),
              _buildTextField(controller: _blockController, hintText: 'Enter Block', icon: Icons.map_outlined),
            ],

            // Pharmacist fields
            if ((_userData?['role'] ?? 'patient') == 'pharmacist') ...[
              _buildLabel(theme, 'Pharmacist ID'),
              _buildTextField(controller: _pharmacistIdController, hintText: 'Enter Pharmacist ID', icon: Icons.badge_outlined),
              const SizedBox(height: 20),
              _buildLabel(theme, 'Village'),
              _buildTextField(controller: _villageController, hintText: 'Enter Village', icon: Icons.home_outlined),
              const SizedBox(height: 20),
              _buildLabel(theme, 'Block'),
              _buildTextField(controller: _blockController, hintText: 'Enter Block', icon: Icons.map_outlined),
            ],
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _showDeleteConfirmation,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Delete Account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.adaptiveSurface(context),
        title: const Text('Delete Account?'),
        content: const Text('This action is permanent and cannot be undone. Are you sure you want to delete your profile?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: AppColors.error))
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _handleDelete();
    }
  }

  Future<void> _handleDelete() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final identifiers = {
        'uid': user['uid'],
        '_id': user['_id'],
        'mciNumber': user['mciNumber'],
        'ashaId': user['ashaId'],
        'panchayatId': user['panchayatId'],
        'pharmacistId': user['pharmacistId'],
      };
      
      final success = await AuthService.deleteProfile(identifiers);
      if (success && mounted) {
        Provider.of<UserProvider>(context, listen: false).clearUser();
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          ?trailing,
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primaryTeal),
        counterText: '',
      ),
    );
  }
}
