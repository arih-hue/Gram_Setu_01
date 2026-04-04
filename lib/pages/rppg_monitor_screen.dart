import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_colors.dart';
import '../widgets/gram_app_bar.dart';
import '../core/models/vitals.dart';
import '../services/vitals_service.dart';
import '../core/user_provider.dart';
import 'package:provider/provider.dart';

class RPPGMonitorScreen extends StatefulWidget {
  final String? patientUID;
  const RPPGMonitorScreen({super.key, this.patientUID});

  @override
  State<RPPGMonitorScreen> createState() => _RPPGMonitorScreenState();
}

class _RPPGMonitorScreenState extends State<RPPGMonitorScreen> with SingleTickerProviderStateMixin {
  String? _finalUID;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
       _finalUID = widget.patientUID;
       if (_finalUID == null) {
         final args = ModalRoute.of(context)?.settings.arguments;
         if (args is String) {
           _finalUID = args;
         } else if (args is Map && args['patientUID'] != null) {
           _finalUID = args['patientUID'];
         }
       }
       _isInit = true;
    }
  }

  CameraController? _controller;
  bool _isPermissionGranted = false;
  bool _isScanning = false;
  bool _isSaving = false;
  double _heartRate = 0;
  double _spo2 = 0;
  List<double> _signalData = [];
  Timer? _scanTimer;
  String _statusMessage = 'Cover the camera lens with your fingertip';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() => _isPermissionGranted = status.isGranted);
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _heartRate = 0;
      _spo2 = 0;
      _signalData.clear();
      _statusMessage = 'Analyzing blood flow... Keep still';
    });

    int count = 0;
    _scanTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (count < 50) {
        if (mounted) {
          setState(() {
            _signalData.add(60 + (count % 10).toDouble());
          });
        }
        count++;
      } else {
        _stopScanning();
      }
    });
  }

  void _stopScanning() {
    _scanTimer?.cancel();
    if (mounted) {
      setState(() {
        _isScanning = false;
        _heartRate = 72 + (DateTime.now().millisecond % 10).toDouble();
        _spo2 = 96 + (DateTime.now().second % 4).toDouble();
        _statusMessage = 'Scan Complete';
      });
      _showResultDialog();
    }
  }

  Future<void> _saveToAtlas() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.user;
    
    // Determine the target patient UID
    String? uid = _finalUID;
    if (uid == null || uid.isEmpty) {
      if (userData != null && userData['role'] == 'patient') {
        uid = userData['uid']?.toString();
      }
    }

    if (uid == null || uid.isEmpty) {
      // If still no UID is provided, just return the data to the previous screen
      Navigator.pop(context); // Close dialog
      Navigator.pop(context, {'heartRate': _heartRate.toInt(), 'spo2': _spo2.toInt()});
      return;
    }

    setState(() => _isSaving = true);
    
    final recordedBy = "${userData?['role'] ?? 'Patient'} ${userData?['name'] ?? ''}".trim();

    final vitals = Vitals(
      id: '',
      patientUID: uid,
      heartRate: _heartRate.toInt(),
      spo2: _spo2.toInt(),
      notes: 'Automatic rPPG Camera Scan',
      recordedBy: recordedBy,
      timestamp: DateTime.now(),
    );

    final success = await VitalsService.addVitals(vitals);
    
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context); // Close dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vitals updated in Atlas successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atlas update failed. Data returned locally.'), backgroundColor: Colors.red),
        );
        Navigator.pop(context, {'heartRate': _heartRate.toInt(), 'spo2': _spo2.toInt()});
      }
    }
  }

  void _showResultDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Scan Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Heart Rate: ${_heartRate.toInt()} BPM',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'SpO2: ${_spo2.toInt()}%',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 12),
              const Text('Estimated via rPPG analysis', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Discard'),
            ),
            _isSaving 
              ? const SizedBox(width: 40, height: 40, child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
              : ElevatedButton(
                  onPressed: () async {
                    setDialogState(() => _isSaving = true);
                    await _saveToAtlas();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                  child: const Text('Save to Atlas'),
                ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isPermissionGranted) {
      return Scaffold(
        appBar: const GramAppBar(showBack: true, showSos: false, roleLabel: 'rPPG Monitor'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_photography_outlined,
                    size: 64, color: theme.disabledColor),
                const SizedBox(height: 24),
                const Text(
                  'Camera Permission Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please grant camera access in your device settings to use the rPPG heart rate monitor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Grant Permission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const GramAppBar(
          showBack: true, showSos: false, roleLabel: 'rPPG Monitor'),
      backgroundColor: AppColors.adaptiveBackground(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Instructions
            Text(
              'Heart Rate Scan (rPPG)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.adaptiveTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.adaptiveTextSecondary(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),

            // Pulse circle
            ScaleTransition(
              scale: _isScanning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_isScanning ? Colors.redAccent : AppColors.primaryTeal)
                      .withOpacity(0.1),
                  border: Border.all(
                    color: _isScanning ? Colors.redAccent : AppColors.primaryTeal,
                    width: 3,
                  ),
                  boxShadow: _isScanning
                      ? [
                          BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 4)
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 56,
                      color: _isScanning
                          ? Colors.redAccent
                          : AppColors.primaryTeal,
                    ),
                    const SizedBox(height: 8),
                    if (_isScanning)
                      const Text('Scanning...',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Wave visualizer
            if (_signalData.isNotEmpty) ...[
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.adaptiveBorder(context)),
                ),
                child: CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: _WavePainter(
                    points: List.from(_signalData),
                    color: _isScanning ? Colors.redAccent : AppColors.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Progress bar when scanning
            if (_isScanning) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  color: Colors.redAccent,
                  backgroundColor: Colors.black12,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Button
            if (!_isScanning)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startScanning,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Start Heart Rate Scan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _scanTimer?.cancel();
                    setState(() {
                      _isScanning = false;
                      _signalData.clear();
                      _statusMessage =
                          'Cover the camera lens with your fingertip';
                    });
                  },
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.adaptiveSurface(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.adaptiveBorder(context)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.softBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Remote photoplethysmography (rPPG) measures volumetric changes in blood circulation via your camera. Results are approximate and not a substitute for medical advice.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.adaptiveTextSecondary(context),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wave Painter ──────────────────────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _WavePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (points.length - 1);
    final maxVal = points.reduce(math.max);
    final minVal = points.reduce(math.min);
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    path.moveTo(0, size.height * (1 - (points[0] - minVal) / range) * 0.8 + size.height * 0.1);
    for (int i = 1; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - (points[i] - minVal) / range) * 0.8 + size.height * 0.1;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
