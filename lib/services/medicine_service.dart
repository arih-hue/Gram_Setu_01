import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/models/medicine.dart';

class MedicineService {
  static final String _baseUrl = '${AppConstants.baseUrl}/api/medicine';

  static Future<List<Medicine>> getAllMedicines() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/all'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Medicine.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching medicines: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> browseMedicinesWithDetails() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/browse'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error browsing medicines: $e');
      return [];
    }
  }

  static Future<List<Medicine>> searchMedicines(String name) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search/$name'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Medicine.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching medicines: $e');
      return [];
    }
  }

  static Future<bool> addMedicine(Medicine medicine) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(medicine.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding medicine: $e');
      return false;
    }
  }

  static Future<bool> updateMedicine(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating medicine: $e');
      return false;
    }
  }

  static Future<bool> deleteMedicine(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/delete/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting medicine: $e');
      return false;
    }
  }
}
