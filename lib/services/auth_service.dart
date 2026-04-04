import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class AuthService {
  static final _googleSignIn = GoogleSignIn();
  static const _storage = FlutterSecureStorage();

  static String get _baseUrl => AppConstants.baseUrl;
  static String get _googleAuthUrl => '$_baseUrl/api/auth/google';

  static Exception _handleError(Object e) {
    if (e is TimeoutException) {
      return Exception('Server unreachable. Please check your network connection.');
    }
    if (e is Exception) return e;
    return Exception(e.toString());
  }

  static Future<Map<String, dynamic>?> registerPatient({
    required String name,
    required String uid,
    required String phone,
    required String village,
    required String block,
    required String fullLocation,
    required String gender,
    required String age,
    required String emergencyContact,
    required String password,
  }) async {
    try {
      final regUrl = '$_baseUrl/api/auth/register';
      final response = await http.post(
        Uri.parse(regUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'uid': uid,
          'phone': phone,
          'village': village,
          'block': block,
          'location': fullLocation,
          'gender': gender,
          'age': age,
          'emergencyContact': emergencyContact,
          'password': password,
        }),
      ).timeout(AppConstants.kRequestTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>?> registerDoctor({
    required String name,
    required String mciId,
    required String phone,
    required String hospital,
    required String village,
    required String block,
    required String fullLocation,
    required String password,
  }) async {
    try {
      final regUrl = '$_baseUrl/api/auth/register';
      final response = await http.post(
        Uri.parse(regUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'mciNumber': mciId,
          'phone': phone,
          'hospitalName': hospital,
          'village': village,
          'block': block,
          'location': fullLocation,
          'password': password,
          'role': 'doctor',
        }),
      ).timeout(AppConstants.kRequestTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>?> registerAsha({
    required String name,
    required String ashaId,
    required String phone,
    required String village,
    required String block,
    required String fullLocation,
    required String password,
  }) async {
    try {
      final regUrl = '$_baseUrl/api/auth/register';
      final response = await http.post(
        Uri.parse(regUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'ashaId': ashaId,
          'phone': phone,
          'village': village,
          'block': block,
          'location': fullLocation,
          'password': password,
          'role': 'asha',
        }),
      ).timeout(AppConstants.kRequestTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>?> registerPanchayat({
    required String name,
    required String panchayatId,
    required String phone,
    required String village,
    required String block,
    required String fullLocation,
    required String position,
    required String password,
  }) async {
    try {
      final regUrl = '$_baseUrl/api/auth/register';
      final response = await http.post(
        Uri.parse(regUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'panchayatId': panchayatId,
          'phone': phone,
          'village': village,
          'block': block,
          'location': fullLocation,
          'position': position,
          'password': password,
          'role': 'panchayat',
        }),
      ).timeout(AppConstants.kRequestTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>?> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final loginUrl = '$_baseUrl/api/auth/login';
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      ).timeout(AppConstants.kRequestTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        return data['user'];
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'jwt_token');
  }

  static Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> data) async {
    try {
      final updateUrl = '$_baseUrl/api/auth/update';
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(AppConstants.kRequestTimeout);

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 && resData['success'] == true) {
        return resData['user'];
      } else {
        throw Exception(resData['message'] ?? 'Update failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<bool> deleteProfile(Map<String, dynamic> identifiers) async {
    try {
      final deleteUrl = '$_baseUrl/api/auth/delete';
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(identifiers),
      ).timeout(AppConstants.kRequestTimeout);

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 && resData['success'] == true) {
        await signOut();
        return true;
      } else {
        throw Exception(resData['message'] ?? 'Deletion failed');
      }
    } catch (e) {
      throw _handleError(e);
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
      while (payloadStr.length % 4 != 0) payloadStr += '=';
      final payloadMap = jsonDecode(utf8.decode(base64Url.decode(payloadStr)));
      return payloadMap['role'];
    } catch (e) {
      return null;
    }
  }
}
