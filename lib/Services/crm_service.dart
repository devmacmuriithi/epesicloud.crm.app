import 'dart:convert';
import 'package:get/get.dart';
import '../models/crm_models.dart';
import '../models/lead_model.dart';
import 'api_service.dart';

class CrmService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  static const String baseUrl = 'http://192.168.1.76:3000';

  Future<DashboardStats> getDashboardStats() async {
    final response = await _apiService.get(baseUrl, '/api/dashboard/stats');
    return DashboardStats.fromJson(jsonDecode(response));
  }

  Future<List<AccountModel>> getAccounts() async {
    final response = await _apiService.get(baseUrl, '/api/accounts');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => AccountModel.fromJson(item)).toList();
  }

  Future<AccountModel> createAccount(Map<String, dynamic> accountData) async {
    final response = await _apiService.post(baseUrl, '/api/accounts', accountData);
    return AccountModel.fromJson(jsonDecode(response));
  }

  Future<List<ContactModel>> getContacts() async {
    final response = await _apiService.get(baseUrl, '/api/contacts');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => ContactModel.fromJson(item)).toList();
  }

  Future<List<LeadModel>> getLeads() async {
    final response = await _apiService.get(baseUrl, '/api/leads');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => LeadModel.fromJson(item)).toList();
  }

  Future<List<DealModel>> getDeals() async {
    final response = await _apiService.get(baseUrl, '/api/deals');
    try {
      List<dynamic> data = jsonDecode(response);
      return data.map((item) => DealModel.fromJson(item)).toList();
    } catch (e) {
      print('--- FLUTTER ERROR FETCHING DEALS ---');
      print('URL: /api/deals');
      print('Error: $e');
      print('RAW JSON: $response');
      rethrow;
    }
  }

  Future<DealModel> createDeal(Map<String, dynamic> dealData) async {
    final response = await _apiService.post(baseUrl, '/api/deals', dealData);
    try {
      final json = jsonDecode(response);
      return DealModel.fromJson(json);
    } catch (e) {
      // Response likely missing joined relations — construct minimal model
      final json = jsonDecode(response);
      return DealModel(
        id: json['id'] ?? 0,
        dealName: json['dealName'] ?? 'New Deal',
        salePrice: double.tryParse(json['salePrice']?.toString() ?? '0') ?? 0,
        isClosed: json['isClosed'] ?? false,
        isWon: json['isWon'] ?? false,
      );
    }
  }

  Future<DealModel> updateDeal(int id, Map<String, dynamic> dealData) async {
    final response = await _apiService.put(baseUrl, '/api/deals/$id', dealData);
    return DealModel.fromJson(jsonDecode(response));
  }

  Future<List<ActivityModel>> getActivities() async {
    final response = await _apiService.get(baseUrl, '/api/activities');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => ActivityModel.fromJson(item)).toList();
  }

  Future<List<TaskModel>> getTasks() async {
    final response = await _apiService.get(baseUrl, '/api/tasks');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => TaskModel.fromJson(item)).toList();
  }

  Future<TaskModel> createTask(Map<String, dynamic> taskData) async {
    final response = await _apiService.post(baseUrl, '/api/tasks', taskData);
    return TaskModel.fromJson(jsonDecode(response));
  }

  Future<void> updateTask(int id, Map<String, dynamic> taskData) async {
    final response = await _apiService.put(baseUrl, '/api/tasks/$id', taskData);
    // Some backends return 204 No Content — ignore body in that case
    if (response != null) {
      TaskModel.fromJson(jsonDecode(response)); // parse to validate, result unused
    }
  }

  Future<List<CaseModel>> getCases() async {
    final response = await _apiService.get(baseUrl, '/api/cases');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => CaseModel.fromJson(item)).toList();
  }

  Future<List<PaymentModel>> getPayments() async {
    final response = await _apiService.get(baseUrl, '/api/payments');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => PaymentModel.fromJson(item)).toList();
  }

  Future<List<ProductModel>> getProducts() async {
    final response = await _apiService.get(baseUrl, '/api/products');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }

  Future<List<ProjectModel>> getProjects() async {
    final response = await _apiService.get(baseUrl, '/api/projects');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => ProjectModel.fromJson(item)).toList();
  }

  Future<ActivityModel> createActivity(Map<String, dynamic> activityData) async {
    final response = await _apiService.post(baseUrl, '/api/activities', activityData);
    return ActivityModel.fromJson(jsonDecode(response));
  }

  Future<ActivityModel> updateActivity(int id, Map<String, dynamic> activityData) async {
    final response = await _apiService.put(baseUrl, '/api/activities/$id', activityData);
    return ActivityModel.fromJson(jsonDecode(response));
  }

  Future<void> deleteActivity(int id) async {
    await _apiService.delete(baseUrl, '/api/activities/$id', {});
  }

  Future<List<Map<String, dynamic>>> getActivityTypes() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/activity-types');
    return List<Map<String, dynamic>>.from(jsonDecode(response));
  }

  Future<List<Map<String, dynamic>>> getPriorities() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/priorities');
    return List<Map<String, dynamic>>.from(jsonDecode(response));
  }

  Future<List<LookupModel>> getCaseTypes() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/case-types');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => LookupModel.fromJson(item)).toList();
  }

  Future<List<LookupModel>> getActivityStatusTypes() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/activity-status-types');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => LookupModel.fromJson(item)).toList();
  }

  Future<List<LookupModel>> getMeetingTypes() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/meeting-types');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => LookupModel.fromJson(item)).toList();
  }

  Future<CaseModel> createCase(Map<String, dynamic> caseData) async {
    final response = await _apiService.post(baseUrl, '/api/cases', caseData);
    return CaseModel.fromJson(jsonDecode(response));
  }

  // --- Notes & Documents ---

  Future<List<ActivityModel>> getActivitiesForEntity(String idParam, int id) async {
    final response = await _apiService.get(baseUrl, '/api/activities?$idParam=$id');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => ActivityModel.fromJson(item)).toList();
  }

  Future<List<NoteModel>> getNotesForEntity(String idParam, int id) async {
    final response = await _apiService.get(baseUrl, '/api/notes?$idParam=$id');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => NoteModel.fromJson(item)).toList();
  }

  Future<NoteModel> createNote(Map<String, dynamic> noteData) async {
    final response = await _apiService.post(baseUrl, '/api/notes', noteData);
    return NoteModel.fromJson(jsonDecode(response));
  }

  Future<List<ContactModel>> getContactsForEntity(String idParam, int id) async {
    final response = await _apiService.get(baseUrl, '/api/contacts?$idParam=$id');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => ContactModel.fromJson(item)).toList();
  }

  Future<ContactModel> createContact(Map<String, dynamic> contactData) async {
    final response = await _apiService.post(baseUrl, '/api/contacts', contactData);
    return ContactModel.fromJson(jsonDecode(response));
  }

  Future<List<DocumentModel>> getDocumentsForEntity(String idParam, int id) async {
    final response = await _apiService.get(baseUrl, '/api/documents?$idParam=$id');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => DocumentModel.fromJson(item)).toList();
  }

  Future<DocumentModel> createDocument(Map<String, dynamic> documentData) async {
    final response = await _apiService.post(baseUrl, '/api/documents', documentData);
    return DocumentModel.fromJson(jsonDecode(response));
  }

  Future<List<DealModel>> getDealsForEntity(String idParam, int id) async {
    final response = await _apiService.get(baseUrl, '/api/deals?$idParam=$id');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => DealModel.fromJson(item)).toList();
  }

  Future<List<PaymentModel>> getPaymentsForEntity(String idParam, int id) async {
    final response = await _apiService.get(baseUrl, '/api/payments?$idParam=$id');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => PaymentModel.fromJson(item)).toList();
  }

  Future<List<LookupModel>> getPaymentMethods() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/payment-methods');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => LookupModel.fromJson(item)).toList();
  }

  Future<PaymentModel> createPayment(Map<String, dynamic> paymentData) async {
    final response = await _apiService.post(baseUrl, '/api/payments', paymentData);
    return PaymentModel.fromJson(jsonDecode(response));
  }

  // --- Task Lookups ---

  Future<List<LookupModel>> getTaskTypes() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/activity-types');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => LookupModel.fromJson(item)).toList();
  }

  Future<List<LookupModel>> getTaskStatusTypes() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/task-status-types');
    List<dynamic> data = jsonDecode(response);
    return data.map((item) => LookupModel.fromJson(item)).toList();
  }

  Future<List<Map<String, dynamic>>> getAgents() async {
    final response = await _apiService.get(baseUrl, '/api/lookups/agents');
    return List<Map<String, dynamic>>.from(jsonDecode(response));
  }
}
