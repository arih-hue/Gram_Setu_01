import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/section_header.dart';

class PatientProfileView extends StatelessWidget {
  final Map<String, dynamic> data;
  const PatientProfileView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = data['user'] ?? {};
    final consultations = (data['consultations'] as List? ?? []);
    final prescriptions = (data['prescriptions'] as List? ?? []);

    // Extract location info
    String village = 'N/A';
    String block = 'N/A';
    String fullLoc = 'N/A';
    
    if (user['location'] != null) {
      if (user['location'] is Map) {
        village = user['location']['village'] ?? 'N/A';
        block = user['location']['block'] ?? 'N/A';
        fullLoc = user['location']['fullLocation'] ?? 'N/A';
      } else {
        fullLoc = user['location'];
        final parts = fullLoc.split(',');
        if (parts.isNotEmpty) village = parts.first.trim();
        if (parts.length > 1) block = parts[1].trim();
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GramAppBar(roleLabel: 'Patient Profile', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Personal Details
            const SectionHeader(title: 'Personal Details'),
            _buildDetailCard(theme, [
              _DetailRow(label: 'Name', value: user['name'] ?? 'N/A'),
              _DetailRow(label: 'Age', value: '${user['age'] ?? '30'} Years'),
              _DetailRow(label: 'Gender', value: user['gender'] ?? 'N/A'),
              _DetailRow(label: 'UID', value: user['uid'] ?? 'N/A'),
              _DetailRow(label: 'Village', value: village),
              _DetailRow(label: 'Block', value: block),
              _DetailRow(label: 'Complete Address', value: fullLoc),
            ]),
            const SizedBox(height: 24),

            // 2. Past Consultations
            const SectionHeader(title: 'Past Consultations'),
            if (consultations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text('No previous consultations found.', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
              )
            else
              ...consultations.map((c) => _buildConsultationCard(theme, c)),
            const SizedBox(height: 24),

            // 3. Past Prescriptions
            const SectionHeader(title: 'Complete Prescription History'),
            if (prescriptions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text('No previous prescriptions found.', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
              )
            else
              ...prescriptions.map((rx) => _buildPrescriptionCard(context, rx)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(ThemeData theme, List<_DetailRow> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: rows.map((row) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 120, child: Text(row.label, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13))),
              const SizedBox(width: 8),
              Expanded(child: Text(row.value, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.displayLarge?.color))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildConsultationCard(ThemeData theme, dynamic c) {
    final dateStr = c['createdAt'] ?? c['timestamp'] ?? '';
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedDate, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('Consultation', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(c['reason'] ?? c['symptoms'] ?? 'No reason provided', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text('Doctor: Dr. ${c['acceptedByDoctorName'] ?? 'General Practitioner'}', style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, dynamic rx) {
    final theme = Theme.of(context);
    final dateStr = rx['date'] ?? rx['timestamp'] ?? '';
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final medicines = (rx['medicines'] as List? ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.doctorGreen, fontSize: 13)),
              const Icon(Icons.history_edu, color: AppColors.doctorGreen, size: 20),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          
          ...medicines.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medication, size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['medicineName'] ?? 'Medicine Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${m['duration'] ?? 'N/A'} • ${m['timing'] ?? 'N/A'}', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
              ],
            ),
          )),
          
          if (rx['extraNote'] != null && rx['extraNote'].toString().isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('DOCTOR NOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                   const SizedBox(height: 4),
                   Text(rx['extraNote'], style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
}
