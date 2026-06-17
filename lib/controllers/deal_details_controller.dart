import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/crm_models.dart';
import '../../Services/crm_service.dart';
import '../../Services/lookups_service.dart';
import '../../utils/snackbar_helpers.dart';
import 'package:file_picker/file_picker.dart';

class DealDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CrmService _crmService = Get.find<CrmService>();
  final LookupsService _lookupsService = Get.find<LookupsService>();
  final Rx<DealModel> deal = DealModel(
    id: 0,
    dealName: 'Loading...',
    salePrice: 0,
    isClosed: false,
    isWon: false,
  ).obs;
  late TabController tabController;

  final activities = <ActivityModel>[].obs;
  final notes = <NoteModel>[].obs;
  final documents = <DocumentModel>[].obs;
  final payments = <PaymentModel>[].obs;

  final isLoadingActivities = false.obs;
  final isLoadingNotes = false.obs;
  final isLoadingDocuments = false.obs;
  final isLoadingPayments = false.obs;

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
    
    if (filter == 'All') {
      feed.addAll(activities.where((a) => 
        !a.type.toLowerCase().contains('call') && 
        !a.type.toLowerCase().contains('sms') && 
        !a.type.toLowerCase().contains('email')
      ));
    }

    feed.sort((a, b) {
      DateTime dateA = _getDateTime(a);
      DateTime dateB = _getDateTime(b);
      return dateB.compareTo(dateA);
    });
    
    return feed;
  }

  DateTime _getDateTime(dynamic item) {
    if (item is ActivityModel) {
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
    final args = Get.arguments;
    if (args is DealModel) {
      deal.value = args;
    }
    
    tabController = TabController(length: 5, vsync: this);

    if (deal.value.id != 0) {
      fetchActivities();
      fetchNotes();
      fetchDocuments();
      fetchPayments();
      // Fetch sales stages for the pipeline if available
      _lookupsService.fetchSalesStages(pipelineId: deal.value.pipelineId);
    }
  }

  Future<void> fetchActivities() async {
    isLoadingActivities.value = true;
    try {
      final fetched = await _crmService.getActivitiesForEntity('dealId', deal.value.id);
      activities.value = fetched.where((a) => 
        a.dealId == deal.value.id || 
        (a.linkedEntityType?.toLowerCase() == 'deal' && a.linkedEntityId == deal.value.id)
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
      final fetched = await _crmService.getNotesForEntity('dealId', deal.value.id);
      notes.value = fetched.where((n) => 
        n.dealId == deal.value.id || 
        (n.linkedEntityType?.toLowerCase() == 'deal' && n.linkedEntityId == deal.value.id)
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
      final fetched = await _crmService.getDocumentsForEntity('dealId', deal.value.id);
      documents.value = fetched.where((d) => 
        d.dealId == deal.value.id || 
        (d.linkedEntityType?.toLowerCase() == 'deal' && d.linkedEntityId == deal.value.id)
      ).toList();
    } catch (e) {
      print('Error fetching documents: $e');
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<void> fetchPayments() async {
    isLoadingPayments.value = true;
    try {
      final fetched = await _crmService.getPaymentsForEntity('dealId', deal.value.id);
      payments.value = fetched;
    } catch (e) {
      print('Error fetching payments: $e');
    } finally {
      isLoadingPayments.value = false;
    }
  }

  Future<void> moveStage(LookupModel stage) async {
    try {
      final updatedDeal = await _crmService.updateDeal(deal.value.id, {'stageId': stage.id});
      deal.value = updatedDeal;
      Get.snackbar('Success', 'Deal stage updated to ${stage.title}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update deal stage: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> saveNote(String title, String content) async {
    Get.back();
    showSaving('Saving note...');
    try {
      await _crmService.createNote({
        'title': title,
        'content': content,
        'dealId': deal.value.id,
        'linkedEntityType': 'deal',
        'linkedEntityId': deal.value.id,
      });
      fetchNotes();
      showSaved('Note saved successfully');
    } catch (e) {
      showSaveError('Failed to save note: $e');
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
        'dealId': deal.value.id,
        'linkedEntityType': 'deal',
        'linkedEntityId': deal.value.id,
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

  Future<void> logPayment(double amount, String reference, {String? notes}) async {
    try {
      await _crmService.createPayment({
        'amount': amount,
        'transactionReference': reference,
        'notes': notes,
        'dealId': deal.value.id,
        'paymentDate': DateTime.now().toIso8601String(),
        'status': 'completed',
      });
      fetchPayments();
      Get.back();
      Get.snackbar('Success', 'Payment logged successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to log payment: $e',
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
