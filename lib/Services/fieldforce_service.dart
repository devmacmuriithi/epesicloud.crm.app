import 'dart:convert';
import 'package:get/get.dart';
import '../models/fieldforce_models.dart';
import 'api_service.dart';
import 'crm_service.dart';

class FieldforceService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  Future<DailyRouteResponse> getDailyRoute() async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/route-plans/mine/today');
    return DailyRouteResponse.fromJson(jsonDecode(response));
  }

  Future<dynamic> startVisit(StartVisitRequest request) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/start', request.toJson());
    return jsonDecode(response);
  }
}
