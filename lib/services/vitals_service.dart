import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/models/vitals.dart';

class VitalsService {
  static final String _baseUrl = '${AppConstants.baseUrl}/api/vitals';

  static Future<bool> addVitals(Vitals vitals) async {
    try {
      final payload = json.encode(vitals.toJson());
      print('Uploading vitals to: $_baseUrl/add');
      print('Payload: $payload');

      final response = await http.post(
        Uri.parse('$_baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      print('Vitals upload response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 201;
    } catch (e) {
      print('FATAL Error adding vitals: $e');
      return false;
    }
  }

  static Future<List<Vitals>> getVitalsByPatientUID(String uid) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/patient/$uid'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Vitals.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching vitals: $e');
      return [];
    }
  }
}
