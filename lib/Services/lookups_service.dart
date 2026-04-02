import 'dart:convert';
import 'package:get/get.dart';
import '../utils/api_constants.dart';
import '../models/crm_models.dart';
import 'api_service.dart';

class LookupsService extends GetxService {
  final ApiService _api = Get.put(ApiService());

  var isLoading = false.obs;

  var countries = <LookupModel>[].obs;
  var accountTypes = <LookupModel>[].obs;
  var interestLevels = <LookupModel>[].obs;
  var leadSources = <LookupModel>[].obs;
  var leadStatusTypes = <LookupModel>[].obs;
  var dealTypes = <LookupModel>[].obs;
  var pipelines = <LookupModel>[].obs;
  var salesStages = <LookupModel>[].obs;
  var zones = <LookupModel>[].obs;
  var agents = <AgentModel>[].obs;
  var paymentTerms = <LookupModel>[].obs;
  
  var products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initially fetch core lookups once authorized
    // We export a function that can be called after splash screen or login
  }

  Future<void> fetchAllLookups() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchCountries(),
        fetchAccountTypes(),
        fetchInterestLevels(),
        fetchLeadSources(),
        fetchLeadStatusTypes(),
        fetchDealTypes(),
        fetchPipelines(),
        fetchSalesStages(),
        fetchZones(),
        fetchAgents(),
        fetchProducts(),
        fetchPaymentTerms(),
      ]);
    } catch (e) {
      print("Error fetching all lookups: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCountries() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/countries');
      final List data = json.decode(res);
      countries.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  // Helper for dynamic cities based on country selection
  Future<List<LookupModel>> fetchCitiesForCountry(int countryId) async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/cities?countryId=$countryId');
      final List data = json.decode(res);
      return data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchAccountTypes() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/account-types');
      final List data = json.decode(res);
      accountTypes.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchInterestLevels() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/interest-levels');
      final List data = json.decode(res);
      interestLevels.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchLeadSources() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/lead-sources');
      final List data = json.decode(res);
      leadSources.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchLeadStatusTypes() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/lead-status-types');
      final List data = json.decode(res);
      leadStatusTypes.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchDealTypes() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/deal-types');
      final List data = json.decode(res);
      dealTypes.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchPipelines() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/pipelines');
      final List data = json.decode(res);
      pipelines.value = data.map((e) => LookupModel.fromJson(e)).toList();
      
      // Usually stage lists are bound to default pipeline in CRM
      if (pipelines.isNotEmpty) {
        final defaultPipeline = pipelines.firstWhere((p) => true, orElse: () => pipelines.first); 
        // Can be customized if 'isDefault' flag exists
      }
    } catch (e) {}
  }

  Future<void> fetchSalesStages({int? pipelineId}) async {
    try {
      String endpoint = '${ApiConstants.lookups}/sales-stages';
      if (pipelineId != null) {
        endpoint += '?pipelineId=$pipelineId';
      }
      final res = await _api.get(ApiConstants.baseUrl, endpoint);
      final List data = json.decode(res);
      salesStages.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchZones() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '/api/zones');
      final List data = json.decode(res);
      zones.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchAgents() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/users');
      final List data = json.decode(res);
      agents.value = data.map((e) => AgentModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchPaymentTerms() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '${ApiConstants.lookups}/payment-terms');
      final List data = json.decode(res);
      paymentTerms.value = data.map((e) => LookupModel.fromJson(e)).toList();
    } catch (e) {}
  }

  Future<void> fetchProducts() async {
    try {
      final res = await _api.get(ApiConstants.baseUrl, '/api/products');
      final List data = json.decode(res);
      products.value = data.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {}
  }
}
