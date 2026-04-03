import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _googleSignIn = GoogleSignIn();
  static const _storage = FlutterSecureStorage();

  // Use your laptop's local IP address (10.0.1.45) so friends' phones can connect over Wi-Fi.
  // 10.0.2.2 will ONLY work for YOUR local Android emulator, not physical devices or other laptops.
  static const String _baseUrl = 'http://10.0.1.45:3000';
  static const String _googleAuthUrl = '$_baseUrl/api/auth/google';

  static Future<Map<String, dynamic>?> signInWithGoogle(String role) async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Failed to obtain ID Token from Google');
      }

      print('🚀 Authenticating with Google at: $_baseUrl/api/auth/google');
      final response = await http.post(
        Uri.parse(_googleAuthUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken, 'role': role}),
      );

      final data = jsonDecode(response.body);
      print('📡 Backend Response (${response.statusCode}): $data');

      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Backend verification failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> registerPatient({
    required String name,
    required String uid,
    required String phone,
    required String location,
    required String gender,
    required String age,
    required String emergencyContact,
    required String password,
  }) async {
    try {
      final regUrl = '$_baseUrl/api/auth/register';
      print('🚀 Attempting Registration at: $regUrl');

      final response = await http
          .post(
            Uri.parse(regUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'uid': uid,
              'phone': phone,
              'location': location,
              'gender': gender,
              'age': age,
              'emergencyContact': emergencyContact,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          ); // Add a timeout to prevent infinite buffering

      final data = jsonDecode(response.body);
      print('📡 Registration Response (${response.statusCode}): $data');

      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> registerDoctor({
    required String name,
    required String mciId,
    required String phone,
    required String hospital,
    required String password,
  }) async {
    try {
      final regUrl = '$_baseUrl/api/auth/register';
      print('🚀 Attempting Registration at: $regUrl');

      final response = await http
          .post(
            Uri.parse(regUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'mciNumber': mciId,
              'phone': phone,
              'hospitalName': hospital,
              'password': password,
              'role': 'doctor',
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      print('📡 Doctor Registration Response (${response.statusCode}): $data');

      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> registerAsha({
    required String name,
    required String ashaId,
    required String phone,
    required String password,
  }) async {
    try {
      final regUrl = '$_baseUrl/api/auth/register';
      print('🚀 Attempting ASHA Registration at: $regUrl');

      final response = await http
          .post(
            Uri.parse(regUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'ashaId': ashaId,
              'phone': phone,
              'password': password,
              'role': 'asha',
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      print('📡 ASHA Registration Response (${response.statusCode}): $data');

      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> registerPanchayat({
    required String name,
    required String panchayatId,
    required String phone,
    required String village,
    required String block,
    required String position,
    required String password,
  }) async {
    try {
      final regUrl = '$_baseUrl/api/auth/register';
      print('🚀 Attempting Panchayat Registration at: $regUrl');
      
      final response = await http.post(
        Uri.parse(regUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'panchayatId': panchayatId,
          'phone': phone,
          'village': village,
          'block': block,
          'position': position,
          'password': password,
          'role': 'panchayat',
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      print('📡 Panchayat Registration Response (${response.statusCode}): $data');

      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final loginUrl = '$_baseUrl/api/auth/login';
      print('🚀 Attempting Login at: $loginUrl');

      final response = await http
          .post(
            Uri.parse(loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'identifier': identifier, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      print('📡 Login Response (${response.statusCode}): $data');

      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'jwt_token');
  }

  static Future<Map<String, dynamic>?> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final updateUrl = '$_baseUrl/api/auth/update';
      final response = await http
          .put(
            Uri.parse(updateUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      final resData = jsonDecode(response.body);

      if (response.statusCode == 200 && resData['success'] == true) {
        return resData['user'];
      } else {
        throw Exception(resData['message'] ?? 'Update failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> deleteProfile(Map<String, dynamic> identifiers) async {
    try {
      final deleteUrl = '$_baseUrl/api/auth/delete';
      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(identifiers),
          )
          .timeout(const Duration(seconds: 15));

      final resData = jsonDecode(response.body);

      if (response.statusCode == 200 && resData['success'] == true) {
        await signOut();
        return true;
      } else {
        throw Exception(resData['message'] ?? 'Deletion failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static String? getRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payloadStr = parts[1];
      while (payloadStr.length % 4 != 0) {
        payloadStr += '=';
      }
      final payloadMap = jsonDecode(utf8.decode(base64Url.decode(payloadStr)));
      return payloadMap['role'];
    } catch (e) {
      return null;
    }
  }
}
