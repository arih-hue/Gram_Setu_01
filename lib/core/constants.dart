import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Central constants for Gram Setu app.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── API ────────────────────────────────────────────────────────────────────
  /// Your laptop's LAN IP for physical device testing (e.g., 192.168.1.x).
  /// Run `ipconfig` on Windows to find it.
  static const String _lanIp = '192.168.52.31';

  /// Base URL is resolved automatically per platform:
  ///   • Flutter Web          → http://<host>:3000 (auto-detects host)
  ///   • Android Emulator     → http://10.0.2.2:3000
  ///   • Physical Device      → http://<_lanIp>:3000
  static String get baseUrl {
    if (kIsWeb) {
      // Auto-detects the host the Flutter web app was served from.
      // Since the app and backend run on the same machine, this always points
      // to the right server — whether accessed from localhost OR via LAN IP.
      final host = Uri.base.host; // e.g. "localhost" or "192.168.52.31"
      return 'http://$host:3000';
    }
    // Note: Platform.isAndroid will throw on web, but we handle kIsWeb above.
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://$_lanIp:3000';
  }

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration kRequestTimeout = Duration(seconds: 15);

  // ── Asset Paths ────────────────────────────────────────────────────────────
  /// Correct path for the app logo.
  static const String kLogoPath = 'assets/images/logo.png';
}
