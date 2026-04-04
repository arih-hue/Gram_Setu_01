import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Central constants for Gram Setu app.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── API ────────────────────────────────────────────────────────────────────
  /// 1. Set this to true if you want to connect to a friend's backend.
  static const bool useFriendBackend = false; 
  
  /// 2. Put your friend's Local IP here (found via `ipconfig` on their PC).
  static const String _friendIp = '192.168.52.31'; // <--- CHANGE THIS

  /// Base URL is resolved automatically:
  static String get baseUrl {
    if (useFriendBackend) return 'http://$_friendIp:3000';
    
    if (kIsWeb) {
      final host = Uri.base.host;
      return 'http://$host:3000';
    }
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://$_friendIp:3000';
  }

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration kRequestTimeout = Duration(seconds: 15);

  // ── Asset Paths ────────────────────────────────────────────────────────────
  /// Correct path for the app logo.
  static const String kLogoPath = 'assets/images/logo.png';
}
