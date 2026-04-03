import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';

class PrescriptionViewer extends StatefulWidget {
  const PrescriptionViewer({super.key});

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
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final uid = user['uid'];
      final response = await ApiService.get('/prescription/patient/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prescriptions = data['prescriptions'];
          _isLoading = false;
        });
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
      appBar: const GramAppBar(roleLabel: 'My Prescriptions', showBack: true),
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
              Text('Your prescriptions will appear here.', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRxCard(Map<String, dynamic> rx) {
    final date = DateTime.parse(rx['date']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final medicines = rx['medicines'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.doctorGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.person, color: AppColors.doctorGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rx['doctorName'] ?? 'Doctor', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formattedDate, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.verified, color: AppColors.primaryTeal, size: 20),
            ],
          ),
          const Divider(height: 24),
          
          Text('Medicines:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context))),
          const SizedBox(height: 8),
          
          ...medicines.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.adaptiveBackground(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.medication, size: 18, color: AppColors.primaryTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['medicineName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${m['duration']} • ${m['timing']}', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                    ],
                  ),
                ),
              ],
            ),
          )),

          if (rx['extraNote'] != null && rx['extraNote'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes, size: 16, color: AppColors.adaptiveTextSecondary(context)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rx['extraNote'],
                    style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextSecondary(context), fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
