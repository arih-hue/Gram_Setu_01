import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../services/medicine_service.dart';
import '../widgets/translated_text.dart';
import '../widgets/gram_app_bar.dart';

class BrowseMedicinesScreen extends StatefulWidget {
  const BrowseMedicinesScreen({super.key});

  @override
  State<BrowseMedicinesScreen> createState() => _BrowseMedicinesScreenState();
}

class _BrowseMedicinesScreenState extends State<BrowseMedicinesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allMedicines = [];
  List<Map<String, dynamic>> _filteredMedicines = [];
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await MedicineService.browseMedicinesWithDetails();
    // Sort by name alphabetically
    data.sort((a, b) => (a['name'] ?? '').toLowerCase().compareTo((b['name'] ?? '').toLowerCase()));
    
    setState(() {
      _allMedicines = data;
      _filteredMedicines = data;
      _isLoading = false;
    });
  }

  void _filterData(String query) {
    setState(() {
      _filteredMedicines = _allMedicines.where((med) {
        final name = (med['name'] ?? '').toLowerCase();
        final shop = (med['pharmacistName'] ?? '').toLowerCase();
        return name.contains(query.toLowerCase()) || shop.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Grouping logic for the grouped view if needed
  Map<String, List<Map<String, dynamic>>> get _groupedMedicines {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (var med in _filteredMedicines) {
      final name = med['name'] ?? 'Unknown';
      if (!groups.containsKey(name)) {
        groups[name] = [];
      }
      groups[name]!.add(med);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _groupedMedicines;
    final sortedKeys = groups.keys.toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GramAppBar(
        roleLabel: 'Buy Medicines',
        showBack: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: _filterData,
              decoration: InputDecoration(
                hintText: 'Search medicine or pharmacy...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryTeal),
                filled: true,
                fillColor: theme.cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Optional Category Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ["All", "Tablets", "Syrups", "Capsules", "Creams"].map((cat) {
                 final isSelected = _selectedCategory == cat;
                 return Padding(
                   padding: const EdgeInsets.only(right: 8),
                   child: ChoiceChip(
                     label: TranslatedText(cat),
                     selected: isSelected,
                     onSelected: (val) => setState(() => _selectedCategory = cat),
                     selectedColor: AppColors.primaryTeal.withOpacity(0.2),
                     labelStyle: TextStyle(
                       color: isSelected ? AppColors.primaryTeal : Colors.grey,
                       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                       fontSize: 12,
                     ),
                     backgroundColor: theme.cardTheme.color,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                     side: BorderSide(color: isSelected ? AppColors.primaryTeal : Colors.grey.withOpacity(0.2)),
                   ),
                 );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredMedicines.isEmpty
                ? Center(child: TranslatedText('No medicines found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      final name = sortedKeys[index];
                      final sellers = groups[name]!;
                      return _buildMedicineGroup(name, sellers);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineGroup(String name, List<Map<String, dynamic>> sellers) {
     final first = sellers.first; // For general medicine info
     
     return Container(
       margin: const EdgeInsets.only(bottom: 24),
       decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
          ]
       ),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header: Medicine Main Info
             Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Container(
                         width: 60,
                         height: 60,
                         decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                         ),
                         child: const Icon(Icons.medication, color: AppColors.primaryTeal, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                         child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                               const SizedBox(height: 2),
                               Text('Generic: ${first['genericName'] ?? name}', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                               const SizedBox(height: 6),
                               if (first['description'] != null)
                               Text(first['description'], style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                               const SizedBox(height: 8),
                               if (first['manufacturer'] != null)
                               Text('By: ${first['manufacturer']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryTeal)),
                            ],
                         ),
                      ),
                   ],
                ),
             ),
             
             const Divider(height: 1),
             
             // List of Sellers
             ...sellers.map((seller) => _buildSellerRow(seller)).toList(),
          ],
       ),
     );
  }

  Widget _buildSellerRow(Map<String, dynamic> seller) {
     final phone = seller['pharmacistPhone'] ?? '';
     final pharmacyName = seller['pharmacistName'] ?? 'Gram Pharmacy';
     final isAvailable = seller['availability'] == true;
     final price = seller['price']?.toString() ?? 'N/A';

     return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))
        ),
        child: Column(
           children: [
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          TranslatedText(pharmacyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Row(
                             children: [
                                Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(phone, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                             ],
                          ),
                       ],
                    ),
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                          Text('₹$price', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryTeal)),
                          const SizedBox(height: 4),
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                             decoration: BoxDecoration(
                                color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                             ),
                             child: TranslatedText(
                                isAvailable ? 'In Stock' : 'Out of Stock',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAvailable ? Colors.green : Colors.red),
                             ),
                          ),
                       ],
                    ),
                 ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                    onPressed: isAvailable 
                      ? () => _callPharmacist(phone)
                      : null,
                    style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.primaryTeal,
                       elevation: 0,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                       disabledBackgroundColor: Colors.grey[300],
                    ),
                    icon: const Icon(Icons.call, size: 18, color: Colors.white),
                    label: const TranslatedText('Call Pharmacy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                 ),
              ),
           ],
        ),
     );
  }

  Future<void> _callPharmacist(String phone) async {
    if (phone.isEmpty) return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch dialer')),
      );
    }
  }
}
