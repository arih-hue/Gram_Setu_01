import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/models/medicine.dart';
import '../translated_text.dart';

class InventoryTab extends StatefulWidget {
  final List<Medicine> medicines;
  final bool isLoading;
  final Function(Medicine?) onEdit;
  final Function(Medicine) onDelete;
  final Future<void> Function() onRefresh;

  const InventoryTab({
    super.key,
    required this.medicines,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.medicines.isEmpty) {
      return const Center(child: TranslatedText('No medicines found.'));
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.medicines.length,
        itemBuilder: (context, index) {
          final med = widget.medicines[index];
          return _buildMedicineCard(med);
        },
      ),
    );
  }

  Widget _buildMedicineCard(Medicine med) {
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
              Text(med.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('₹${med.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business, size: 14, color: AppColors.adaptiveTextSecondary(context)),
              const SizedBox(width: 4),
              Text(med.manufacturer, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: med.availability ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TranslatedText(
                  med.availability ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: med.availability ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText('Expires by:', style: TextStyle(fontSize: 10, color: AppColors.adaptiveTextSecondary(context))),
                  Text(med.expiryDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primaryTeal, size: 20),
                    onPressed: () => widget.onEdit(med),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => widget.onDelete(med),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
