import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';

class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final _uidController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _patient;
  String _mode = 'book'; // 'book' or 'view'

  @override
  void dispose() {
    _uidController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _searchPatient() async {
    final uid = _uidController.text.trim();
    if (uid.length < 4) return;

    setState(() {
      _isLoading = true;
      _patient = null;
    });

    try {
      final response = await ApiService.get('/patient/uid/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _patient = data['patient'];
          _isLoading = false;
        });
        
        // If mode is 'view', immediately navigate to PrescriptionViewer
        if (_mode == 'view' && _patient != null) {
          Navigator.pushNamed(context, '/prescriptions', arguments: _patient!['uid']);
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient not found. Please check UID.'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _submitBooking(String bookedBy) async {
    if (_patient == null || _reasonController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.post('/consultation/create', {
        'patientName': _patient!['name'],
        'patientUID': _patient!['uid'],
        'patientAge': _patient!['age'] ?? 45, // Fallback if age not in User model yet
        'patientGender': _patient!['gender'] ?? 'Unknown',
        'reason': _reasonController.text.trim(),
        'bookedBy': bookedBy,
        'status': 'pending'
      });

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Consultation Booked Successfully!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _mode = args['mode'] ?? 'book';
    final String role = args['role'] ?? 'asha';

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(roleLabel: _mode == 'book' ? 'Book Consultation' : 'View Prescription', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Patient UID', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _uidController,
                    decoration: InputDecoration(
                      hintText: 'e.g. UID001234',
                      filled: true,
                      fillColor: AppColors.adaptiveSurface(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _searchPatient(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchPatient,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_patient != null && _mode == 'book') ...[
              const Text('Patient Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _infoRow('Name', _patient!['name']),
                    _infoRow('UID', _patient!['uid']),
                    _infoRow('Gender', _patient!['gender'] ?? 'N/A'),
                    _infoRow('Location', _patient!['location'] ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Reason for Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe the symptoms or problem...',
                  filled: true,
                  fillColor: AppColors.adaptiveSurface(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _submitBooking(role),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                  child: const Text('Confirm & Book Consultation'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.adaptiveTextSecondary(context), fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
