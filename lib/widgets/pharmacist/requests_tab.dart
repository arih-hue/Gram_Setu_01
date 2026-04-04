import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/models/medicine_request.dart';
import '../../services/medicine_request_service.dart';
import '../translated_text.dart';
import 'package:intl/intl.dart';

class RequestsTab extends StatefulWidget {
  final String pharmacistId;
  const RequestsTab({super.key, required this.pharmacistId});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  bool _isLoading = true;
  List<MedicineRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    final requests = await MedicineRequestService.getRequests(pharmacistId: widget.pharmacistId);
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    final success = await MedicineRequestService.updateRequestStatus(id, status);
    if (success) {
      _fetchRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatedText('Request status updated to $status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchRequests,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              alignment: Alignment.center,
              child: const TranslatedText('No medicine requests found.'),
            )
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final req = _requests[index];
          return _buildRequestCard(req);
        },
      ),
    );
  }

  Widget _buildRequestCard(MedicineRequest req) {
    Color statusColor;
    switch (req.status) {
      case 'accepted': statusColor = Colors.blue; break;
      case 'completed': statusColor = Colors.green; break;
      case 'rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(req.medicineName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TranslatedText(
                  req.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.primaryTeal),
              const SizedBox(width: 4),
              Text(req.patientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('UID: ${req.patientUID}', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.primaryTeal),
              const SizedBox(width: 4),
              Text('Qty: ${req.quantity}', style: const TextStyle(fontSize: 12)),
              const Spacer(),
              Text(
                DateFormat('dd MMM yyyy').format(req.requestDate),
                style: TextStyle(fontSize: 11, color: AppColors.adaptiveTextSecondary(context)),
              ),
            ],
          ),
          if (req.notes.isNotEmpty) ...[
            const Divider(height: 20),
            Text('Notes: ${req.notes}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (req.status == 'pending') ...[
                TextButton(
                  onPressed: () => _updateStatus(req.id, 'rejected'),
                  child: const TranslatedText('Reject', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () => _updateStatus(req.id, 'accepted'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                  child: const TranslatedText('Accept', style: TextStyle(color: Colors.white)),
                ),
              ] else if (req.status == 'accepted') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(req.id, 'completed'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const TranslatedText('Mark Completed', style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
