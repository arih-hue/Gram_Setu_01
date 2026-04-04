import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';

class VitalsRecorderScreen extends StatefulWidget {
  const VitalsRecorderScreen({super.key});

  @override
  State<VitalsRecorderScreen> createState() => _VitalsRecorderScreenState();
}

class _VitalsRecorderScreenState extends State<VitalsRecorderScreen> {
  final _uidController = TextEditingController();
  bool _patientFound = false;
  bool _submitted = false;

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
        Text('Record Patient Vitals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
        const SizedBox(height: 6),
        Text('Enter patient UID and record health data', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context))),
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
            ElevatedButton(
              onPressed: () => setState(() => _patientFound = true),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
              child: Text('Search'),
            ),
          ],
        ),

        if (_patientFound) ...[
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
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ramesh Yadav', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
                    Text('Age: 42 • Male • Village: Rampur', style: TextStyle(fontSize: 12, color: AppColors.adaptiveTextSecondary(context))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Vitals Form
          Text('Blood Pressure', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
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
                padding: EdgeInsets.symmetric(horizontal: 8),
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
                    Text('Heart Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
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
                    Text('SpO2', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
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
                    Text('Blood Sugar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
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
                    Text('Weight', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
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

          Text('Temperature', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
          const SizedBox(height: 8),
          TextField(
            controller: _tempController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Body temperature', suffixText: '°F'),
          ),
          const SizedBox(height: 16),

          Text('Symptoms / Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adaptiveTextPrimary(context))),
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
                      Text('Camera Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Auto-detect HR & SpO2', style: TextStyle(color: AppColors.adaptiveTextSecondary(context), fontSize: 12)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _hrController.text = '76';
                      _spo2Controller.text = '97';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('rPPG scan complete: HR 76, SpO2 97%'), backgroundColor: AppColors.primaryTeal),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text('Scan', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => setState(() => _submitted = true),
              child: const Text('Submit Vitals'),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        ),
        const SizedBox(height: 24),
        Text('Vitals Recorded!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.adaptiveTextPrimary(context))),
        const SizedBox(height: 8),
        Text('Data has been saved to the patient\'s health record.', style: TextStyle(fontSize: 14, color: AppColors.adaptiveTextSecondary(context)), textAlign: TextAlign.center),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.adaptiveSurface(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.adaptiveBorder(context))),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Patient', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                Text('Ramesh Yadav', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('UID', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                Text('UID003829', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Recorded by', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                Text('ASHA Worker Sunita', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Time', style: TextStyle(color: AppColors.adaptiveTextSecondary(context))),
                Text('Just now', style: TextStyle(fontWeight: FontWeight.w600)),
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
            }),
            child: const Text('Record Another Patient'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Dashboard'),
          ),
        ),
      ],
    );
  }
}
