import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';
import '../core/theme_provider.dart';
import '../core/user_provider.dart';
import '../services/auth_service.dart';

class ProfileDashboard extends StatefulWidget {
  final String? roleOverride;
  const ProfileDashboard({super.key, this.roleOverride});

  @override
  State<ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends State<ProfileDashboard> {
  String _role = 'patient';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _role = args['role'] ?? widget.roleOverride ?? 'patient';
      // _userData is now fetched live from Provider in build methods
    } else if (args is String) {
      _role = args;
    } else {
      _role = widget.roleOverride ?? 'patient';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(
        roleLabel: '${_capitalize(_role)} Profile',
        showBack: true,
        showSos: _role == 'patient',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Summary Card
            _buildProfileSummary(context, _role),
            const SizedBox(height: 24),

            // Role Specific Stats / Info
            if (_role == 'patient') ..._buildPatientSections(context, _role),
            if (_role == 'doctor') ..._buildDoctorSections(context, _role),
            if (_role == 'asha') ..._buildAshaSections(context, _role),
            if (_role == 'panchayat')
              ..._buildPanchayatSections(context, _role),

            const SizedBox(height: 24),

            // App Settings Section
            _buildSection(_role, 'App Settings', [
              _ProfileField(
                label: 'Dark Mode',
                value: themeProvider.isDarkMode ? 'On' : 'Off',
                icon: themeProvider.isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                onTap: () => themeProvider.toggleTheme(),
              ),
            ]),

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(context, _role),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  Color _getRoleColor(String role) {
    switch (role) {
      case 'doctor':
        return AppColors.doctorGreen;
      case 'asha':
        return AppColors.ashaWorkerPink;
      case 'panchayat':
        return AppColors.panchayatPurple;
      default:
        return AppColors.primaryTeal;
    }
  }

  Widget _buildProfileSummary(BuildContext context, String role) {
    final theme = Theme.of(context);
    final userData = Provider.of<UserProvider>(context).user;
    String name = userData?['name'] ?? 'User';
    String subtitle =
        'ID: ${userData?['_id']?.toString().substring(0, 8) ?? 'N/A'}';

    switch (role) {
      case 'doctor':
        subtitle = 'MCI Reg: ${userData?['mciNumber'] ?? 'N/A'}';
        break;
      case 'asha':
        subtitle = 'ASHA ID: ${userData?['ashaId'] ?? 'N/A'}';
        break;
      case 'panchayat':
        subtitle = 'Panchayat ID: ${userData?['panchayatId'] ?? 'ID-N/A'}';
        break;
      case 'patient':
        subtitle =
            'UID: ${userData?['uid'] ?? userData?['_id']?.toString().substring(0, 8) ?? 'N/A'}';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: _getRoleColor(role).withValues(alpha: 0.1),
                child: Icon(Icons.person, size: 50, color: _getRoleColor(role)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: _getRoleColor(role),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _getRoleColor(role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getRoleColor(role),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPatientSections(BuildContext context, String role) {
    final userData = Provider.of<UserProvider>(context).user;
    return [
      _buildSection(role, 'Personal Information', [
        _ProfileField(
          label: 'Full Name',
          value: userData?['name'] ?? 'Not set',
          icon: Icons.person_outline,
        ),
        _ProfileField(
          label: 'Age',
          value: userData?['age']?.toString() ?? 'Not set',
          icon: Icons.cake_outlined,
        ),
        _ProfileField(
          label: 'Gender',
          value: userData?['gender'] ?? 'Not set',
          icon: Icons.male_outlined,
        ),
        _ProfileField(
          label: 'Contact Number',
          value: userData?['phone'] ?? 'Not set',
          icon: Icons.phone_outlined,
        ),
      ]),
      const SizedBox(height: 20),
      _buildSection(role, 'Additional Details', [
        _ProfileField(
          label: 'Location/Village',
          value: userData?['location'] ?? 'Not set',
          icon: Icons.location_on_outlined,
        ),
        _ProfileField(
          label: 'Emergency Contact',
          value: userData?['emergencyContact'] ?? 'Not set',
          icon: Icons.contact_emergency_outlined,
        ),
      ]),
    ];
  }

  List<Widget> _buildDoctorSections(BuildContext context, String role) {
    final userData = Provider.of<UserProvider>(context).user;
    return [
      _buildSection(role, 'Professional Info', [
        _ProfileField(
          label: 'Hospital',
          value: userData?['hospitalName'] ?? 'N/A',
          icon: Icons.apartment_outlined,
        ),
        _ProfileField(
          label: 'MCI Number',
          value: userData?['mciNumber'] ?? 'N/A',
          icon: Icons.badge_outlined,
        ),
        _ProfileField(
          label: 'Phone',
          value: userData?['phone'] ?? 'N/A',
          icon: Icons.phone_outlined,
        ),
      ]),
      const SizedBox(height: 20),
      _buildSection(role, 'App Activity', [
        _ProfileField(
          label: 'Volunteered',
          value: '0 Hours',
          icon: Icons.volunteer_activism_outlined,
        ),
        _ProfileField(
          label: 'Avg Rating',
          value: '5.0 / 5.0',
          icon: Icons.star_outline,
        ),
      ]),
    ];
  }

  List<Widget> _buildAshaSections(BuildContext context, String role) {
    final userData = Provider.of<UserProvider>(context).user;
    return [
      _buildSection(role, 'ASHA Worker Info', [
        _ProfileField(
          label: 'Full Name',
          value: userData?['name'] ?? 'Not set',
          icon: Icons.person_outline,
        ),
        _ProfileField(
          label: 'ASHA ID',
          value: userData?['ashaId'] ?? 'N/A',
          icon: Icons.badge_outlined,
        ),
        _ProfileField(
          label: 'Contact Number',
          value: userData?['phone'] ?? 'N/A',
          icon: Icons.phone_outlined,
        ),
      ]),
      const SizedBox(height: 20),
      _buildSection(role, 'Village Assignment', [
        _ProfileField(
          label: 'Assigned Village',
          value: userData?['location'] ?? 'Not set',
          icon: Icons.location_on_outlined,
        ),
      ]),
    ];
  }

  List<Widget> _buildPanchayatSections(BuildContext context, String role) {
    final userData = Provider.of<UserProvider>(context).user;
    return [
      _buildSection(role, 'Panchayat Office Info', [
        _ProfileField(
          label: 'Panchayat ID',
          value: userData?['panchayatId'] ?? 'ID-N/A',
          icon: Icons.badge_outlined,
        ),
        _ProfileField(
          label: 'Village',
          value: userData?['village'] ?? 'Not set',
          icon: Icons.home_outlined,
        ),
        _ProfileField(
          label: 'Block',
          value: userData?['block'] ?? 'Not set',
          icon: Icons.map_outlined,
        ),
      ]),
    ];
  }

  Widget _buildSection(String role, String title, List<_ProfileField> fields) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: fields.asMap().entries.map((entry) {
                  final field = entry.value;
                  final isLast = entry.key == fields.length - 1;
                  return InkWell(
                    onTap: field.onTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(
                                    role,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  field.icon,
                                  color: _getRoleColor(role),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  field.label,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              if (field.onTap != null)
                                Switch.adaptive(
                                  value: field.value == 'On',
                                  activeTrackColor: _getRoleColor(role),
                                  onChanged: (_) => field.onTap!(),
                                )
                              else
                                Text(
                                  field.value,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            color: theme.dividerColor.withValues(alpha: 0.1),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, String role) {
    final liveUser = Provider.of<UserProvider>(context).user;
    final identifiers = {
      '_id': liveUser?['_id'],
      'uid': liveUser?['uid'],
      'mciNumber': liveUser?['mciNumber'],
      'ashaId': liveUser?['ashaId'],
      'panchayatId': liveUser?['panchayatId'],
    };

    return Column(
      children: [
        if (role == 'patient' || role == 'doctor') ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                final liveUser = Provider.of<UserProvider>(context, listen: false).user;
                Navigator.pushNamed(
                  context,
                  '/edit_profile',
                  arguments: liveUser,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getRoleColor(role),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              label: const Text(
                'Update Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Theme.of(ctx).cardTheme.color,
                    title: const Text('Delete Account?'),
                    content: const Text(
                      'This will permanently delete your account from Atlas. This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.emergencyRed),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await AuthService.deleteProfile(identifiers);
                    if (!context.mounted) return;
                    Provider.of<UserProvider>(context, listen: false).setUser({});
                    Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }


                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.emergencyRed),
                foregroundColor: AppColors.emergencyRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text(
                'Delete Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).setUser({});
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
              foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Logout of Gram Setu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileField {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });
}
