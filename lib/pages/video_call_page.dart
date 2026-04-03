import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/livekit_service.dart';

class VideoCallPage extends StatefulWidget {
  final String roomName;

  const VideoCallPage({super.key, required this.roomName});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  final LiveKitService _livekitService = LiveKitService();

  bool _isMicEnabled = true;
  bool _isVideoEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupCall();
  }

  Future<void> _setupCall() async {
    // 1. Request permissions
    bool permissionsGranted = await _livekitService.requestPermissions();
    if (!permissionsGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera and Microphone permissions are required')),
        );
        Navigator.pop(context);
      }
      return;
    }

    // 2. Fetch token
    final result = await _livekitService.getLiveKitToken(widget.roomName);
    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch call token')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final token = result['token'];
    final url = result['serverUrl'];

    // 3. Connect to room
    _room = await _livekitService.connectToRoom(url, token);
    if (_room == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to video room')),
        );
        Navigator.pop(context);
      }
      return;
    }

    _listener = _room!.createListener();
    _room!.addListener(_onRoomEvent);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onRoomEvent() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _room?.removeListener(_onRoomEvent);
    _listener?.dispose();
    _livekitService.disconnect();
    super.dispose();
  }

  void _toggleMic() {
    setState(() {
      _isMicEnabled = !_isMicEnabled;
      _room?.localParticipant?.setMicrophoneEnabled(_isMicEnabled);
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
      _room?.localParticipant?.setCameraEnabled(_isVideoEnabled);
    });
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                'Connecting to Secure Consultation...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ).animate().fadeIn(duration: 500.ms),
            ],
          ),
        ),
      );
    }

    final remoteParticipants = _room!.remoteParticipants.values.toList();
    final firstRemote = remoteParticipants.isNotEmpty ? remoteParticipants.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Remote Video (Background)
          if (firstRemote != null && firstRemote.videoTrackPublications.isNotEmpty)
            Positioned.fill(
              child: VideoTrackRenderer(
                firstRemote.videoTrackPublications.first.track as VideoTrack,
                fit: VideoViewFit.cover,
              ).animate().fadeIn(duration: 800.ms),
            )
          else
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.person, size: 50, color: Colors.white38),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Waiting for other participant...',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Top Header (Room info)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 1000.ms)
                       .then()
                       .scale(begin: const Offset(1.5, 1.5), end: const Offset(1, 1), duration: 1000.ms),
                      const SizedBox(width: 8),
                      Text(
                        'Live Consultation',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {}, // Switch camera maybe?
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black26),
                ),
              ],
            ),
          ).animate().slideY(begin: -1, end: 0, duration: 600.ms, curve: Curves.easeOutBack),

          // Local Video (Floating)
          if (_isVideoEnabled)
            Positioned(
              top: 120,
              right: 20,
              child: Container(
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _room!.localParticipant?.videoTrackPublications.isNotEmpty == true
                      ? VideoTrackRenderer(
                          _room!.localParticipant!.videoTrackPublications.first.track as VideoTrack,
                          fit: VideoViewFit.cover,
                        )
                      : Container(color: Colors.black54),
                ),
              ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlCircleButton(
                  icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                  isActive: _isMicEnabled,
                  onTap: _toggleMic,
                ),
                const SizedBox(width: 20),
                _ControlCircleButton(
                  icon: Icons.call_end,
                  isActive: false,
                  isDestructive: true,
                  onTap: _endCall,
                  size: 70,
                ),
                const SizedBox(width: 20),
                _ControlCircleButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  isActive: _isVideoEnabled,
                  onTap: _toggleVideo,
                ),
              ],
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}

class _ControlCircleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback onTap;
  final double size;

  const _ControlCircleButton({
    required this.icon,
    required this.isActive,
    this.isDestructive = false,
    required this.onTap,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDestructive
              ? Colors.redAccent
              : (isActive ? Colors.white24 : Colors.white10),
          border: Border.all(
            color: isDestructive
                ? Colors.redAccent.withValues(alpha: 0.5)
                : (isActive ? Colors.white38 : Colors.white12),
            width: 1,
          ),
          boxShadow: [
            if (isDestructive)
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive || isDestructive ? Colors.white : Colors.white38,
          size: size * 0.5,
        ),
      ),
    );
  }
}
