import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../core/models/medicine.dart';
import '../services/medicine_service.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/translated_text.dart';
import '../widgets/pharmacist/inventory_tab.dart';
import '../widgets/pharmacist/requests_tab.dart';
import '../widgets/pharmacist/pharmacist_profile_tab.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          backgroundColor: AppColors.adaptiveSurface(context),
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
                  activeColor: AppColors.primaryTeal,
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
                  if (mounted) Navigator.pop(context);
                  _fetchMedicines();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
              child: TranslatedText(medicine == null ? 'Add' : 'Update', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Medicine med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.adaptiveSurface(context),
        title: const TranslatedText('Delete Medicine'),
        content: TranslatedText('Are you sure you want to delete ${med.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TranslatedText('Cancel')),
          TextButton(
            onPressed: () async {
              final success = await MedicineService.deleteMedicine(med.id);
              if (success) {
                if (mounted) Navigator.pop(context);
                _fetchMedicines();
              }
            },
            child: const TranslatedText('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final userName = user?['name'] ?? 'Pharmacist';
    final pharmacistId = user?['pharmacistId'] ?? 'unknown';

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(
        roleLabel: 'Pharmacist Portal',
        showSos: false,
        onLogoutTap: () {
            Provider.of<UserProvider>(context, listen: false).clearUser();
            Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_currentIndex == 0)
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
                    
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                        _searchMedicines(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search inventory...',
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
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  InventoryTab(
                    medicines: _medicines,
                    isLoading: _isLoading,
                    onEdit: (med) => _showAddMedicineDialog(medicine: med),
                    onDelete: _confirmDelete,
                    onRefresh: _fetchMedicines,
                  ),
                  RequestsTab(pharmacistId: pharmacistId),
                  PharmacistProfileTab(userData: user ?? {}),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0 
        ? FloatingActionButton(
            onPressed: () => _showAddMedicineDialog(),
            backgroundColor: AppColors.primaryTeal,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primaryTeal,
          unselectedItemColor: AppColors.adaptiveTextSecondary(context).withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Inventory'),
            BottomNavigationBarItem(icon: Icon(Icons.message_outlined), activeIcon: Icon(Icons.message), label: 'Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
