import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
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
  bool _showConsultationForm = false;
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

    setState(() {
      _isLoading = true;
      _showConsultationForm = false;
    });
    try {
      final response = await ApiService.get('/patient/uid/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _patientFound = true;
          _patientData = data['user'];
        });
      } else {
        setState(() {
          _patientFound = false;
          _patientData = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient not found')));
        }

      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error lookup: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitConsultation() async {
    if (_patientData == null) return;
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter symptoms/reason')));
      return;
    }

    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookedById = userProvider.user?['_id'] ?? userProvider.user?['uid'];

    final body = {
      'patientName': _patientData!['name'],
      'patientUID': _patientData!['uid'],
      'patientAge': _patientData!['age'] ?? '30',
      'patientGender': _patientData!['gender'] ?? 'Others',
      'reason': _reasonController.text.trim(),
      'bookedBy': widget.bookedBy,
      'bookedById': bookedById,
    };

    try {
      final response = await ApiService.post('/consultation/create', body);
      if (response.statusCode == 201) {
        setState(() => _isSubmitted = true);
      } else {
        throw Exception('Failed to book consultation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error booking: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.bookedBy == 'asha' ? AppColors.ashaWorkerPink : AppColors.panchayatPurple;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(roleLabel: 'Consultation Booking', showBack: true, showSos: false),
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
        Text('Book New Consultation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color)),
        const SizedBox(height: 6),
        Text('Connect a villager with a doctor by searching their UID.', style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 24),

        TextField(
          controller: _uidController,
          decoration: InputDecoration(
            hintText: 'Enter Patient UID (e.g. PAT-123456)',
            prefixIcon: Icon(Icons.badge_outlined, color: accentColor),
            suffixIcon: IconButton(
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
              onPressed: _isLoading ? null : _lookupPatient,
            ),
          ),
          onSubmitted: (_) => _lookupPatient(),
        ),
        const SizedBox(height: 16),

        if (_patientFound && _patientData != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.1)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            ),
            child: Column(
              children: [
                _patientInfoRow(theme, 'Patient Name', _patientData!['name']),
                _patientInfoRow(theme, 'UID Number', _patientData!['uid']),
                _patientInfoRow(theme, 'Gender', _patientData!['gender'] ?? 'N/A'),
                _patientInfoRow(theme, 'Age', '${_patientData!['age'] ?? 'N/A'} years'),
                const Divider(height: 24),
                if (!_showConsultationForm)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showConsultationForm = true),
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
                      child: const Text('Start New Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                else ...[
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text('Symptoms / Reason for Visit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                       const SizedBox(height: 10),
                       TextField(
                         controller: _reasonController,
                         maxLines: 4,
                         decoration: InputDecoration(
                           hintText: 'Describe current health issues...',
                           filled: true,
                           fillColor: theme.dividerColor.withOpacity(0.05),
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                         ),
                       ),
                       const SizedBox(height: 20),
                       SizedBox(
                         width: double.infinity,
                         height: 52,
                         child: ElevatedButton(
                           onPressed: _isLoading ? null : _submitConsultation,
                           style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
                           child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         ),
                       ),
                     ],
                   ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _patientInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme, Color accentColor) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.check_circle, size: 80, color: AppColors.success),
          ),
          const SizedBox(height: 32),
          const Text('Consultation Booked!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'A request has been sent to available doctors for Dr. ${_patientData?['name']}. You can see this in patient records later.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
              child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
