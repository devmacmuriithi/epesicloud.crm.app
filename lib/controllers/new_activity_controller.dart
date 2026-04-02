import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/crm_models.dart';
import '../../models/lead_model.dart';
import '../../Services/crm_service.dart';

class NewActivityController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();

  final locationController = TextEditingController();
  final notesController = TextEditingController();
  
  final actType = 'Call'.obs; // Call, Meeting, Email
  final status = 'Completed'.obs;

  // New Date/Time logic
  final selectedDateStr = 'Select Date'.obs;
  final startTimeStr = 'Set time'.obs;
  final endTimeStr = 'Set time'.obs;
  
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  // Lookups data
  final activityTypes = <LookupModel>[].obs;
  final activityStatusTypes = <LookupModel>[].obs;
  final meetingTypes = <LookupModel>[].obs;

  // Link To records
  final linkType = 'Lead'.obs; // Lead, Deal, Account, Contact
  final searchQuery = ''.obs;
  final selectedRecord = Rxn<dynamic>(); 
  final availableRecords = <dynamic>[].obs;
  final isLoadingRecords = false.obs;

  final allLeads = <LeadModel>[].obs;
  final allDeals = <DealModel>[].obs;
  final allAccounts = <AccountModel>[].obs;
  final allContacts = <ContactModel>[].obs;

  bool isEditing = false;
  int? editingId;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    
    if (Get.arguments is ActivityModel) {
      isEditing = true;
      final activity = Get.arguments as ActivityModel;
      editingId = activity.id;
      locationController.text = activity.location ?? '';
      notesController.text = activity.description ?? '';
      
      actType.value = _capitalize(activity.type);
      status.value = 'Completed';
      
      if (activity.startDateTime != null) {
        selectedDate = activity.startDateTime;
        selectedStartTime = TimeOfDay.fromDateTime(activity.startDateTime!);
        selectedDateStr.value = DateFormat('MM/dd/yyyy').format(activity.startDateTime!);
        startTimeStr.value = DateFormat('hh:mm a').format(activity.startDateTime!);
      }
      
      if (activity.endDateTime != null) {
        selectedEndTime = TimeOfDay.fromDateTime(activity.endDateTime!);
        endTimeStr.value = DateFormat('hh:mm a').format(activity.endDateTime!);
      }

      if (activity.linkedEntityType != null) {
        linkType.value = _capitalize(activity.linkedEntityType!);
      }
    } else if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('entityType')) {
        linkType.value = _capitalize(args['entityType']);
      }
      // We'll match the actual record in fetchInitialData once allLeads/allAccounts are loaded
      
      // Default to Today
      selectedDate = DateTime.now();
      selectedDateStr.value = DateFormat('MM/dd/yyyy').format(selectedDate!);
    } else {
      // Default to Today
      selectedDate = DateTime.now();
      selectedDateStr.value = DateFormat('MM/dd/yyyy').format(selectedDate!);
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future<void> fetchInitialData() async {
    try {
      isLoadingRecords.value = true;
      
      final types = await _crmService.getActivityTypes();
      activityTypes.assignAll(types.map((e) => LookupModel(id: e['id'], title: e['title'] ?? e['name'] ?? '')));
      
      final statuses = await _crmService.getActivityStatusTypes();
      activityStatusTypes.assignAll(statuses);

      allLeads.assignAll(await _crmService.getLeads());
      allDeals.assignAll(await _crmService.getDeals());
      allAccounts.assignAll(await _crmService.getAccounts());
      allContacts.assignAll(await _crmService.getContacts());

      updateAvailableRecords();
      
      if (isEditing && Get.arguments is ActivityModel) {
        final activity = Get.arguments as ActivityModel;
        if (activity.linkedEntityId != null) {
          _matchSelectedRecord(activity.linkedEntityType, activity.linkedEntityId);
        }
      } else if (Get.arguments is Map) {
        final args = Get.arguments as Map;
        if (args.containsKey('entityType') && args.containsKey('entityId')) {
          _matchSelectedRecord(args['entityType'], args['entityId']);
        }
        if (args.containsKey('actType')) {
          actType.value = _capitalize(args['actType']);
        }
      }

    } catch (e) {
      Get.snackbar('Error', 'Failed to load lookup data: $e');
    } finally {
      isLoadingRecords.value = false;
    }
  }

  void _matchSelectedRecord(String? type, int? id) {
    if (type == null || id == null) return;
    switch (type.toLowerCase()) {
      case 'lead':
        selectedRecord.value = allLeads.firstWhereOrNull((e) => e.id == id);
        break;
      case 'deal':
        selectedRecord.value = allDeals.firstWhereOrNull((e) => e.id == id);
        break;
      case 'account':
        selectedRecord.value = allAccounts.firstWhereOrNull((e) => e.id == id);
        break;
      case 'contact':
        selectedRecord.value = allContacts.firstWhereOrNull((e) => e.id == id);
        break;
    }
  }

  String _matchOption(String value, List<String> options) {
    if (options.contains(value)) return value;
    final normalized = value.toLowerCase().trim();
    return options.firstWhere(
      (o) => o.toLowerCase() == normalized,
      orElse: () => options.first, // Fallback to first option to prevent crash
    );
  }

  void updateAvailableRecords() {
    List<dynamic> records = [];
    switch (linkType.value) {
      case 'Lead': records = allLeads; break;
      case 'Deal': records = allDeals; break;
      case 'Account': records = allAccounts; break;
      case 'Contact': records = allContacts; break;
    }
    
    if (searchQuery.isEmpty) {
      availableRecords.assignAll(records);
    } else {
      final query = searchQuery.value.toLowerCase();
      availableRecords.assignAll(records.where((r) {
        final name = _getRecordName(r).toLowerCase();
        return name.contains(query);
      }).toList());
    }
  }

  String _getRecordName(dynamic record) {
    if (record is LeadModel) return record.name;
    if (record is DealModel) return record.dealName;
    if (record is AccountModel) return record.accountName;
    if (record is ContactModel) return record.fullName;
    return '';
  }

  @override
  void onClose() {
    locationController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void setActivityType(String type) {
    actType.value = type;
  }

  void setLinkType(String type) {
    linkType.value = type;
    selectedRecord.value = null;
    searchQuery.value = '';
    updateAvailableRecords();
  }

  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      selectedDate = date;
      selectedDateStr.value = DateFormat('MM/dd/yyyy').format(date);
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedStartTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      selectedStartTime = time;
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      startTimeStr.value = DateFormat('hh:mm a').format(dt);
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedEndTime ?? selectedStartTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      selectedEndTime = time;
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      endTimeStr.value = DateFormat('hh:mm a').format(dt);
    }
  }

  Future<void> saveActivity() async {
    if (selectedDate == null) {
      Get.snackbar('Error', 'Date is required');
      return;
    }

    DateTime? startDT;
    if (selectedStartTime != null) {
      startDT = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedStartTime!.hour, selectedStartTime!.minute);
    }

    DateTime? endDT;
    if (selectedEndTime != null) {
      endDT = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedEndTime!.hour, selectedEndTime!.minute);
    }

    final activityType = activityTypes.firstWhereOrNull((e) => (e.title ?? '').toLowerCase().contains(actType.value.toLowerCase()));
    final statusType = activityStatusTypes.firstWhereOrNull((e) => (e.title ?? '').toLowerCase().trim() == status.value.toLowerCase().trim());

    final data = {
      'subject': _generateDefaultSubject(),
      'location': locationController.text,
      'description': notesController.text,
      'activityTypeId': activityType?.id ?? 1,
      'activityStatusTypeId': statusType?.id,
      'priority': 'medium',
      'startDate': DateFormat('yyyy-MM-dd').format(selectedDate!),
      'startDateTime': startDT?.toIso8601String(),
      'endDateTime': endDT?.toIso8601String(),
      'linkedEntityType': linkType.value.toLowerCase(),
      'linkedEntityId': selectedRecord.value?.id,
      if (linkType.value == 'Lead') 'leadId': selectedRecord.value?.id,
      if (linkType.value == 'Deal') 'dealId': selectedRecord.value?.id,
      if (linkType.value == 'Account') 'accountId': selectedRecord.value?.id,
      if (linkType.value == 'Contact') 'contactId': selectedRecord.value?.id,
    };

    try {
      if (isEditing && editingId != null) {
        await _crmService.updateActivity(editingId!, data);
      } else {
        await _crmService.createActivity(data);
      }
      Get.back(result: true);
      Get.snackbar('Success', 'Activity ${isEditing ? 'updated' : 'created'} successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save activity: $e');
    }
  }

  Future<void> deleteActivity() async {
    if (!isEditing || editingId == null) return;
    
    try {
      await _crmService.deleteActivity(editingId!);
      Get.back(result: true);
      Get.snackbar('Success', 'Activity deleted successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete activity: $e');
    }
  }

  String getRecordName(dynamic r) => _getRecordName(r);

  String _generateDefaultSubject() {
    final recordName = selectedRecord.value != null ? _getRecordName(selectedRecord.value) : '';
    return '${actType.value}${recordName.isNotEmpty ? " - $recordName" : ""}';
  }
}
