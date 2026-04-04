import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';
import '../services/api_service.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _symptomsController = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
       return;
    }

    final String reason = _symptomsController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the symptoms')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post('/consultation/create', {
        'patientName': user['name'],
        'patientUID': user['uid'],
        'patientAge': user['age'] ?? 25,
        'patientGender': user['gender'] ?? 'Not specified',
        'reason': reason,
        'bookedBy': 'patient',
      });

      if (response.statusCode == 201) {
        setState(() {
          _submitted = true;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to submit: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Book Consultation', showBack: true, showSos: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _submitted ? _buildSubmittedView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    final user = Provider.of<UserProvider>(context).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Request Consultation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
        const SizedBox(height: 6),
        Text('Describe your symptoms and we will match you with an available doctor.', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
        const SizedBox(height: 24),

        // Patient info Card
        if (user != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.adaptiveSurface(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.adaptiveBorder(context))),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name'] ?? 'User', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                    Text('UID: ${user['uid'] ?? 'N/A'} • Age: ${user['age'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                  ],
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 20),

        // Symptoms
        Text('Describe Symptoms / Problem', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
        const SizedBox(height: 8),
        TextField(
          controller: _symptomsController,
          maxLines: 4,
          style: TextStyle(color: AppColors.adaptiveTextPrimary(context)),
          decoration: InputDecoration(
            hintText: 'E.g., Fever for 3 days, headache, body pain...',
            filled: true,
            fillColor: AppColors.adaptiveSurface(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.adaptiveBorder(context))),
          ),
        ),
        const SizedBox(height: 20),

        // Common symptoms quick select
        Text('Common Symptoms', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Fever', 'Headache', 'Cold/Cough', 'Body Pain', 'Stomach Pain', 'Dizziness', 'Skin Rash', 'Chest Pain'].map((s) {
            return ActionChip(
              label: Text(s, style: const TextStyle(fontSize: 12)),
              onPressed: () {
                final current = _symptomsController.text;
                _symptomsController.text = current.isEmpty ? s : '$current, $s';
              },
              backgroundColor: AppColors.adaptiveSurface(context),
              side: BorderSide(color: AppColors.adaptiveBorder(context)),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitRequest,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Submit Consultation Request', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittedView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
        ),
        const SizedBox(height: 24),
        Text('Consultation Requested!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
        const SizedBox(height: 8),
        Text('We are matching you with an available doctor.', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.adaptiveSurface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.adaptiveBorder(context)),
          ),
          child: Column(
            children: [
              _infoRow('Patient', Provider.of<UserProvider>(context).user?['name'] ?? 'N/A'),
              _infoRow('Status', 'Matching doctor...'),
              _infoRow('Est. Wait', '~15 minutes'),
            ],
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        )
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
        ],
      ),
    );
  }
}
