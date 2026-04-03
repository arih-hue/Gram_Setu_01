import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';

class ConsultationRequestsScreen extends StatefulWidget {
  const ConsultationRequestsScreen({super.key});

  @override
  State<ConsultationRequestsScreen> createState() => _ConsultationRequestsScreenState();
}

class _ConsultationRequestsScreenState extends State<ConsultationRequestsScreen> {
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
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _acceptRequest(String id) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      final doctorId = user['id'] ?? user['_id']; // Fallback for safety
      if (doctorId == null) throw Exception('Doctor ID not found in session');

      final response = await ApiService.patch('/consultation/accept/$id', {
        'acceptedByDoctorId': doctorId,
        'acceptedByDoctorName': user['name'],
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consultation accepted successfully!')),
          );
          // Remove from list immediately
          setState(() {
            _requests.removeWhere((r) => r['_id'] == id);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Consultation Requests', showBack: true),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchRequests,
            child: _requests.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
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

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.adaptiveTextSecondary(context)),
              const SizedBox(height: 16),
              Text('No pending requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
            ],
          ),
        ),
      ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                req['patientName'] ?? 'Unknown',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'UID: ${req['patientUID']}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoBadge(Icons.person_outline, '${req['patientAge']} Yrs'),
              const SizedBox(width: 8),
              _infoBadge(Icons.wc, req['patientGender']),
              const SizedBox(width: 8),
              _infoBadge(Icons.bookmark_outline, 'By: ${req['bookedBy']}'),
            ],
          ),
          const Divider(height: 24),
          Text(
            'Reason:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context)),
          ),
          const SizedBox(height: 4),
          Text(
            req['reason'] ?? 'No reason provided',
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _acceptRequest(req['_id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.doctorGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Accept Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.adaptiveTextSecondary(context)),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
      ],
    );
  }
}
