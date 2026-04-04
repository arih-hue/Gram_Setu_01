import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';
import 'write_prescription_screen.dart';
import 'video_call_screen.dart';

class AcceptedConsultationsScreen extends StatefulWidget {
  const AcceptedConsultationsScreen({super.key});

  @override
  State<AcceptedConsultationsScreen> createState() => _AcceptedConsultationsScreenState();
}

class _AcceptedConsultationsScreenState extends State<AcceptedConsultationsScreen> {
  bool _isLoading = true;
  List<dynamic> _consultations = [];

  @override
  void initState() {
    super.initState();
    _fetchAccepted();
  }

  Future<void> _fetchAccepted() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    
    setState(() => _isLoading = true);
    try {
      final doctorId = user['id'] ?? user['_id'];
      final response = await ApiService.get('/consultation/accepted/$doctorId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _consultations = (data['consultations'] as List? ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load consultations');
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

  Future<void> _startConsultation(String id) async {
    try {
      final response = await ApiService.patch('/consultation/start/$id', {});
      if (response.statusCode == 200) {
        _fetchAccepted();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session started! You can now join the call.'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting session: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'My Accepted Consultations', showBack: true),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchAccepted,
            child: _consultations.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _consultations.length,
                  itemBuilder: (context, index) {
                    final item = _consultations[index];
                    return _buildItemCard(item);
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
              const Text('No consultations currently accepted', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Accept some from the consultation requests.', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
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
                item['patientName'] ?? 'Unknown',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                'Age: ${item['patientAge']}',
                style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextSecondary(context)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'UID: ${item['patientUID']}',
            style: TextStyle(fontSize: 12, color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Reason:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context)),
          ),
          Text(
            item['reason'] ?? 'None',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
          const Divider(height: 24),
          if (item['status'] == 'active')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoCallScreen(consultation: item),
                        ),
                      );
                    },
                    icon: const Icon(Icons.videocam_outlined, size: 18),
                    label: const Text('Join Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WritePrescriptionScreen(consultation: item),
                        ),
                      );
                      if (result == true) {
                        _fetchAccepted();
                      }
                    },
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Prescribe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _startConsultation(item['_id']),
                icon: const Icon(Icons.play_arrow_outlined, color: Colors.white),
                label: const Text('Start Consultation Session', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.doctorGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
