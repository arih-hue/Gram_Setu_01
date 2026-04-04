import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/user_provider.dart';
import '../core/models/vitals.dart';
import '../services/api_service.dart';
import '../services/vitals_service.dart';
import '../widgets/gram_app_bar.dart';
import '../widgets/translated_text.dart';
import 'rppg_monitor_screen.dart';

class VitalsRecorderScreen extends StatefulWidget {
  const VitalsRecorderScreen({super.key});

  @override
  State<VitalsRecorderScreen> createState() => _VitalsRecorderScreenState();
}

class _VitalsRecorderScreenState extends State<VitalsRecorderScreen> {
  final _uidController = TextEditingController();
  bool _patientFound = false;
  bool _submitted = false;
  bool _isLoadingSearch = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _patientData;

  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _hrController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _sugarController = TextEditingController();
  final _weightController = TextEditingController();
  final _tempController = TextEditingController();
  final _symptomsController = TextEditingController();

  @override
  void dispose() {
    _uidController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _hrController.dispose();
    _spo2Controller.dispose();
    _sugarController.dispose();
    _weightController.dispose();
    _tempController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _searchUID() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) return;

    setState(() {
      _isLoadingSearch = true;
      _patientFound = false;
    });

    try {
      final response = await ApiService.get('/users/uid/$uid');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _patientData = data['user'];
          _patientFound = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TranslatedText('Patient not found with UID: $uid')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error searching patient')),
      );
    } finally {
      setState(() => _isLoadingSearch = false);
    }
  }

  Future<void> _submitVitals() async {
    if (!_patientFound) return;

    setState(() => _isSubmitting = true);

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final recordedBy = "${user?['role'] ?? 'Worker'} ${user?['name'] ?? ''}".trim();

    final vitals = Vitals(
      id: '',
      patientUID: _uidController.text.trim(),
      systolic: int.tryParse(_bpSystolicController.text),
      diastolic: int.tryParse(_bpDiastolicController.text),
      heartRate: int.tryParse(_hrController.text),
      spo2: int.tryParse(_spo2Controller.text),
      temperature: double.tryParse(_tempController.text),
      bloodSugar: int.tryParse(_sugarController.text),
      weight: double.tryParse(_weightController.text),
      notes: _symptomsController.text.trim(),
      recordedBy: recordedBy,
      timestamp: DateTime.now(),
    );

    final success = await VitalsService.addVitals(vitals);

    setState(() => _isSubmitting = false);

    if (success) {
      setState(() => _submitted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to record vitals. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptiveBackground(context),
      appBar: const GramAppBar(roleLabel: 'Record Vitals', showBack: true, showSos: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _submitted ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText('Record Patient Vitals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
        const SizedBox(height: 6),
        TranslatedText('Enter patient UID and record health data', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
        const SizedBox(height: 20),

        // UID Search
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _uidController,
                decoration: const InputDecoration(
                  hintText: 'Enter Patient UID',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primaryTeal),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _isLoadingSearch
                ? const SizedBox(width: 50, height: 50, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                : ElevatedButton(
                    onPressed: _searchUID,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                    child: TranslatedText('Search'),
                  ),
          ],
        ),

        if (_patientFound && _patientData != null) ...[
          const SizedBox(height: 16),

          // Patient info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_patientData!['name'] ?? 'Unknown Patient', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                    Text('Age: ${_patientData!['age'] ?? 'N/A'} • ${_patientData!['gender'] ?? 'N/A'} • Village: ${(_patientData!['location']?['village']) ?? 'N/A'}', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Vitals Form
          TranslatedText('Blood Pressure', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bpSystolicController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Systolic', suffixText: 'mmHg'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('/', style: TextStyle(fontSize: 20, color: AppColors.adaptiveTextSecondary(context))),
              ),
              Expanded(
                child: TextField(
                  controller: _bpDiastolicController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Diastolic', suffixText: 'mmHg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText('Heart Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _hrController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'BPM', suffixText: 'bpm'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText('SpO2', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _spo2Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '%', suffixText: '%'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText('Blood Sugar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _sugarController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'mg/dL', suffixText: 'mg/dL'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText('Weight', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'kg', suffixText: 'kg'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TranslatedText('Temperature', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
          const SizedBox(height: 8),
          TextField(
            controller: _tempController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Body temperature', suffixText: '°F'),
          ),
          const SizedBox(height: 16),

          TranslatedText('Symptoms / Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
          const SizedBox(height: 8),
          TextField(
            controller: _symptomsController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Any symptoms or observations...'),
          ),
          const SizedBox(height: 24),

          // rPPG Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.camera_front, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TranslatedText('Camera Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const TranslatedText('Auto-detect HR & SpO2', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RPPGMonitorScreen(patientUID: _uidController.text.trim()),
                      )
                    );

                    if (result != null && result is Map) {
                      setState(() {
                         if (result.containsKey('heartRate')) {
                           _hrController.text = result['heartRate'].toString();
                         }
                         if (result.containsKey('spo2')) {
                           _spo2Controller.text = result['spo2'].toString();
                         }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('rPPG scan integrated successfully'), backgroundColor: AppColors.primaryTeal),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                  ),
                  child: const TranslatedText('Scan', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 54,
            child: _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitVitals,
                    child: const TranslatedText('Submit Vitals'),
                  ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSuccessView() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final recordedBy = "${user?['role'] ?? 'Worker'} ${user?['name'] ?? ''}".trim();

    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        ),
        const SizedBox(height: 24),
        TranslatedText('Vitals Recorded!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
        const SizedBox(height: 8),
        TranslatedText('Data has been saved to the patient\'s health record.', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context)), textAlign: TextAlign.center),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.adaptiveSurface(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.adaptiveBorder(context))),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TranslatedText('Patient', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                Text(_patientData?['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TranslatedText('UID', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                Text(_uidController.text, style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TranslatedText('Recorded by', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                Text(recordedBy, style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TranslatedText('Time', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                const TranslatedText('Just now', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => setState(() {
              _submitted = false;
              _patientFound = false;
              _uidController.clear();
              _bpSystolicController.clear();
              _bpDiastolicController.clear();
              _hrController.clear();
              _spo2Controller.clear();
              _sugarController.clear();
              _weightController.clear();
              _tempController.clear();
              _symptomsController.clear();
              _patientData = null;
            }),
            child: const TranslatedText('Record Another Patient'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const TranslatedText('Back to Dashboard'),
          ),
        ),
      ],
    );
  }
}
