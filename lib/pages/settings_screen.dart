import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../widgets/gram_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const GramAppBar(roleLabel: 'Settings', showBack: true, showSos: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Customize your app preferences',
              style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionTitle(theme, 'Appearance'),
            const SizedBox(height: 12),
            _buildSettingCard(
              theme: theme,
              icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              iconColor: themeProvider.isDarkMode ? AppColors.accentYellow : AppColors.primaryTeal,
              title: 'Dark Mode',
              subtitle: themeProvider.isDarkMode ? 'Dark theme is active' : 'Light theme is active',
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                activeTrackColor: AppColors.primaryTeal,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            const SizedBox(height: 24),

            // About Section
            _buildSectionTitle(theme, 'About'),
            const SizedBox(height: 12),
            _buildSettingCard(
              theme: theme,
              icon: Icons.info_outline,
              iconColor: AppColors.softBlue,
              title: 'Gram Setu',
              subtitle: 'Version 1.0.0 • Rural Healthcare Platform',
            ),
            _buildSettingCard(
              theme: theme,
              icon: Icons.shield_outlined,
              iconColor: AppColors.doctorGreen,
              title: 'Privacy Policy',
              subtitle: 'Read our data handling practices',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.titleMedium?.color,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color)),
                Text(subtitle, style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
