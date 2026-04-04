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
  Map<String, dynamic>? _myStats;
  bool _isAscending = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    final doctorId = user['id'] ?? user['_id'];

    setState(() => _isLoading = true);
    try {
      final order = _isAscending ? 'asc' : 'desc';
      final response = await ApiService.get('/doctor/leaderboard?order=$order');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _leaderboard = (data['leaderboard'] as List? ?? []);
            final index = _leaderboard.indexWhere((d) => d['doctorId'] == doctorId);
            if (index != -1) {
              _myStats = _leaderboard[index];
            } else {
              _myStats = null;
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Handle fetch error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
    _fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;
    final doctorId = user?['id'] ?? user?['_id'];

    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(
        roleLabel: 'Rewards & Recognition',
        showBack: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildMySummaryHeader(theme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LEADERBOARD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.adaptiveTextSecondary(context))),
                    TextButton.icon(
                       onPressed: _toggleOrder,
                       icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                       label: Text(_isAscending ? 'Ascending' : 'Descending', style: const TextStyle(fontSize: 12)),
                       style: TextButton.styleFrom(foregroundColor: AppColors.primaryTeal),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchLeaderboard,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = (index < _leaderboard.length) ? _leaderboard[index] : {};
                      final isMe = entry['doctorId'] == doctorId;
                      final rank = entry['rank'] ?? (index + 1);

                      return _buildLeaderboardTile(theme, rank, entry, isMe);
                    },
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildMySummaryHeader(ThemeData theme) {
    if (_myStats == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        border: Border(bottom: BorderSide(color: AppColors.adaptiveBorder(context))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('My Rank', '#${_myStats!['rank'] ?? '-'}', Icons.leaderboard_outlined, AppColors.accentYellow),
              Container(height: 40, width: 1, color: AppColors.adaptiveBorder(context)),
              _summaryItem('Total Hours', '${_myStats!['totalHours'] ?? 0}h', Icons.schedule_outlined, AppColors.softBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
      ],
    );
  }

  Widget _buildLeaderboardTile(ThemeData theme, int rank, Map<String, dynamic> entry, bool isMe) {
    final bool isChampion = rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? AppColors.accentYellow.withOpacity(0.05) : AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? AppColors.accentYellow : AppColors.adaptiveBorder(context),
          width: isMe ? 2 : 1,
        ),
        boxShadow: isMe ? [BoxShadow(color: AppColors.accentYellow.withOpacity(0.1), blurRadius: 10)] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isChampion ? AppColors.accentYellow : AppColors.adaptiveBackground(context),
              shape: BoxShape.circle,
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isChampion ? Colors.black : AppColors.adaptiveTextPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 20,
            backgroundColor: isMe ? AppColors.accentYellow.withOpacity(0.2) : AppColors.primaryTeal.withOpacity(0.1),
            child: Icon(Icons.person, color: isMe ? AppColors.adaptiveTextPrimary(context) : AppColors.primaryTeal, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isMe ? '${entry['doctorName'] ?? ''} (Me)' : 'Dr. ${entry['doctorName'] ?? ''}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context)),
                    ),
                    if (isChampion) ...[
                      const SizedBox(width: 6),
                      const Text('Champion 🏆', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentYellow)),
                    ]
                  ],
                ),
                Text(
                  entry['hospital'] ?? 'District Hospital',
                  style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry['totalHours'] ?? 0}h',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryTeal),
              ),
              const Text('Contribution', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
