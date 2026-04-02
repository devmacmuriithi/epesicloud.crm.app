import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import '../models/crm_models.dart';
import '../models/lead_model.dart';
import '../Services/crm_service.dart';

class CasesController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();
  
  var cases = <CaseModel>[].obs;
  var isLoading = false.obs;

  var accounts = <AccountModel>[].obs;
  var contacts = <ContactModel>[].obs;
  var leads = <LeadModel>[].obs;
  var deals = <DealModel>[].obs;
  var caseTypes = <LookupModel>[].obs;

  var selectedEntityType = 'Account'.obs;
  var selectedEntityId = Rxn<int>();
  var selectedCaseTypeId = Rxn<int>();
  var selectedPriority = 'Medium'.obs;
  final descriptionController = TextEditingController();
  final titleController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCases();
    fetchLookups();
  }

  Future<void> fetchLookups() async {
    try {
      final fetchedAccounts = await _crmService.getAccounts();
      accounts.assignAll(fetchedAccounts);
      
      final fetchedContacts = await _crmService.getContacts();
      contacts.assignAll(fetchedContacts);

      final fetchedLeads = await _crmService.getLeads();
      leads.assignAll(fetchedLeads);

      final fetchedDeals = await _crmService.getDeals();
      deals.assignAll(fetchedDeals);
      
      final fetchedCaseTypes = await _crmService.getCaseTypes();
      caseTypes.assignAll(fetchedCaseTypes);
    } catch (e) {
      print('Error fetching lookups: $e');
    }
  }

  Future<void> fetchCases() async {
    isLoading.value = true;
    try {
      final fetchedCases = await _crmService.getCases();
      cases.assignAll(fetchedCases);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch cases: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Color getStatusColor(String status) {
    status = status.toUpperCase();
    if (status.contains('PROGRESS')) return AppColors.primary;
    if (status.contains('OPEN') || status.contains('NEW')) return AppColors.warning;
    if (status.contains('RESOLVED') || status.contains('CLOSED')) return AppColors.success;
    return AppColors.textSecondary;
  }

  Color getPriorityColor(String priority) {
    priority = priority.toUpperCase();
    if (priority.contains('HIGH') || priority.contains('CRITICAL')) return Colors.redAccent;
    if (priority.contains('MEDIUM') || priority.contains('NORMAL')) return AppColors.primary;
    if (priority.contains('LOW')) return AppColors.textSecondary;
    return AppColors.textSecondary;
  }

  void filterCases(String query) {
    if (query.isEmpty) {
      fetchCases();
      return;
    }
    final filtered = cases.where((c) => 
      (c.title?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (c.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      c.caseNumber.toLowerCase().contains(query.toLowerCase())
    ).toList();
    cases.assignAll(filtered);
  }

  Future<bool> submitCase() async {
    if (selectedEntityId.value == null) {
      Get.snackbar('Error', 'Please select a linked entity reference');
      return false;
    }

    isLoading.value = true;
    try {
      final caseData = {
        'linkedEntityType': selectedEntityType.value,
        'linkedEntityId': selectedEntityId.value,
        'caseTypeId': selectedCaseTypeId.value,
        'priority': selectedPriority.value.toLowerCase(),
        'title': titleController.text,
        'description': descriptionController.text,
        'status': 'new',
        'caseOrigin': 'Web',
      };

      await _crmService.createCase(caseData);
      
      // Reset form
      titleController.clear();
      descriptionController.clear();
      selectedEntityId.value = null;
      selectedCaseTypeId.value = null;
      
      fetchCases(); // Refresh in background
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create case: $e',
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
