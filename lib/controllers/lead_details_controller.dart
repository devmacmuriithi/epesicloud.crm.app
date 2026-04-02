import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/lead_model.dart';
import '../../models/crm_models.dart';
import '../../Services/crm_service.dart';
import 'package:file_picker/file_picker.dart';

class LeadDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CrmService _crmService = Get.find<CrmService>();
  late TabController tabController;
  late LeadModel lead;

  final activities = <ActivityModel>[].obs;
  final notes = <NoteModel>[].obs;
  final documents = <DocumentModel>[].obs;
  final deals = <DealModel>[].obs;

  final isLoadingActivities = false.obs;
  final isLoadingNotes = false.obs;
  final isLoadingDocuments = false.obs;
  final isLoadingDeals = false.obs;

  final currentActivityFilter = 'All'.obs;

  List<dynamic> get filteredFeed {
    final List<dynamic> feed = [];
    
    final filter = currentActivityFilter.value;

    if (filter == 'All' || filter == 'Calls') {
      feed.addAll(activities.where((a) => a.type.toLowerCase().contains('call')));
    }
    if (filter == 'All' || filter == 'SMS') {
      feed.addAll(activities.where((a) => a.type.toLowerCase().contains('sms') || a.type.toLowerCase().contains('message')));
    }
    if (filter == 'All' || filter == 'Emails') {
      feed.addAll(activities.where((a) => a.type.toLowerCase().contains('email')));
    }
    if (filter == 'All' || filter == 'Notes') {
      feed.addAll(notes);
    }
    if (filter == 'All' || filter == 'Docs') {
      feed.addAll(documents);
    }
    
    // Add other activities (tasks/meetings) only if 'All' is selected or if there's an 'Others' filter
    if (filter == 'All') {
      feed.addAll(activities.where((a) => 
        !a.type.toLowerCase().contains('call') && 
        !a.type.toLowerCase().contains('sms') && 
        !a.type.toLowerCase().contains('email')
      ));
    }

    // Sort by date (descending)
    feed.sort((a, b) {
      DateTime dateA = _getDateTime(a);
      DateTime dateB = _getDateTime(b);
      return dateB.compareTo(dateA);
    });
    
    return feed;
  }

  DateTime _getDateTime(dynamic item) {
    if (item is ActivityModel) {
      // Assuming dueDate or some date field exists. 
      // If it's just a string, we try to parse it.
      return DateTime.tryParse(item.dueDate ?? '') ?? DateTime.now();
    } else if (item is NoteModel) {
      return item.createdAt ?? DateTime.now();
    } else if (item is DocumentModel) {
      return item.createdAt;
    }
    return DateTime.now();
  }

  @override
  void onInit() {
    super.onInit();
    lead = Get.arguments as LeadModel? ??
        LeadModel(
          id: 0,
          firstName: 'Jonathan',
          lastName: 'Sterling',
          company: 'Nexus Systems Inc.',
          status: 'Active',
          email: 'jonathan@example.com',
          isConverted: false,
        );
    tabController = TabController(length: 5, vsync: this);

    if (lead.id != 0) {
      fetchActivities();
      fetchNotes();
      fetchDocuments();
      fetchDeals();
    }
  }

  Future<void> fetchActivities() async {
    isLoadingActivities.value = true;
    try {
      final fetched = await _crmService.getActivitiesForEntity('leadId', lead.id);
      // Filter locally as a fallback to ensure data isolation
      activities.value = fetched.where((a) => 
        a.leadId == lead.id || 
        (a.linkedEntityType?.toLowerCase() == 'lead' && a.linkedEntityId == lead.id)
      ).toList();
    } catch (e) {
      print('Error fetching activities: $e');
    } finally {
      isLoadingActivities.value = false;
    }
  }

  Future<void> fetchNotes() async {
    isLoadingNotes.value = true;
    try {
      final fetched = await _crmService.getNotesForEntity('leadId', lead.id);
      notes.value = fetched.where((n) => 
        n.leadId == lead.id || 
        (n.linkedEntityType?.toLowerCase() == 'lead' && n.linkedEntityId == lead.id)
      ).toList();
    } catch (e) {
      print('Error fetching notes: $e');
    } finally {
      isLoadingNotes.value = false;
    }
  }

  Future<void> fetchDocuments() async {
    isLoadingDocuments.value = true;
    try {
      final fetched = await _crmService.getDocumentsForEntity('leadId', lead.id);
      documents.value = fetched.where((d) => 
        d.leadId == lead.id || 
        (d.linkedEntityType?.toLowerCase() == 'lead' && d.linkedEntityId == lead.id)
      ).toList();
    } catch (e) {
      print('Error fetching documents: $e');
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<void> fetchDeals() async {
    isLoadingDeals.value = true;
    try {
      final fetched = await _crmService.getDealsForEntity('leadId', lead.id);
      deals.value = fetched;
    } catch (e) {
      print('Error fetching deals: $e');
    } finally {
      isLoadingDeals.value = false;
    }
  }

  Future<void> createDeal(Map<String, dynamic> dealData) async {
    try {
      // Ensure the deal is linked to the lead
      dealData['leadId'] = lead.id;
      
      await _crmService.createDeal(dealData);
      fetchDeals();
      Get.back();
      Get.snackbar('Success', 'Deal created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create deal: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> saveNote(String title, String content) async {
    try {
      await _crmService.createNote({
        'title': title,
        'content': content,
        'leadId': lead.id,
      });
      fetchNotes();
      Get.back();
      Get.snackbar('Success', 'Note saved successfully', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save note: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  }

  Future<void> pickAndUploadDocument({String? description}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;
        final fileName = file.name;
        final fileSize = file.size;
        final fileType = file.extension?.toUpperCase() ?? 'FILE';

        await saveDocumentEntry(fileName, fileType, fileSize, description: description);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  }

  Future<void> saveDocumentEntry(String fileName, String fileType, int fileSize, {String? description}) async {
    try {
      await _crmService.createDocument({
        'fileName': fileName,
        'fileType': fileType,
        'fileSize': fileSize,
        'description': description,
        'fileUrl': 'https://example.com/mock-upload/$fileName',
        'leadId': lead.id,
      });
      fetchDocuments();
      Get.back();
      Get.snackbar('Success', 'Document entry created',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save document: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
