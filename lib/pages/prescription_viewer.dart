import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';

class PrescriptionViewer extends StatefulWidget {
  final String? patientUid;
  const PrescriptionViewer({super.key, this.patientUid});

  @override
  State<PrescriptionViewer> createState() => _PrescriptionViewerState();
}

class _PrescriptionViewerState extends State<PrescriptionViewer> {
  bool _isLoading = true;
  List<dynamic> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final uid = widget.patientUid ?? (user != null ? user['uid'] : null);
    
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/prescription/patient/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _prescriptions = data['prescriptions'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load prescriptions');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Medical History', showBack: true),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchPrescriptions,
            child: _prescriptions.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    final rx = _prescriptions[index];
                    return _buildRxCard(rx);
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
              Icon(Icons.description_outlined, size: 64, color: AppColors.adaptiveTextSecondary(context)),
              const SizedBox(height: 16),
              const Text('No prescriptions found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Medical history will appear here.', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRxCard(Map<String, dynamic> rx) {
    DateTime? date;
    try {
      date = DateTime.parse(rx['date']);
    } catch (e) {
      date = DateTime.now();
    }
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
    final medicines = rx['medicines'] as List<dynamic>? ?? [];
    
    String reason = 'General Consultation';
    if (rx['consultationId'] != null) {
      if (rx['consultationId'] is Map) {
        reason = rx['consultationId']['reason'] ?? 'General Consultation';
      } else {
        reason = 'Consultation Record';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reason,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 11, color: AppColors.adaptiveTextSecondary(context)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, color: AppColors.doctorGreen, size: 20),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PATIENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context))),
                  Text(rx['patientName'] ?? 'No Name', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DOCTOR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context))),
                  Text('Dr. ${rx['doctorName'] ?? 'Doctor'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Text('PRESCRIBED MEDICINES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context))),
          const SizedBox(height: 10),
          
          ...medicines.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.adaptiveBackground(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.adaptiveBorder(context).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.medication, size: 16, color: AppColors.primaryTeal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['medicineName'] ?? 'Medicine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Duration: ${m['duration'] ?? 'N/A'} • Timing: ${m['timing'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                    ],
                  ),
                ),
              ],
            ),
          )),

          if (rx['extraNote'] != null && rx['extraNote'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 16, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DOCTOR\'S REMARKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                        const SizedBox(height: 4),
                        Text(
                          rx['extraNote'],
                          style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextPrimary(context), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
