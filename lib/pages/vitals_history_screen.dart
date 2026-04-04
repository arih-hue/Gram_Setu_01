import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/models/vitals.dart';
import '../services/vitals_service.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/translated_text.dart';
import 'package:intl/intl.dart';

class VitalsHistoryScreen extends StatefulWidget {
  final String patientUID;
  final String? patientName;

  const VitalsHistoryScreen({
    super.key,
    required this.patientUID,
    this.patientName,
  });

  @override
  State<VitalsHistoryScreen> createState() => _VitalsHistoryScreenState();
}

class _VitalsHistoryScreenState extends State<VitalsHistoryScreen> {
  bool _isLoading = true;
  List<Vitals> _records = [];

  @override
  void initState() {
    super.initState();
    _loadVitals();
  }

  Future<void> _loadVitals() async {
    setState(() => _isLoading = true);
    final records = await VitalsService.getVitalsByPatientUID(widget.patientUID);
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: GramAppBar(
        roleLabel: widget.patientName != null ? 'Vitals: ${widget.patientName}' : 'Vitals History',
        showBack: true,
        showSos: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadVitals,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
                ? _buildEmptyState()
                : _buildVitalsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: AppColors.adaptiveTextSecondary(context).withOpacity(0.3)),
          const SizedBox(height: 16),
          TranslatedText('No vitals recorded yet.', style: TextStyle(fontSize: 16, color: AppColors.adaptiveTextSecondary(context))),
        ],
      ),
    );
  }

  Widget _buildVitalsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return _buildVitalsCard(record);
      },
    );
  }

  Widget _buildVitalsCard(Vitals record) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(record.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryTeal)),
              if (record.recordedBy.isNotEmpty)
                TranslatedText('By: ${record.recordedBy}', style: TextStyle(fontSize: 10, color: AppColors.adaptiveTextSecondary(context))),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (record.systolic != null && record.diastolic != null)
                _buildSmallVitalItem(Icons.speed, 'BP', '${record.systolic}/${record.diastolic}', 'mmHg'),
              if (record.heartRate != null)
                _buildSmallVitalItem(Icons.favorite, 'HR', '${record.heartRate}', 'bpm'),
              if (record.spo2 != null)
                _buildSmallVitalItem(Icons.water_drop, 'SpO2', '${record.spo2}', '%'),
              if (record.temperature != null)
                _buildSmallVitalItem(Icons.thermostat, 'Temp', '${record.temperature}', '°F'),
              if (record.bloodSugar != null)
                _buildSmallVitalItem(Icons.bloodtype, 'Sugar', '${record.bloodSugar}', 'mg/dL'),
              if (record.weight != null)
                _buildSmallVitalItem(Icons.monitor_weight, 'Weight', '${record.weight}', 'kg'),
            ],
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            TranslatedText('Notes:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextSecondary(context))),
            const SizedBox(height: 4),
            Text(record.notes, style: TextStyle(fontSize: 13, color: AppColors.adaptiveTextPrimary(context))),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallVitalItem(IconData icon, String label, String value, String unit) {
    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 3,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.adaptiveBackground(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryTeal),
          const SizedBox(height: 4),
          TranslatedText(label, style: TextStyle(fontSize: 10, color: AppColors.adaptiveTextSecondary(context))),
          Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
