import 'package:get/get.dart';
import '../models/lead_model.dart';
import '../models/crm_models.dart';
import '../Services/leads_service.dart';

class LeadsController extends GetxController {
  final LeadsService _leadsService = Get.put(LeadsService());
  
  var leads = <LeadModel>[].obs;
  final List<LeadModel> _allLeads = []; // Regular list is enough as it's filtered into 'leads'
  var isLoading = false.obs;

  var selectedStatus = LookupModel(id: -1, title: 'All Statuses').obs;
  var selectedSource = LookupModel(id: -1, title: 'All Sources').obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
  }

  Future<void> fetchLeads() async {
    isLoading.value = true;
    try {
      final fetchedLeads = await _leadsService.getLeads();
      _allLeads.clear();
      _allLeads.addAll(fetchedLeads);
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch leads: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setStatus(LookupModel status) {
    if (selectedStatus.value.id == status.id) {
      selectedStatus.value = LookupModel(id: -1, title: 'All Statuses');
    } else {
      selectedStatus.value = status;
    }
    applyFilters();
  }

  void setSource(LookupModel source) {
    if (selectedSource.value.id == source.id) {
      selectedSource.value = LookupModel(id: -1, title: 'All Sources');
    } else {
      selectedSource.value = source;
    }
    applyFilters();
  }

  void resetFilters() {
    selectedStatus.value = LookupModel(id: -1, title: 'All Statuses');
    selectedSource.value = LookupModel(id: -1, title: 'All Sources');
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    var filtered = _allLeads.toList();

    // Filter by status (ID-based matching)
    if (selectedStatus.value.id != -1) {
      filtered = filtered.where((lead) => 
        (lead.leadStatusTypeId != null && lead.leadStatusTypeId == selectedStatus.value.id) ||
        lead.status.toLowerCase() == selectedStatus.value.title.toLowerCase()
      ).toList();
    }

    // Filter by lead source (ID-based matching)
    if (selectedSource.value.id != -1) {
      filtered = filtered.where((lead) => 
        (lead.leadSourceId != null && lead.leadSourceId == selectedSource.value.id) ||
        (lead.status.toLowerCase() == selectedSource.value.title.toLowerCase()) // Fallback for sources too
      ).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((lead) => 
        lead.name.toLowerCase().contains(query) ||
        lead.company.toLowerCase().contains(query)
      ).toList();
    }

    leads.assignAll(filtered);
  }

  void openLeadDetails(LeadModel lead) {
    Get.toNamed('/lead-details', arguments: lead);
  }

  Future<bool> createLead(Map<String, dynamic> payload) async {
    try {
      final newLead = await _leadsService.createLead(payload);
      _allLeads.insert(0, newLead); // Add to top of original list
      applyFilters(); // Re-apply to show if it fits criteria
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create lead',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError);
      return false;
    }
  }
}
