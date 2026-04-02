import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/crm_models.dart';
import '../models/lead_model.dart';
import '../Services/crm_service.dart';
import '../Services/auth_service.dart';

class TasksController extends GetxController with GetSingleTickerProviderStateMixin {
  final CrmService _crmService = Get.find<CrmService>();
  late TabController tabController;
  
  var isSearchExpanded = false.obs;
  var searchQuery = ''.obs;
  var tasks = <TaskModel>[].obs;
  var isLoading = false.obs;

  // -- Lookups --
  var taskTypes = <LookupModel>[].obs;
  var taskStatusTypes = <LookupModel>[].obs;
  var priorities = <LookupModel>[].obs;
  var agents = <Map<String, dynamic>>[].obs;

  // -- Linked Entities --
  var accounts = <AccountModel>[].obs;
  var contacts = <ContactModel>[].obs;
  var leads = <LeadModel>[].obs;
  var deals = <DealModel>[].obs;

  // -- Form Fields --
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  var selectedTaskTypeId = Rxn<int>();
  var selectedStatusTypeId = Rxn<int>();
  var selectedPriorityId = Rxn<int>();
  var selectedAssigneeId = Rxn<int>();
  var selectedDueDate = Rxn<DateTime>();
  var selectedLinkedEntityType = 'account'.obs;
  var selectedLinkedEntityId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    // Auto-assign to the currently logged-in agent
    final authService = Get.find<AuthService>();
    final userId = authService.currentUser.value?.id;
    if (userId != null) {
      selectedAssigneeId.value = int.tryParse(userId);
    }
    fetchTasks();
    fetchAllLookups();
  }

  @override
  void onClose() {
    tabController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      final fetchedTasks = await _crmService.getTasks();
      tasks.assignAll(fetchedTasks);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllLookups() async {
    try {
      try {
        final tTaskTypes = await _crmService.getTaskTypes();
        taskTypes.assignAll(tTaskTypes);
      } catch (e) { print('Error fetching taskTypes: $e'); }

      try {
        final tTaskStatusTypes = await _crmService.getTaskStatusTypes();
        taskStatusTypes.assignAll(tTaskStatusTypes);
      } catch (e) { print('Error fetching taskStatusTypes: $e'); }

      try {
        final tPriorities = await _crmService.getPriorities();
        if (tPriorities is List<Map<String, dynamic>>) {
          priorities.assignAll((tPriorities).map((e) => LookupModel.fromJson(e)).toList());
        } else {
          priorities.assignAll(tPriorities as List<LookupModel>);
        }
      } catch (e) { print('Error fetching priorities: $e'); }

      try {
        final tAgents = await _crmService.getAgents();
        agents.assignAll(tAgents);
      } catch (e) { print('Error fetching agents: $e'); }

      try {
        final tAccounts = await _crmService.getAccounts();
        accounts.assignAll(tAccounts);
      } catch (e) { print('Error fetching accounts: $e'); }

      try {
        final tContacts = await _crmService.getContacts();
        contacts.assignAll(tContacts);
      } catch (e) { print('Error fetching contacts: $e'); }

      try {
        final tLeads = await _crmService.getLeads();
        leads.assignAll(tLeads);
      } catch (e) { print('Error fetching leads: $e'); }

      try {
        final tDeals = await _crmService.getDeals();
        deals.assignAll(tDeals);
      } catch (e) { print('Error fetching deals: $e'); }
      
      _setDefaults();
    } catch (e) {
      print('Error fetching task lookups: $e');
    }
  }

  void _setDefaults() {
    if (priorities.isNotEmpty && selectedPriorityId.value == null) {
      final medium = priorities.firstWhereOrNull((p) => p.title.toLowerCase() == 'medium');
      if (medium != null) selectedPriorityId.value = medium.id;
    }
    if (taskStatusTypes.isNotEmpty) {
      final completed = taskStatusTypes.firstWhereOrNull((s) => s.title.toLowerCase().contains('complet'));
      if (completed != null) selectedStatusTypeId.value = completed.id;
    }
    if (taskTypes.isNotEmpty) {
      final task = taskTypes.firstWhereOrNull((t) => t.title.toLowerCase() == 'task') ?? taskTypes.firstOrNull;
      if (task != null) selectedTaskTypeId.value = task.id;
    }
  }


  List<TaskModel> get filteredTasks {
    if (searchQuery.isEmpty) return tasks;
    return tasks.where((task) => 
      task.subject.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  void toggleSearch() {
    isSearchExpanded.value = !isSearchExpanded.value;
    if (!isSearchExpanded.value) {
      searchQuery.value = '';
    }
  }

  Future<bool> submitTask() async {
    if (subjectController.text.isEmpty) {
      Get.snackbar('Error', 'Subject is required');
      return false;
    }
    if (selectedLinkedEntityId.value == null) {
      Get.snackbar('Error', 'Linked Entity is required');
      return false;
    }

    isLoading.value = true;
    try {
      final taskData = {
        'subject': subjectController.text,
        'description': descriptionController.text.isEmpty ? null : descriptionController.text,
        'taskTypeId': selectedTaskTypeId.value,
        'taskStatusTypeId': selectedStatusTypeId.value,
        'priorityId': selectedPriorityId.value,
        'assigneeId': selectedAssigneeId.value,
        'dueDate': selectedDueDate.value?.toIso8601String().split('T')[0],
        'linkedEntityType': selectedLinkedEntityType.value,
        'linkedEntityId': selectedLinkedEntityId.value,
      };

      final newTask = await _crmService.createTask(taskData);
      
      // Re-fetch tasks to get populated relations
      await fetchTasks();
      
      // Reset form
      subjectController.clear();
      descriptionController.clear();
      selectedDueDate.value = null;
      selectedLinkedEntityId.value = null;
      _setDefaults();
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create task: $e',
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTaskCompletion(int id) async {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = tasks[index];
    final currentStatus = task.status?.toLowerCase() ?? '';
    final isCurrentlyComplete = currentStatus.contains('complete') || currentStatus.contains('done');

    // Decide target status
    LookupModel? targetStatus;
    if (isCurrentlyComplete) {
      targetStatus = taskStatusTypes.firstWhereOrNull(
        (s) => s.title.toLowerCase().contains('not started') || s.title.toLowerCase().contains('open'),
      ) ?? taskStatusTypes.firstOrNull;
    } else {
      targetStatus = taskStatusTypes.firstWhereOrNull(
        (s) => s.title.toLowerCase().contains('complet'),
      ) ?? taskStatusTypes.lastOrNull;
    }

    if (targetStatus == null) {
      Get.snackbar('Error', 'Could not get target status');
      return;
    }

    // Optimistic local update
    tasks[index] = TaskModel(
      id: task.id,
      subject: task.subject,
      description: task.description,
      priority: task.priority,
      status: targetStatus.title,
      dueDate: task.dueDate,
      startDate: task.startDate,
      completedDate: task.completedDate,
      assigneeId: task.assigneeId,
      linkedEntityType: task.linkedEntityType,
      linkedEntityId: task.linkedEntityId,
    );
    tasks.refresh();

    try {
      await _crmService.updateTask(id, {'taskStatusTypeId': targetStatus.id});
    } catch (e) {
      // Rollback on failure
      tasks[index] = task;
      tasks.refresh();
      Get.snackbar('Error', 'Failed to update task status: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
