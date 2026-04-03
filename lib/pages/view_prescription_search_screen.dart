import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';

class ViewPrescriptionSearchScreen extends StatefulWidget {
  final Color themeColor;
  const ViewPrescriptionSearchScreen({super.key, this.themeColor = AppColors.primaryTeal});

  @override
  State<ViewPrescriptionSearchScreen> createState() => _ViewPrescriptionSearchScreenState();
}

class _ViewPrescriptionSearchScreenState extends State<ViewPrescriptionSearchScreen> {
  final _uidController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _prescriptions = [];
  bool _searched = false;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _searchPrescriptions() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searched = true;
    });

    try {
      final response = await ApiService.get('/prescription/patient/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prescriptions = data['prescriptions'];
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _prescriptions = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not find prescriptions for this UID')));

      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(roleLabel: 'View Patient Prescription', showBack: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _uidController,
              decoration: InputDecoration(
                hintText: 'Search Patient UID...',
                prefixIcon: Icon(Icons.search, color: widget.themeColor),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _searchPrescriptions,
                ),
              ),
              onSubmitted: (_) => _searchPrescriptions(),
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _searched && _prescriptions.isEmpty
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No records found for this UID', style: TextStyle(color: Colors.grey)),
        ],
      ),
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
              Text(rx['doctorName'] ?? 'Doctor', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(formattedDate, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
            ],
          ),
          const Divider(height: 24),
          
          ...medicines.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.medication, size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${m['medicineName']} (${m['duration']}) • ${m['timing']}', style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          )),

          if (rx['extraNote'] != null && rx['extraNote'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${rx['extraNote']}',
              style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextSecondary(context), fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
