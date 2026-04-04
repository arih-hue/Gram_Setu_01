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
        if (mounted) {
          setState(() {
            _requests = (data['consultations'] as List? ?? []);
            _isLoading = false;
          });
        }
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
      final doctorId = user['id'] ?? user['_id'];
      if (doctorId == null) throw Exception('Doctor ID not found in session');

      final response = await ApiService.patch('/consultation/accept/$id', {
        'acceptedByDoctorId': doctorId,
        'acceptedByDoctorName': user['name'] ?? 'Doctor',
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consultation accepted successfully!'), backgroundColor: AppColors.success),
          );
          setState(() {
            _requests.removeWhere((r) => r != null && r['_id'] == id);
          });
          // Redirect to active consultations after brief delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pushReplacementNamed(context, '/accepted_consultations');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'New Patient Requests', showBack: true),
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
                    if (req == null) return const SizedBox.shrink();
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
              Text('Check back later for new consultations.', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                req['patientName'] ?? 'Unknown Patient',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'UID: ${req['patientUID'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoBadge(Icons.person_outline, '${req['patientAge'] ?? '30'} Yrs'),
              const SizedBox(width: 12),
              _infoBadge(Icons.wc, req['patientGender'] ?? 'N/A'),
              const SizedBox(width: 12),
              _infoBadge(Icons.badge_outlined, 'By: ${req['bookedBy'] ?? 'Self'}'),
            ],
          ),
          const Divider(height: 24),
          const Text(
            'REASON FOR CONSULTATION:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryTeal, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            req['reason'] ?? req['symptoms'] ?? 'No specific symptoms listed.',
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _acceptRequest(req['_id']?.toString() ?? ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.doctorGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Accept Consultation', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
        Text(text, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
