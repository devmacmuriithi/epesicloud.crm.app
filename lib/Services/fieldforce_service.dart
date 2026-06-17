import 'dart:convert';
import 'package:get/get.dart';
import '../models/fieldforce_models.dart';
import '../models/crm_models.dart';
import '../models/location_models.dart';
import 'api_service.dart';
import 'crm_service.dart';

class FieldforceService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<DailyRouteResponse> getDailyRoute() async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/route-plans/mine/today');
    return DailyRouteResponse.fromJson(jsonDecode(response));
  }

  Future<List<VisitRecord>> getVisits({int? agentId}) async {
    final Map<String, dynamic> params = {};
    if (agentId != null) params['agentId'] = agentId.toString();
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits', filters: params);
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => VisitRecord.fromJson(e)).toList();
  }

  Future<VisitRecord> getVisit(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId');
    return VisitRecord.fromJson(jsonDecode(response));
  }

  Future<Map<String, dynamic>> startVisit(StartVisitRequest request) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/start', request.toJson());
    return jsonDecode(response);
  }

  Future<Map<String, dynamic>> updateCheckInGps(
    int visitId, {
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{};
    if (latitude != null) body['checkInLatitude'] = latitude;
    if (longitude != null) body['checkInLongitude'] = longitude;
    final response = await _apiService.post(
      CrmService.baseUrl,
      '/api/visits/$visitId/checkin',
      body,
    );
    return jsonDecode(response);
  }

  Future<Map<String, dynamic>> checkOutVisit(
    int visitId, {
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (latitude != null) 'checkOutLatitude': latitude,
      if (longitude != null) 'checkOutLongitude': longitude,
    };
    final response = await _apiService.post(
      CrmService.baseUrl,
      '/api/visits/$visitId/checkout',
      body,
    );
    return jsonDecode(response);
  }

  Future<List<AccountModel>> getAccounts() async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/accounts');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => AccountModel.fromJson(e)).toList();
  }

  // Visit Workspace Sub-resources

  Future<List<VisitOrder>> getVisitOrders(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId/orders');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => VisitOrder.fromJson(e)).toList();
  }

  Future<VisitOrder> addVisitOrder(int visitId, Map<String, dynamic> data) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/$visitId/orders', data);
    return VisitOrder.fromJson(jsonDecode(response));
  }

  Future<List<CompetitorRate>> getVisitCompetitorRates(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId/competitor-rates');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => CompetitorRate.fromJson(e)).toList();
  }

  Future<CompetitorRate> addCompetitorRate(int visitId, Map<String, dynamic> data) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/$visitId/competitor-rates', data);
    return CompetitorRate.fromJson(jsonDecode(response));
  }

  Future<List<OutletRate>> getVisitOutletRates(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId/outlet-rates');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => OutletRate.fromJson(e)).toList();
  }

  Future<OutletRate> addOutletRate(int visitId, Map<String, dynamic> data) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/$visitId/outlet-rates', data);
    return OutletRate.fromJson(jsonDecode(response));
  }

  Future<List<Complaint>> getVisitComplaints(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId/complaints');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => Complaint.fromJson(e)).toList();
  }

  Future<Complaint> addComplaint(int visitId, Map<String, dynamic> data) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/$visitId/complaints', data);
    return Complaint.fromJson(jsonDecode(response));
  }

  Future<List<VisitPhoto>> getVisitPhotos(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId/photos');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => VisitPhoto.fromJson(e)).toList();
  }

  Future<VisitPhoto> addVisitPhoto(int visitId, Map<String, dynamic> data) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/$visitId/photos', data);
    return VisitPhoto.fromJson(jsonDecode(response));
  }

  Future<Map<String, dynamic>> uploadPhoto(int visitId, String filePath) async {
    final response = await _apiService.uploadMultipartFile(
      CrmService.baseUrl,
      '/api/visits/$visitId/photos/upload',
      'photo',
      filePath,
    );
    return jsonDecode(response);
  }

  // Stock Availability
  Future<List<StockAvailability>> getStockAvailability(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId/stock-availability');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => StockAvailability.fromJson(e)).toList();
  }

  Future<StockAvailability> addStockAvailability(int visitId, Map<String, dynamic> data) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/$visitId/stock-availability', data);
    return StockAvailability.fromJson(jsonDecode(response));
  }

  // Shelf Placements
  Future<List<ShelfPlacement>> getShelfPlacements(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId/shelf-placements');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => ShelfPlacement.fromJson(e)).toList();
  }

  Future<ShelfPlacement> addShelfPlacement(int visitId, Map<String, dynamic> data) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/$visitId/shelf-placements', data);
    return ShelfPlacement.fromJson(jsonDecode(response));
  }

  // Promotion Audits
  Future<List<PromotionAudit>> getPromotionAudits(int visitId) async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/visits/$visitId/promotion-audits');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => PromotionAudit.fromJson(e)).toList();
  }

  Future<PromotionAudit> addPromotionAudit(int visitId, Map<String, dynamic> data) async {
    final response = await _apiService.post(CrmService.baseUrl, '/api/visits/$visitId/promotion-audits', data);
    return PromotionAudit.fromJson(jsonDecode(response));
  }

  // PATCH / DELETE (where supported by backend)

  Future<Complaint> patchComplaint(int complaintId, Map<String, dynamic> data) async {
    final response = await _apiService.patch(CrmService.baseUrl, '/api/complaints/$complaintId', data);
    return Complaint.fromJson(jsonDecode(response));
  }

  Future<void> deleteComplaint(int complaintId) async {
    // Note: Assuming DELETE /api/complaints/:id exists or is mapped to a logical delete
    await _apiService.delete(CrmService.baseUrl, '/api/complaints/$complaintId', {});
  }

  Future<void> confirmSalesOrder(int orderItemId) async {
    await _apiService.patch(CrmService.baseUrl, '/api/sales-orders/$orderItemId/confirm', {});
  }

  // ─── Location Tracking ──────────────────────────────────────────────────

  Future<void> postLocationPing(Map<String, dynamic> data) async {
    await _apiService.post(CrmService.baseUrl, '/api/locations', data);
  }

  Future<List<LiveLocationEntry>> getLiveLocationFeed() async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/locations/live');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => LiveLocationEntry.fromJson(e)).toList();
  }

  Future<List<AccountMapItem>> getAccountsMap() async {
    final response = await _apiService.get(CrmService.baseUrl, '/api/accounts/map');
    final List<dynamic> data = jsonDecode(response);
    return data.map((e) => AccountMapItem.fromJson(e)).toList();
  }
}
