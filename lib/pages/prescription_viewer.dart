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
      appBar: const GramAppBar(roleLabel: 'Prescription History', showBack: true),
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
              const Text('No records found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Medical prescriptions will appear here after sessions.', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
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
    // Date Format: DD/MM/YYYY
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final medicines = rx['medicines'] as List<dynamic>? ?? [];
    
    // Title is Reason / Problem
    String reason = 'General Consultation';
    if (rx['consultationId'] != null) {
      if (rx['consultationId'] is Map) {
        reason = rx['consultationId']['reason'] ?? 'General Consultation';
      } else {
        reason = 'Prescription for: Consultation';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 6))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prescription for: $reason',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, color: AppColors.doctorGreen, size: 22),
            ],
          ),
          const Divider(height: 32, thickness: 1.2),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PATIENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context), letterSpacing: 0.5)),
                  Text(rx['patientName'] ?? 'No Name', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DIAGNOSED BY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context), letterSpacing: 0.5)),
                  Text('Dr. ${rx['doctorName'] ?? 'Physician'}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text('PRESCRIBED MEDICINES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context), letterSpacing: 1)),
          const SizedBox(height: 12),
          
          ...medicines.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.adaptiveBackground(context).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.adaptiveBorder(context).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.medication_rounded, size: 18, color: AppColors.primaryTeal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine name BOLD
                      Text(m['medicineName'] ?? 'Medicine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.2)),
                      const SizedBox(height: 2),
                      Text('Duration: ${m['duration'] ?? 'N/A'} • Timing: ${m['timing'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                    ],
                  ),
                ),
              ],
            ),
          )),

          if (rx['extraNote'] != null && rx['extraNote'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DOCTOR\'S ADVICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text(
                    rx['extraNote'],
                    style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextPrimary(context), height: 1.5, fontStyle: FontStyle.italic),
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
