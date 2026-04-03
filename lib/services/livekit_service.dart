import 'dart:convert';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;
  Room? get room => _room;

  Future<Map<String, dynamic>?> getLiveKitToken(String roomName) async {
    try {
      final response = await ApiService.post('/livekit/token', {'roomName': roomName});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Log error

        return null;
      }
    } catch (e) {
      // Log exception

      return null;
    }
  }

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera]!.isGranted &&
           statuses[Permission.microphone]!.isGranted;
  }

  Future<Room?> connectToRoom(String url, String token) async {
    try {
      _room = Room();
      
      // Connect to the room
      await _room!.connect(url, token);
      
      // Publish local tracks
      await _room!.localParticipant?.setCameraEnabled(true);
      await _room!.localParticipant?.setMicrophoneEnabled(true);
      
      return _room;
    } catch (e) {
      // Log error

      return null;
    }
  }

  Future<void> disconnect() async {
    await _room?.disconnect();
    _room = null;
  }
}
