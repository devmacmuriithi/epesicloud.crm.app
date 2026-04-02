import 'package:get/get.dart';
import '../models/crm_models.dart';
import '../models/lead_model.dart';
import '../Services/crm_service.dart';
import 'activities_controller.dart';

class CommunicationController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();

  var isLoading = false.obs;
  
  // Lists for selection
  var activityTypes = <Map<String, dynamic>>[].obs;
  var activityStatusTypes = <LookupModel>[].obs;
  var priorities = <Map<String, dynamic>>[].obs;
  var accounts = <AccountModel>[].obs;
  var contacts = <ContactModel>[].obs;
  var leads = <LeadModel>[].obs;
  var deals = <DealModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _crmService.getActivityTypes(),
        _crmService.getPriorities(),
        _crmService.getAccounts(),
        _crmService.getContacts(),
        _crmService.getLeads(),
        _crmService.getDeals(),
        _crmService.getActivityStatusTypes(),
      ]);

      activityTypes.value = (results[0] as List).cast<Map<String, dynamic>>();
      priorities.value = (results[1] as List).cast<Map<String, dynamic>>();
      accounts.value = results[2] as List<AccountModel>;
      contacts.value = results[3] as List<ContactModel>;
      leads.value = results[4] as List<LeadModel>;
      deals.value = results[5] as List<DealModel>;
      activityStatusTypes.assignAll(results[6] as List<LookupModel>);
    } catch (e) {
      print("Error fetching communication lookup data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitActivity(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      // Find "Completed" status ID if not provided
      if (data['activityStatusTypeId'] == null) {
        final completedStatus = activityStatusTypes.firstWhereOrNull(
          (s) => s.title.toLowerCase() == 'completed' || s.title.toLowerCase() == 'sent'
        );
        if (completedStatus != null) {
          data['activityStatusTypeId'] = completedStatus.id;
        }
      }

      // Ensure startDateTime is present for Calendar visibility
      if (data['startDateTime'] == null && data['startDate'] != null) {
        data['startDateTime'] = DateTime.now().toIso8601String();
      }

      await _crmService.createActivity(data);
      
      // Refresh the main activities list so the new record appears immediately
      if (Get.isRegistered<ActivitiesController>()) {
        Get.find<ActivitiesController>().fetchActivities();
      }
      
      Get.snackbar('Success', 'Activity logged successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to log activity: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitNote(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      await _crmService.createNote(data);
      Get.snackbar('Success', 'Note added successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add note: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitDocument(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      if (data['fileUrl'] == null) {
        data['fileUrl'] = 'https://example.com/uploads/${data['fileName']}';
      }
      await _crmService.createDocument(data);
      Get.snackbar('Success', 'Document uploaded successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload document: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
