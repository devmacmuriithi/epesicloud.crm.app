import 'dart:convert';
import 'package:get/get.dart';
import '../utils/api_constants.dart';
import '../models/lead_model.dart';
import 'api_service.dart';

class LeadsService extends GetxService {
  final ApiService _api = Get.put(ApiService());

  Future<List<LeadModel>> getLeads() async {
    try {
      final responseBody = await _api.get(
        ApiConstants.baseUrl,
        ApiConstants.leads,
      );

      if (responseBody == null) return [];

      final List<dynamic> data = json.decode(responseBody);
      return data.map((json) => LeadModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching leads: $e');
      rethrow;
    }
  }

  Future<LeadModel> getLeadDetails(int id) async {
    try {
      final responseBody = await _api.get(
        ApiConstants.baseUrl,
        '${ApiConstants.leads}/$id',
      );

      final data = json.decode(responseBody);
      return LeadModel.fromJson(data);
    } catch (e) {
      print('Error fetching lead details: $e');
      rethrow;
    }
  }

  Future<LeadModel> createLead(Map<String, dynamic> leadData) async {
    try {
      final responseBody = await _api.post(
        ApiConstants.baseUrl,
        ApiConstants.leads,
        leadData,
      );

      final data = json.decode(responseBody);
      return LeadModel.fromJson(data);
    } catch (e) {
      print('Error creating lead: $e');
      rethrow;
    }
  }
}
