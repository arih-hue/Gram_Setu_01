import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';

class ViewRequestsScreen extends StatefulWidget {
  const ViewRequestsScreen({super.key});

  @override
  State<ViewRequestsScreen> createState() => _ViewRequestsScreenState();
}

class _ViewRequestsScreenState extends State<ViewRequestsScreen> {
  bool _isLoading = true;
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/consultation/all');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _requests = data['consultations'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final doctor = userProvider.user;
    
    if (doctor == null) return;

    try {
      final response = await ApiService.post('/consultation/accept/${request['_id']}', {
        'doctorId': doctor['uid'] ?? doctor['_id'],
        'doctorName': doctor['name'],
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consultation Accepted!'), backgroundColor: AppColors.success),
          );
        }
        _fetchRequests(); // Refresh list (it will be gone because of server filter)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'New Requests', showBack: true),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _requests.isEmpty
          ? const Center(child: Text('No new requests found.'))
          : RefreshIndicator(
              onRefresh: _fetchRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final req = _requests[index];
                  return _buildRequestCard(req);
                },
              ),
            ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
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
              Text(req['patientName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'From: ${req['bookedBy']?.toString().toUpperCase()}', 
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('UID: ${req['patientUID']} • Age: ${req['patientAge']} • ${req['patientGender']}', 
               style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
          const Divider(height: 24),
          const Text('Reason for Consultation:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(req['reason'] ?? 'No reason provided', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _acceptRequest(req),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.doctorGreen),
              child: const Text('Accept Request'),
            ),
          ),
        ],
      ),
    );
  }
}
