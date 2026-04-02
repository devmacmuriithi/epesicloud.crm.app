import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/crm_models.dart';
import '../../Services/crm_service.dart';
import 'package:file_picker/file_picker.dart';

class AccountDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CrmService _crmService = Get.find<CrmService>();
  late TabController tabController;
  late AccountModel account;

  final activities = <ActivityModel>[].obs;
  final notes = <NoteModel>[].obs;
  final documents = <DocumentModel>[].obs;
  final contacts = <ContactModel>[].obs;
  final deals = <DealModel>[].obs;

  final isLoadingActivities = false.obs;
  final isLoadingNotes = false.obs;
  final isLoadingDocuments = false.obs;
  final isLoadingContacts = false.obs;
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

  var isShippingAddressExpanded = true.obs;
  var isBillingAddressExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    account = Get.arguments as AccountModel? ??
        AccountModel(
          id: 0,
          accountName: 'Acme Corp',
          industry: 'Technology / SaaS',
          isActive: true,
        );
    tabController = TabController(length: 6, vsync: this);

    if (account.id != 0) {
      fetchActivities();
      fetchNotes();
      fetchDocuments();
      fetchContacts();
      fetchDeals();
    }
  }

  Future<void> fetchActivities() async {
    isLoadingActivities.value = true;
    try {
      final fetched = await _crmService.getActivitiesForEntity('accountId', account.id);
      activities.value = fetched.where((a) => 
        a.accountId == account.id || 
        (a.linkedEntityType?.toLowerCase() == 'account' && a.linkedEntityId == account.id)
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
      final fetched = await _crmService.getNotesForEntity('accountId', account.id);
      notes.value = fetched.where((n) => 
        n.accountId == account.id || 
        (n.linkedEntityType?.toLowerCase() == 'account' && n.linkedEntityId == account.id)
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
      final fetched = await _crmService.getDocumentsForEntity('accountId', account.id);
      documents.value = fetched.where((d) => 
        d.accountId == account.id || 
        (d.linkedEntityType?.toLowerCase() == 'account' && d.linkedEntityId == account.id)
      ).toList();
    } catch (e) {
      print('Error fetching documents: $e');
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<void> fetchContacts() async {
    isLoadingContacts.value = true;
    try {
      contacts.value = await _crmService.getContactsForEntity('accountId', account.id);
    } catch (e) {
      print('Error fetching contacts: $e');
    } finally {
      isLoadingContacts.value = false;
    }
  }

  Future<void> fetchDeals() async {
    isLoadingDeals.value = true;
    try {
      deals.value = await _crmService.getDealsForEntity('accountId', account.id);
    } catch (e) {
      print('Error fetching deals: $e');
    } finally {
      isLoadingDeals.value = false;
    }
  }

  Future<void> saveNote(String title, String content) async {
    try {
      await _crmService.createNote({
        'title': title,
        'content': content,
        'accountId': account.id,
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
        'accountId': account.id,
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

  void toggleShippingAddress() {
    isShippingAddressExpanded.value = !isShippingAddressExpanded.value;
  }

  void toggleBillingAddress() {
    isBillingAddressExpanded.value = !isBillingAddressExpanded.value;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
