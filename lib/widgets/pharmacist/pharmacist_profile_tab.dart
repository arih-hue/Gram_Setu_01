import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/user_provider.dart';
import '../translated_text.dart';

class PharmacistProfileTab extends StatelessWidget {
  final Map<String, dynamic> userData;
  const PharmacistProfileTab({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final pharmacistId = userData['pharmacistId'] ?? 'ID-N/A';
    final village = userData['village'] ?? userData['location']?['village'] ?? 'Not set';
    final block = userData['block'] ?? userData['location']?['block'] ?? 'Not set';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
            child: const Icon(Icons.person, size: 50, color: AppColors.primaryTeal),
          ),
          const SizedBox(height: 16),
          Text(
            userData['name'] ?? 'Pharmacist',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.adaptiveTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Pharmacist ID: $pharmacistId',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
          const SizedBox(height: 32),

          _buildProfileField(context, Icons.phone_outlined, 'Contact', userData['phone'] ?? 'N/A'),
          const SizedBox(height: 12),
          _buildProfileField(context, Icons.home_outlined, 'Village', village),
          const SizedBox(height: 12),
          _buildProfileField(context, Icons.map_outlined, 'Block', block),
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/edit_profile', arguments: userData),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const TranslatedText('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).clearUser();
                Navigator.pushReplacementNamed(context, '/home');
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const TranslatedText('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(label, style: TextStyle(fontSize: 10, color: AppColors.adaptiveTextSecondary(context))),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
