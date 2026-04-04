import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';
import 'prescription_viewer.dart';

class SearchPrescriptionScreen extends StatefulWidget {
  const SearchPrescriptionScreen({super.key});

  @override
  State<SearchPrescriptionScreen> createState() => _SearchPrescriptionScreenState();
}

class _SearchPrescriptionScreenState extends State<SearchPrescriptionScreen> {
  final _uidController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSearch() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      // Find if patient exists first
      final response = await ApiService.get('/user/patient/$uid');
      if (response.statusCode == 200) {
        if (mounted) {
          // If found, open the same PrescriptionViewer used by patients
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrescriptionViewer(patientUid: uid),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient not found. Please check the UID.'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Search Prescriptions', showBack: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View Patient Prescriptions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter Patient UID to retrieve the complete medical profile and prescription history.',
              style: TextStyle(color: AppColors.adaptiveTextSecondary(context)),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _uidController,
              decoration: InputDecoration(
                hintText: 'e.g. PAT-123456',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryTeal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Search Prescriptions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
