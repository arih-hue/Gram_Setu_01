import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';
import '../services/location_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _addressController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  String _gender = 'Male';
  bool _isSubmitted = false;
  bool _isLoading = false;
  bool _isFetchingLocation = false;
  String _generatedUid = '';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _fetchGPSLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final location = await LocationService.getCurrentLocation();
      if (mounted) {
        _villageController.text = location;
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    final uid = 'UID${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    setState(() {
      _isLoading = false;
      _isSubmitted = true;
      _generatedUid = uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GramAppBar(roleLabel: 'Add New Patient', showBack: true, showSos: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isSubmitted ? _buildSuccessView(theme) : _buildFormView(theme),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Register New Patient', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color)),
          const SizedBox(height: 6),
          Text('Fill in patient details to create a health ID.', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
          const SizedBox(height: 24),

          _buildLabel(theme, 'Full Name *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Enter patient full name', prefixIcon: Icon(Icons.person_outline)),
            validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(theme, 'Age *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Age', prefixIcon: Icon(Icons.calendar_today_outlined)),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(theme, 'Gender *'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _gender,
                          isExpanded: true,
                          dropdownColor: theme.cardTheme.color,
                          items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildLabel(theme, 'Phone Number *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+91 XXXXX XXXXX', prefixIcon: Icon(Icons.phone_outlined)),
            validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null,
          ),
          const SizedBox(height: 16),

          _buildLabel(
            theme,
            'Village *',
            trailing: GestureDetector(
              onTap: _isFetchingLocation ? null : _fetchGPSLocation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFetchingLocation)
                    const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ashaWorkerPink),
                    )
                  else
                    const Icon(Icons.gps_fixed, size: 16, color: AppColors.ashaWorkerPink),
                  const SizedBox(width: 4),
                  Text(
                    _isFetchingLocation ? 'Fetching...' : 'Fetch GPS',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ashaWorkerPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _villageController,
            decoration: const InputDecoration(hintText: 'Enter village name', prefixIcon: Icon(Icons.location_on_outlined)),
            validator: (v) => v == null || v.isEmpty ? 'Village is required' : null,
          ),
          const SizedBox(height: 16),

          _buildLabel(theme, 'Address'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'House number, ward, etc.', prefixIcon: Icon(Icons.home_outlined)),
          ),
          const SizedBox(height: 16),

          _buildLabel(theme, 'Known Health Conditions'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _conditionsController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'E.g., Diabetes, Hypertension...', prefixIcon: Icon(Icons.medical_information_outlined)),
          ),
          const SizedBox(height: 16),

          _buildLabel(theme, 'Allergies'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _allergiesController,
            decoration: const InputDecoration(hintText: 'E.g., Penicillin, Dust...', prefixIcon: Icon(Icons.warning_amber)),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.ashaWorkerPink),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Register Patient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        ),
        const SizedBox(height: 24),
        Text('Patient Registered!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color)),
        const SizedBox(height: 8),
        Text('A new Health UID has been generated.', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _infoRow(theme, 'Name', _nameController.text),
              _infoRow(theme, 'Age / Gender', '${_ageController.text} / $_gender'),
              _infoRow(theme, 'Phone', _phoneController.text),
              _infoRow(theme, 'Village', _villageController.text),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Health UID: ', style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _generatedUid,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryTeal, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isSubmitted = false;
                    _nameController.clear();
                    _ageController.clear();
                    _phoneController.clear();
                    _villageController.clear();
                    _addressController.clear();
                    _conditionsController.clear();
                    _allergiesController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.ashaWorkerPink),
                ),
                child: const Text('Add Another'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ashaWorkerPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(ThemeData theme, String text, {Widget? trailing}) {
    return Row(
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
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color)),
        ],
      ),
    );
  }
}
