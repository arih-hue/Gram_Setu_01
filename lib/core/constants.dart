import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Central constants for Gram Setu app.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── API ────────────────────────────────────────────────────────────────────
  /// 1. If true, all systems (emulators, other PCs, phones) connect to the host below.
  static const bool usePhysicalIp = true; 
  
  /// 2. The LAN IP of the computer running the backend.
  static const String _hostIp = '192.168.53.234'; 

  /// Base URL is resolved automatically based on the platform:
  static String get baseUrl {
    if (usePhysicalIp) return 'http://$_hostIp:3000';
    
    if (kIsWeb) {
      // Browsers use the same host they are served from.
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      return 'http://$host:3000';
    }
    
    if (Platform.isAndroid) {
      // Official Android Emulator uses 10.0.2.2 for host loopback.
      return 'http://10.0.2.2:3000';
    }
    
    if (Platform.isIOS || Platform.isMacOS) {
      // iOS simulators share the host network stack.
      return 'http://localhost:3000';
    }

    // Default fallback for physical devices or other platforms.
    return 'http://$_hostIp:3000';
  }

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration kRequestTimeout = Duration(seconds: 15);

  // ── Asset Paths ────────────────────────────────────────────────────────────
  /// Correct path for the app logo.
  static const String kLogoPath = 'assets/images/logo.png';
}
