// Sync: 2026-03-30 13:35
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/crm_models.dart';
import '../Services/crm_service.dart';
import '../Services/lookups_service.dart';

class DealsController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();
  
  final RxList<DealModel> _allDeals = <DealModel>[].obs;
  var deals = <DealModel>[].obs;
  var isLoading = false.obs;
  int? preSelectedAccountId;
  int? preSelectedLeadId;
  String? preSelectedLeadName;

  var selectedType = LookupModel(id: -1, title: 'All Deals').obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args.containsKey('accountId')) {
      preSelectedAccountId = args['accountId'];
    }
    fetchDeals();
  }

  Future<void> fetchDeals() async {
    isLoading.value = true;
    try {
      final fetchedDeals = await _crmService.getDeals();
      _allDeals.assignAll(fetchedDeals);
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch deals: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setDealType(LookupModel type) {
    if (selectedType.value.id == type.id) {
      selectedType.value = LookupModel(id: -1, title: 'All Deals');
    } else {
      selectedType.value = type;
    }
    applyFilters();
  }

  void resetFilters() {
    selectedType.value = LookupModel(id: -1, title: 'All Deals');
    searchQuery.value = '';
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void filterDeals(String query) {
    setSearchQuery(query);
  }

  void applyFilters() {
    var filtered = _allDeals.toList();

    // Filter by deal type
    if (selectedType.value.id != -1) {
      filtered = filtered.where((deal) => 
        deal.dealTypeId == selectedType.value.id
      ).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((deal) => 
        deal.dealName.toLowerCase().contains(query)
      ).toList();
    }

    // Filter by account if pre-selected
    if (preSelectedAccountId != null) {
      filtered = filtered.where((deal) => deal.accountId == preSelectedAccountId).toList();
    }

    deals.assignAll(filtered);
  }

  String formatValue(double value) {
    return NumberFormat.currency(symbol: 'Kes ', decimalDigits: 0).format(value);
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void openDealDetails(DealModel deal) {
    Get.toNamed('/deal-details', arguments: deal);
  }

  Future<bool> createDeal(Map<String, dynamic> payload) async {
    try {
      final newDeal = await _crmService.createDeal(payload);
      deals.insert(0, newDeal);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create deal',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError);
      return false;
    }
  }
}
