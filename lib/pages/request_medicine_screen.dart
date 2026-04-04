import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../core/models/medicine_request.dart';
import '../services/medicine_request_service.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/translated_text.dart';

class RequestMedicineScreen extends StatefulWidget {
  const RequestMedicineScreen({super.key});

  @override
  State<RequestMedicineScreen> createState() => _RequestMedicineScreenState();
}

class _RequestMedicineScreenState extends State<RequestMedicineScreen> {
  final _medicineNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _medicineNameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final name = _medicineNameController.text.trim();
    final qty = _quantityController.text.trim();
    final notes = _notesController.text.trim();

    if (name.isEmpty || qty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TranslatedText('Please enter medicine name and quantity')),
      );
      return;
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final request = MedicineRequest(
        id: '',
        patientUID: user['uid'] ?? 'N/A',
        patientName: user['name'] ?? 'Patient',
        medicineName: name,
        quantity: qty,
        requestDate: DateTime.now(),
        notes: notes,
      );

      final success = await MedicineRequestService.createRequest(request);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TranslatedText('Request sent to village pharmacist'), backgroundColor: AppColors.primaryTeal),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Request Medicine', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TranslatedText(
              'Order Medication',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TranslatedText('Submit a request to your local pharmacist for available medicines.'),
            const SizedBox(height: 32),

            _buildLabel('Medicine Name'),
            _buildTextField(controller: _medicineNameController, hint: 'e.g., Paracetamol 500mg', icon: Icons.medication),
            const SizedBox(height: 20),

            _buildLabel('Quantity (Tablets / Bottles)'),
            _buildTextField(controller: _quantityController, hint: 'e.g., 10 tablets', icon: Icons.numbers),
            const SizedBox(height: 20),

            _buildLabel('Additional Notes (Optional)'),
            _buildTextField(controller: _notesController, hint: 'Special instructions...', icon: Icons.note_alt, maxLines: 3),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const TranslatedText('Send Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TranslatedText(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryTeal),
        filled: true,
        fillColor: AppColors.adaptiveSurface(context),
      ),
    );
  }
}
