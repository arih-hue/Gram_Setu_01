import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  final Color? accentColor;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isDark = false,
    this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isDark
        ? (accentColor ?? const Color(0xFF3F4E5A))
        : theme.cardTheme.color ?? theme.colorScheme.surface;
    final titleColor = isDark ? Colors.white : theme.textTheme.titleMedium?.color;
    final subColor = isDark ? Colors.white70 : theme.textTheme.bodyMedium?.color;
    final iconBgColor = isDark
        ? Colors.white.withOpacity(0.15)
        : (accentColor?.withOpacity(0.1) ?? theme.colorScheme.surfaceContainerHighest);
    final iconClr = isDark
        ? Colors.white
        : (accentColor ?? theme.textTheme.titleMedium?.color);
    final borderColor = isDark ? Colors.transparent : theme.dividerColor.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconClr, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: subColor),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white38 : theme.textTheme.bodySmall?.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
