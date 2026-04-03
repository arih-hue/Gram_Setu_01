import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';

class AshaConsultationScreen extends StatefulWidget {
  final String bookedBy; // 'asha' or 'panchayat'
  const AshaConsultationScreen({super.key, this.bookedBy = 'asha'});

  @override
  State<AshaConsultationScreen> createState() => _AshaConsultationScreenState();
}

class _AshaConsultationScreenState extends State<AshaConsultationScreen> {
  final _uidController = TextEditingController();
  final _reasonController = TextEditingController();
  
  bool _isLoading = false;
  bool _patientFound = false;
  Map<String, dynamic>? _patientData;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _uidController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _lookupPatient() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a Patient UID')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/patient/uid/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _patientFound = true;
          _patientData = data['user'];
        });
      } else {
        if (!mounted) return;
        setState(() => _patientFound = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient not found')));

      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));

    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitConsultation() async {
    if (_patientData == null) return;
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a reason')));
      return;
    }

    setState(() => _isLoading = true);
    final body = {
      'patientName': _patientData!['name'],
      'patientUID': _patientData!['uid'],
      'patientAge': _patientData!['age'] ?? 30, // Fallback if age not in User model yet
      'patientGender': _patientData!['gender'] ?? 'Not specified',
      'reason': _reasonController.text.trim(),
      'bookedBy': widget.bookedBy,
    };

    try {
      final response = await ApiService.post('/consultation/create', body);
      if (response.statusCode == 201) {
        if (!mounted) return;
        setState(() {
          _isSubmitted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation booked successfully!')));

      } else {
        throw Exception('Failed to book');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));

    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.bookedBy == 'asha' ? AppColors.ashaWorkerPink : AppColors.panchayatPurple;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(roleLabel: 'Book Consultation', showBack: true, showSos: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isSubmitted 
          ? _buildSuccessView(theme, accentColor) 
          : _buildFormView(theme, accentColor),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Book Consultation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color)),
        const SizedBox(height: 6),
        Text('Search for a patient by UID and book a consultation.', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 24),

        TextField(
          controller: _uidController,
          decoration: InputDecoration(
            hintText: 'Enter Patient UID',
            prefixIcon: Icon(Icons.badge_outlined, color: accentColor),
            suffixIcon: IconButton(
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
              onPressed: _isLoading ? null : _lookupPatient,
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_patientFound && _patientData != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                _patientInfoRow('Name', _patientData!['name']),
                _patientInfoRow('UID', _patientData!['uid']),
                _patientInfoRow('Gender', _patientData!['gender'] ?? 'N/A'),
                _patientInfoRow('Age', '${_patientData!['age'] ?? 'N/A'}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Reason for Consultation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'E.g. Fever and body pain...'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitConsultation,
              style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _patientInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme, Color accentColor) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.check_circle, size: 80, color: AppColors.success),
          const SizedBox(height: 20),
          const Text('Request Submitted!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Consultation has been booked by ${widget.bookedBy}.', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
            child: const Text('Return to Dashboard'),
          ),
        ],
      ),
    );
  }
}
