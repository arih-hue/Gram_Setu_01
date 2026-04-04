import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../services/api_service.dart';
import '../widgets/gram_app_bar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = true;
  List<dynamic> _leaderboard = [];
  String _sortOrder = 'desc'; // Default descending

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/doctor/leaderboard?order=$_sortOrder');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _leaderboard = (data['leaderboard'] as List? ?? []);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Leaderboard Fetch Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleSort() {
    setState(() {
      _sortOrder = (_sortOrder == 'desc') ? 'asc' : 'desc';
    });
    _fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;
    final doctorId = user?['_id'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GramAppBar(
        roleLabel: 'Doctor Standings',
        showBack: true,
        onSosTap: _toggleSort, // Reusing SOS slot for sort toggle to save space or adding custom action
      ),
      body: Column(
        children: [
          _buildSortHeader(theme),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchLeaderboard,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = _leaderboard[index];
                      final isMe = entry['doctorId'] == doctorId;
                      final rank = entry['rank'] ?? (index + 1);

                      return _buildLeaderboardTile(theme, rank, entry['doctorName'], entry['totalHours'] ?? '0', isMe);
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: AppColors.accentYellow, size: 20),
              const SizedBox(width: 8),
              Text('Monthly Rankings', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.displayLarge?.color)),
            ],
          ),
          InkWell(
            onTap: _toggleSort,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    _sortOrder == 'desc' ? Icons.trending_down : Icons.trending_up,
                    size: 14,
                    color: AppColors.primaryTeal,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sortOrder == 'desc' ? 'Highest Service First' : 'Lowest Service First',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(ThemeData theme, int rank, String name, dynamic hours, bool isMe) {
    final isTop3 = rank <= 3;
    final Color rankColor;
    if (rank == 1) rankColor = const Color(0xFFFFD700); // Gold
    else if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
    else if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze
    else rankColor = theme.dividerColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isMe ? AppColors.doctorGreen.withValues(alpha: 0.05) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? const Color(0xFFFFD700) : theme.dividerColor.withValues(alpha: 0.1),
          width: isMe ? 2.5 : 1.0,
        ),
        boxShadow: isMe ? [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.2), blurRadius: 10)] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isTop3 ? rankColor.withValues(alpha: 0.15) : theme.dividerColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isTop3 ? rankColor : theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          const SizedBox(width: 14),
          CircleAvatar(
             radius: 20,
             backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
             child: Icon(Icons.person, color: isMe ? AppColors.doctorGreen : AppColors.primaryTeal, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '$name (You)' : 'Dr. $name',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                    color: theme.textTheme.displayLarge?.color,
                  ),
                ),
                Text(
                  'Community Hero 🏅',
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${hours}h',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryTeal),
              ),
              const Text('Service Time', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
