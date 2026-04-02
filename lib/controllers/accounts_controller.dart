import 'package:get/get.dart';
import '../models/crm_models.dart';
import '../Services/crm_service.dart';

class AccountsController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();
  
  var accounts = <AccountModel>[].obs;
  final List<AccountModel> _allAccounts = []; // Regular list is enough as it's filtered into 'accounts'
  var isLoading = false.obs;

  var selectedStatus = LookupModel(id: -1, title: 'All Accounts').obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    isLoading.value = true;
    try {
      final fetchedAccounts = await _crmService.getAccounts();
      _allAccounts.clear();
      _allAccounts.addAll(fetchedAccounts);
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch accounts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setStatus(LookupModel status) {
    if (selectedStatus.value.id == status.id) {
      selectedStatus.value = LookupModel(id: -1, title: 'All Accounts');
    } else {
      selectedStatus.value = status;
    }
    applyFilters();
  }

  void resetFilters() {
    selectedStatus.value = LookupModel(id: -1, title: 'All Accounts');
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    var filtered = _allAccounts.toList();

    // Filter by status (Account Type ID matching)
    if (selectedStatus.value.id != -1) {
      filtered = filtered.where((account) => 
        (account.accountTypeId != null && account.accountTypeId == selectedStatus.value.id) ||
        (account.accountType?.toLowerCase() ?? '') == selectedStatus.value.title.toLowerCase()
      ).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((account) => 
        account.accountName.toLowerCase().contains(query) ||
        (account.industry?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    accounts.assignAll(filtered);
  }

  Future<bool> createAccount(Map<String, dynamic> payload) async {
    try {
      final newAccount = await _crmService.createAccount(payload);
      _allAccounts.insert(0, newAccount);
      applyFilters();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError);
      return false;
    }
  }
}
