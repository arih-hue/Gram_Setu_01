import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/models/medicine_request.dart';

class MedicineRequestService {
  static final String _baseUrl = '${AppConstants.baseUrl}/api/medicine-request';

  static Future<List<MedicineRequest>> getRequests({String? pharmacistId}) async {
    try {
      final url = pharmacistId != null ? '$_baseUrl/all?pharmacistId=$pharmacistId' : '$_baseUrl/all';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['requests'] ?? [];
        return list.map((item) => MedicineRequest.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching medicine requests: $e');
      return [];
    }
  }

  static Future<bool> updateRequestStatus(String id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating medicine request status: $e');
      return false;
    }
  }

  static Future<bool> createRequest(MedicineRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating medicine request: $e');
      return false;
    }
  }
}
