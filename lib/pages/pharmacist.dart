import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../core/models/medicine.dart';
import '../services/medicine_service.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/translated_text.dart';

class PharmacistDashboard extends StatefulWidget {
  const PharmacistDashboard({super.key});

  @override
  State<PharmacistDashboard> createState() => _PharmacistDashboardState();
}

class _PharmacistDashboardState extends State<PharmacistDashboard> {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<Medicine> _medicines = [];
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    setState(() => _isLoading = true);
    final medicines = await MedicineService.getAllMedicines();
    setState(() {
      _medicines = medicines;
      _isLoading = false;
    });
  }

  Future<void> _searchMedicines(String query) async {
    if (query.isEmpty) {
      _fetchMedicines();
      return;
    }
    setState(() => _isLoading = true);
    final medicines = await MedicineService.searchMedicines(query);
    setState(() {
      _medicines = medicines;
      _isLoading = false;
    });
  }

  void _showAddMedicineDialog({Medicine? medicine}) {
    final nameCtrl = TextEditingController(text: medicine?.name);
    final expiryCtrl = TextEditingController(text: medicine?.expiryDate);
    final priceCtrl = TextEditingController(text: medicine?.price.toString());
    final descCtrl = TextEditingController(text: medicine?.description);
    final mfrCtrl = TextEditingController(text: medicine?.manufacturer);
    bool available = medicine?.availability ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: TranslatedText(medicine == null ? 'Add Medicine' : 'Edit Medicine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medicine Name')),
                TextField(controller: expiryCtrl, decoration: const InputDecoration(labelText: 'Expiry Date (MM/YYYY)')),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number),
                TextField(controller: mfrCtrl, decoration: const InputDecoration(labelText: 'Manufacturer')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const TranslatedText('In Stock'),
                  value: available,
                  onChanged: (val) => setDialogState(() => available = val ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const TranslatedText('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final user = Provider.of<UserProvider>(context, listen: false).user;
                final pharmacistId = user?['pharmacistId'] ?? 'unknown';
                
                final newMed = Medicine(
                  id: medicine?.id ?? '',
                  name: nameCtrl.text.trim(),
                  expiryDate: expiryCtrl.text.trim(),
                  availability: available,
                  price: double.tryParse(priceCtrl.text) ?? 0.0,
                  description: descCtrl.text.trim(),
                  manufacturer: mfrCtrl.text.trim(),
                  pharmacistId: pharmacistId,
                );

                bool success;
                if (medicine == null) {
                  success = await MedicineService.addMedicine(newMed);
                } else {
                  success = await MedicineService.updateMedicine(medicine.id, newMed.toJson());
                }

                if (success) {
                  Navigator.pop(context);
                  _fetchMedicines();
                }
              },
              child: TranslatedText(medicine == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final userName = user?['name'] ?? 'Pharmacist';

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(
        roleLabel: 'Pharmacist Dashboard',
        onLogoutTap: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    'Hello, $userName 👋',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context)),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _searchMedicines(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search medicines...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryTeal),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _fetchMedicines();
                        })
                        : null,
                      filled: true,
                      fillColor: AppColors.adaptiveSurface(context),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchMedicines,
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _medicines.isEmpty
                    ? const Center(child: TranslatedText('No medicines found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _medicines.length,
                        itemBuilder: (context, index) {
                          final med = _medicines[index];
                          return _buildMedicineCard(med);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicineDialog(),
        backgroundColor: AppColors.primaryTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: _buildBottomNavBar(),
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
                    onPressed: () => _showAddMedicineDialog(medicine: med),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _confirmDelete(med),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Medicine med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslatedText('Delete Medicine'),
        content: TranslatedText('Are you sure you want to delete ${med.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TranslatedText('Cancel')),
          TextButton(
            onPressed: () async {
              final success = await MedicineService.deleteMedicine(med.id);
              if (success) {
                Navigator.pop(context);
                _fetchMedicines();
              }
            },
            child: const TranslatedText('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context).withAlpha(229),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.person_outline, 'Profile', 1),
          _buildNavItem(Icons.settings_outlined, 'Settings', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () async {
        if (index == 0) {
          setState(() => _currentIndex = index);
          return;
        }

        if (index == 1) {
          await Navigator.pushNamed(context, '/profile', arguments: 'pharmacist');
        } else if (index == 2) {
          await Navigator.pushNamed(context, '/settings');
        }

        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryTeal : AppColors.adaptiveTextSecondary(context), size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              TranslatedText(label, style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
