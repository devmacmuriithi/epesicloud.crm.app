import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tasks_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/crm_models.dart';
import '../../models/lead_model.dart';
import '../../widgets/searchable_dropdown.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TasksController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () => controller.toggleSearch(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddTaskSheet(context, controller),
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => controller.isSearchExpanded.value
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) => controller.searchQuery.value = value,
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => controller.toggleSearch(),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
            ),
            TabBar(
              controller: controller.tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              dividerColor: AppColors.divider,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Today'),
                Tab(text: 'Overdue'),
                Tab(text: 'Upcoming'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildTasksList(controller),
                  const Center(child: Text('Today Tasks', style: TextStyle(color: AppColors.textSecondary))),
                  const Center(child: Text('Overdue Tasks', style: TextStyle(color: AppColors.textSecondary))),
                  const Center(child: Text('Upcoming Tasks', style: TextStyle(color: AppColors.textSecondary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(TasksController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.tasks.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.filteredTasks.isEmpty) {
        return const Center(child: Text('No tasks found', style: TextStyle(color: AppColors.textSecondary)));
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchTasks(),
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.filteredTasks.length,
          itemBuilder: (context, index) {
            return _buildTaskCard(controller.filteredTasks[index], controller);
          },
        ),
      );
    });
  }

  Widget _buildTaskCard(TaskModel task, TasksController controller) {
    final status = task.status?.toLowerCase() ?? 'not started';
    final isCompleted = status.contains('complete') || status.contains('done');

    Color priorityColor;
    final priority = task.priority?.toUpperCase() ?? 'MEDIUM';
    switch (priority) {
      case 'HIGH': priorityColor = Colors.redAccent; break;
      case 'MEDIUM': priorityColor = Colors.amber; break;
      case 'LOW': priorityColor = AppColors.textSecondary; break;
      default: priorityColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.toggleTaskCompletion(task.id),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCompleted ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildBadge(priority, priorityColor),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    task.dueDate ?? 'No date',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildBadge(task.status ?? 'Not Started', AppColors.primary.withOpacity(0.8)),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.background,
                    child: const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, TasksController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Task',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Linked Entity Selection
              const Text('Relate To *', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['account', 'contact', 'lead', 'deal'].map((type) {
                    final isSelected = controller.selectedLinkedEntityType.value == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type.capitalizeFirst!),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectedLinkedEntityType.value = type;
                            controller.selectedLinkedEntityId.value = null;
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              )),
              const SizedBox(height: 8),
              Obx(() {
                final type = controller.selectedLinkedEntityType.value;
                List<dynamic> items = [];
                String displayKey = '';
                if (type == 'account') { items = controller.accounts; displayKey = 'accountName'; }
                else if (type == 'contact') { items = controller.contacts; displayKey = 'fullName'; }
                else if (type == 'lead') { items = controller.leads; displayKey = 'name'; }
                else if (type == 'deal') { items = controller.deals; displayKey = 'dealName'; }
                
                return SearchableDropdown<int>(
                  label: 'Select ${type.capitalizeFirst}',
                  value: controller.selectedLinkedEntityId.value,
                  items: items,
                  onChanged: (val) => controller.selectedLinkedEntityId.value = val,
                  displayKey: displayKey,
                  valueKey: 'id',
                );
              }),

              const SizedBox(height: 20),
              _buildTextField('Subject *', 'What needs to be done?', null, 1, controller.subjectController),
              const SizedBox(height: 20),
              _buildTextField('Description', 'Provide more details...', null, 3, controller.descriptionController),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildDropdownField<int>(
                      'Task Type',
                      controller.selectedTaskTypeId.value,
                      controller.taskTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title))).toList(),
                      (val) => controller.selectedTaskTypeId.value = val,
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => _buildDropdownField<int>(
                      'Status',
                      controller.selectedStatusTypeId.value,
                      controller.taskStatusTypes.map((s) => DropdownMenuItem(value: s.id, child: Text(s.title))).toList(),
                      (val) => controller.selectedStatusTypeId.value = val,
                    )),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildDropdownField<int>(
                      'Priority',
                      controller.selectedPriorityId.value,
                      controller.priorities.map((p) => DropdownMenuItem(value: p.id, child: Text(p.title))).toList(),
                      (val) => controller.selectedPriorityId.value = val,
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(context, controller),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () async {
                    final success = await controller.submitTask();
                    if (success) {
                      Get.back();
                      Get.snackbar('Success', 'Task created successfully',
                          backgroundColor: AppColors.success, colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                )),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  List<DropdownMenuItem<int>> _getLinkedEntityItems(TasksController controller) {
    switch (controller.selectedLinkedEntityType.value) {
      case 'account':
        return controller.accounts.map((e) => DropdownMenuItem(value: e.id, child: Text(e.accountName))).toList();
      case 'contact':
        return controller.contacts.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.firstName} ${e.lastName}'))).toList();
      case 'lead':
        return controller.leads.map((e) => DropdownMenuItem<int>(value: e.id, child: Text('${e.firstName} ${e.lastName}'))).toList();
      case 'deal':
        return controller.deals.map((e) => DropdownMenuItem(value: e.id, child: Text(e.dealName))).toList();
      default:
        return [];
    }
  }

  Widget _buildDropdownField<T>(String label, T? value, List<DropdownMenuItem<T>> items, Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, TasksController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) controller.selectedDueDate.value = date;
          },
          child: Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.selectedDueDate.value == null
                  ? 'Select Date'
                  : '${controller.selectedDueDate.value!.day}/${controller.selectedDueDate.value!.month}/${controller.selectedDueDate.value!.year}',
              style: TextStyle(color: controller.selectedDueDate.value == null ? AppColors.textSecondary : AppColors.textPrimary),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, [String? hintText, TextInputType? keyboardType, int maxLines = 1, TextEditingController? controller]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
