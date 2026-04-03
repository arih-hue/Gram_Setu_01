import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';

class PanchayatRecordsScreen extends StatefulWidget {
  const PanchayatRecordsScreen({super.key});

  @override
  State<PanchayatRecordsScreen> createState() => _PanchayatRecordsScreenState();
}

class _PanchayatRecordsScreenState extends State<PanchayatRecordsScreen> {
  final _uidSearchController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _records = [];
  String? _lastSearchedUid;

  @override
  void dispose() {
    _uidSearchController.dispose();
    super.dispose();
  }

  Future<void> _searchRecords() async {
    final uid = _uidSearchController.text.trim();
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a UID to search')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/consultations/user/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _records = data['records'];
          _lastSearchedUid = uid;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search Error: $e')));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Village Records', showBack: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _uidSearchController,
                    decoration: InputDecoration(
                        hintText: 'Search by Patient UID',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.adaptiveSurface(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                    onSubmitted: (_) => _searchRecords(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _searchRecords,
                  icon: const Icon(Icons.arrow_forward),
                  style: IconButton.styleFrom(backgroundColor: AppColors.panchayatPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Results Heading
            if (_lastSearchedUid != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Records for UID: $_lastSearchedUid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
              ),
            const SizedBox(height: 12),

            // Results List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _records.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _records.length,
                          itemBuilder: (context, index) {
                            final item = _records[index];
                            return _buildRecordCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
      if (_lastSearchedUid == null) {
          return Center(
             child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.person_search_outlined, size: 64, color: AppColors.adaptiveTextSecondary(context)),
                    const SizedBox(height: 16),
                    Text('Enter a patient UID to see records', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                ],
             ),
          );
      }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: AppColors.adaptiveTextSecondary(context)),
          const SizedBox(height: 16),
          Text('No records found for this UID.', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> item) {
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
                'Problem Record',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
              ),
              Text(
                item['createdAt'].toString().split('T')[0],
                style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['problem'] ?? 'No description',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${item['status']}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: item['status'] == 'completed' ? AppColors.success : AppColors.warning),
          ),
        ],
      ),
    );
  }
}
