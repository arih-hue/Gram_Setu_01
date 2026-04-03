/// Central constants for Gram Setu app.
/// Change [kBaseUrl] to match your backend server's IP/host.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── API ────────────────────────────────────────────────────────────────────
  /// Base URL of the Node.js backend.
  /// ✅ Android Emulator (running on same PC) → use "http://10.0.2.2:3000"
  /// ✅ Flutter Web (browser on same PC)     → use "http://localhost:3000"
  /// ✅ Physical Phone (same Wi-Fi)          → use your Laptop's Local IP (e.g., http://192.168.1.15:3000)
  static const String kBaseUrl = 'http://192.168.52.31:3000';


  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration kRequestTimeout = Duration(seconds: 15);

  // ── Asset Paths ────────────────────────────────────────────────────────────
  /// Correct path for the app logo.
  /// In pubspec.yaml declare:  assets: - assets/images/
  static const String kLogoPath = 'assets/images/logo.png';
}

