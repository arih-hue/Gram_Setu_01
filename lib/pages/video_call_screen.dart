import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_colors.dart';

class VideoCallScreen extends StatefulWidget {
  final Map<String, dynamic> consultation;

  const VideoCallScreen({super.key, required this.consultation});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  CameraController? _controller;
  bool _isPermissionGranted = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (cameraStatus.isGranted && micStatus.isGranted) {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          setState(() {
            _errorMessage = 'No cameras found on device.';
            _isLoading = false;
          });
          return;
        }

        // Use front camera if available
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: true,
        );

        await _controller!.initialize();
        
        if (mounted) {
          setState(() {
            _isPermissionGranted = true;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isPermissionGranted = false;
            _isLoading = false;
            _errorMessage = 'Camera and Microphone permissions are required for video calls.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing camera: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview or Status Message
          Positioned.fill(
            child: _buildMainContent(),
          ),

          // Overlay Info
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.consultation['patientName'] ?? 'Patient',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                  ),
                ),
                const Text(
                  'Video Consultation',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.mic,
                  onPressed: () {},
                  color: Colors.white24,
                ),
                const SizedBox(width: 30),
                _buildControlButton(
                  icon: Icons.call_end,
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.emergencyRed,
                  iconSize: 32,
                  padding: 20,
                ),
                const SizedBox(width: 30),
                _buildControlButton(
                  icon: Icons.videocam,
                  onPressed: () {},
                  color: Colors.white24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
    }

    if (!_isPermissionGranted) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 64),
            const SizedBox(height: 24),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initializeCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Grant Permissions'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text('Initializing...', style: TextStyle(color: Colors.white)));
    }

    return CameraPreview(_controller!);
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double iconSize = 24,
    double padding = 15,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
