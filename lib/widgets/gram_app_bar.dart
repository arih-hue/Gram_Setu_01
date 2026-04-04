import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/theme_provider.dart';
import '../core/user_provider.dart';
import '../core/emergency_util.dart';

class GramAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? roleLabel;
  final VoidCallback? onSosTap;
  final VoidCallback? onLogoutTap;
  final bool showSos;
  final bool showBack;

  const GramAppBar({
    super.key,
    this.roleLabel,
    this.onSosTap,
    this.onLogoutTap,
    this.showSos = true,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10); // increased for double subtitle

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final user = userProvider.user;

    // Get location accurately from user data
    String locationText = '';
    if (user != null && user['location'] != null) {
      final loc = user['location'];
      if (loc is Map) {
        final village = loc['village'] ?? '';
        final block = loc['block'] ?? '';
        if (village.isNotEmpty && block.isNotEmpty) {
          locationText = '$village, $block';
        } else {
          locationText = loc['fullLocation'] ?? '';
        }
      } else if (loc is String) {
        locationText = loc;
      }
    }

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: showBack,
      titleSpacing: showBack ? 0 : 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco,
              color: AppColors.primaryTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gram Setu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.appBarTheme.titleTextStyle?.color,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      roleLabel ?? 'Healthcare',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    if (locationText.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text('|', style: TextStyle(fontSize: 10, color: theme.dividerColor)),
                      ),
                      Expanded(
                        child: Text(
                          locationText,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            size: 22,
            color: themeProvider.isDarkMode ? AppColors.accentYellow : theme.primaryColor,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: 'Toggle Theme',
        ),
        if (showSos)
          GestureDetector(
            onTap: onSosTap ?? () => EmergencyUtil.callEmergency(context),
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.call, color: Colors.white, size: 14),
                   Text('SOS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        if (onLogoutTap != null)
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            onPressed: onLogoutTap,
            tooltip: 'Logout',
          ),
      ],
    );
  }
}
