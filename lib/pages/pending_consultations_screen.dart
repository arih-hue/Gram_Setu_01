import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';

class PendingConsultationsScreen extends StatefulWidget {
  const PendingConsultationsScreen({super.key});

  @override
  State<PendingConsultationsScreen> createState() => _PendingConsultationsScreenState();
}

class _PendingConsultationsScreenState extends State<PendingConsultationsScreen> {
  bool _isLoading = true;
  List<dynamic> _consultations = [];

  @override
  void initState() {
    super.initState();
    _fetchPending();
  }

  Future<void> _fetchPending() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/consultations/pending');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _consultations = data['consultations'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching: $e')),
      );
    }

  }

  Future<void> _completeConsultation(String id) async {
    try {
        final response = await ApiService.post('/consultations/$id/complete', {});
        if (response.statusCode == 200) {
            _fetchPending();
        }
    } catch (e) {
        // Log error silently

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Pending Consultations', showBack: true),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _consultations.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchPending,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _consultations.length,
                itemBuilder: (context, index) {
                  final item = _consultations[index];
                  return _buildConsultationCard(item);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AppColors.adaptiveTextSecondary(context)),
          const SizedBox(height: 16),
          Text('All caught up!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
          Text('No pending consultations at the moment.', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['patientName'] ?? 'Unknown Patient',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'UID: ${item['uid']}',
                style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Problem:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
          ),
          Text(
            item['problem'] ?? 'No description',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {}, // Future: Video Call
                  child: const Text('Video Call'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _completeConsultation(item['_id']),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  child: const Text('Complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
