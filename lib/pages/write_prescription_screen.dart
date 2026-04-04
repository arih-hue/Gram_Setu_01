import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../core/user_provider.dart';
import '../widgets/gram_app_bar.dart';

class MedicineEntry {
  TextEditingController nameController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController timingController = TextEditingController();

  Map<String, String> toJson() {
    return {
      'medicineName': nameController.text,
      'duration': durationController.text,
      'timing': timingController.text,
    };
  }

  void dispose() {
    nameController.dispose();
    durationController.dispose();
    timingController.dispose();
  }
}

class WritePrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> consultation;
  const WritePrescriptionScreen({super.key, required this.consultation});

  @override
  State<WritePrescriptionScreen> createState() => _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState extends State<WritePrescriptionScreen> {
  final List<MedicineEntry> _medicines = [];
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addMedicineField(); // Add initial field
  }

  void _addMedicineField() {
    setState(() {
      _medicines.add(MedicineEntry());
    });
  }

  void _removeMedicineField(int index) {
    if (_medicines.length > 1) {
      setState(() {
        _medicines[index].dispose();
        _medicines.removeAt(index);
      });
    }
  }

  Future<void> _submitPrescription() async {
    // Validate
    bool isValid = true;
    for (var med in _medicines) {
      if (med.nameController.text.isEmpty) isValid = false;
    }
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all medicine names.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    final body = {
      'patientName': widget.consultation['patientName'],
      'patientUID': widget.consultation['patientUID'],
      'patientAge': widget.consultation['patientAge'],
      'doctorName': user['name'],
      'doctorId': user['id'] ?? user['_id'],
      'medicines': _medicines.map((m) => m.toJson()).toList(),
      'extraNote': _noteController.text,
      'consultationId': widget.consultation['_id'],
    };

    try {
      final response = await ApiService.post('/prescription/create', body);
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescription sent successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to send prescription');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    for (var med in _medicines) {
      med.dispose();
    }
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final String today = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Write Prescription', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient & Doctor Info Card (Read-only)
            _buildHeaderCard(user, today),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Medicines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
                TextButton.icon(
                  onPressed: _addMedicineField,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Medicine'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Medicines List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                return _buildMedicineField(index);
              },
            ),

            const SizedBox(height: 16),
            Text('Extra Note (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: TextStyle(color: AppColors.adaptiveTextPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Any special instructions...',
                filled: true,
                fillColor: AppColors.adaptiveSurface(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.adaptiveBorder(context))),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPrescription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Prescription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic>? user, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurfaceVariant(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerInfo('PATIENT', widget.consultation['patientName']),
              _headerInfo('UID', widget.consultation['patientUID']),
              _headerInfo('AGE', '${widget.consultation['patientAge']}'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerInfo('DOCTOR', "Dr. ${user?['name'] ?? 'Doctor'}"),
              _headerInfo('DATE', date),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context))),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
      ],
    );
  }

  Widget _buildMedicineField(int index) {
    final med = _medicines[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: med.nameController,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Medicine Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _removeMedicineField(index),
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: med.durationController,
                  style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextSecondary(context)),
                  decoration: const InputDecoration(
                    hintText: 'Duration (e.g. 7 days)',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: AppColors.adaptiveBorder(context).withValues(alpha: 0.5), margin: const EdgeInsets.symmetric(horizontal: 8)),
              Expanded(
                child: TextField(
                  controller: med.timingController,
                  style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextSecondary(context)),
                  decoration: const InputDecoration(
                    hintText: 'When (e.g. After meals)',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
