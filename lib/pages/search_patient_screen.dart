import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';
import 'patient_profile_view.dart';

class SearchPatientScreen extends StatefulWidget {
  const SearchPatientScreen({super.key});

  @override
  State<SearchPatientScreen> createState() => _SearchPatientScreenState();
}

class _SearchPatientScreenState extends State<SearchPatientScreen> {
  final _uidController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('/users/uid/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientProfileView(data: data),
            ),
          );
        }
      } else {
        setState(() => _error = 'Patient with UID $uid not found.');
      }
    } catch (e) {
      setState(() => _error = 'Error occurred during search.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GramAppBar(roleLabel: 'Search Patient', showBack: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Search',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 12-digit Patient Health UID to retrieve their complete medical profile.',
              style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 32),
            
            // Search Input
            TextField(
              controller: _uidController,
              decoration: InputDecoration(
                hintText: 'e.g. PAT-123456',
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryTeal),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primaryTeal),
                  onPressed: _isLoading ? null : _handleSearch,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: theme.cardTheme.color,
              ),
              onSubmitted: (_) => _handleSearch(),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.emergencyRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.emergencyRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.emergencyRed))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
            if (_isLoading)
               const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _handleSearch,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                  child: const Text('Lookup Patient Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
