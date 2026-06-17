import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/activities_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/crm_models.dart';
import '../../views/activities/modals/log_call_modal.dart';
import '../../views/activities/modals/send_email_modal.dart';
import '../../views/activities/modals/send_sms_modal.dart';
import '../../views/activities/modals/note_modal.dart';
import '../../views/activities/modals/document_modal.dart';
import '../../widgets/activity_action_bottom_sheet.dart';

class ActivitiesView extends StatelessWidget {
  const ActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivitiesController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildCommunicationActions(context),
            _buildSearchAndFilters(controller),
            
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.allActivities.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (controller.activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text('No ${controller.selectedFilter.value == 'All' ? '' : controller.selectedFilter.value.toLowerCase()} activities found', 
                             style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchActivities(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.activities.length,
                    itemBuilder: (context, index) {
                      return _buildActivityCard(controller.activities[index], controller);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activities',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'Manage your tasks and events',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: AppColors.primary),
              onPressed: () => Get.toNamed('/calendar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ActivitiesController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (value) => controller.filterActivities(value),
            decoration: InputDecoration(
              hintText: 'Search subject or type...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: controller.filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Obx(() => _buildFilterChip(
                  filter,
                  isSelected: controller.selectedFilter.value == filter,
                  onTap: () => controller.setFilter(filter),
                )),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCommunicationActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 20),
              _buildActionItem(Icons.phone_outlined, 'Call', onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => const ActivityActionBottomSheet(
                  actionType: 'call',
                ),
              )),
              const SizedBox(width: 20),
              _buildActionItem(Icons.message_outlined, 'SMS', onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => const ActivityActionBottomSheet(
                  actionType: 'sms',
                ),
              )),
              const SizedBox(width: 20),
              _buildActionItem(Icons.email_outlined, 'Email', onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => const ActivityActionBottomSheet(
                  actionType: 'email',
                ),
              )),
              const SizedBox(width: 20),
              _buildActionItem(Icons.note_add_outlined, 'Note', onTap: () => Get.bottomSheet(const NoteModal(), isScrollControlled: true)),
              const SizedBox(width: 20),
              _buildActionItem(Icons.upload_file_outlined, 'Doc', onTap: () => Get.bottomSheet(const DocumentModal(), isScrollControlled: true)),
              const SizedBox(width: 20),
              _buildActionItem(Icons.add_task_outlined, 'Activity', onTap: () => Get.toNamed('/new-activity')),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity, ActivitiesController controller) {
    Color statusColor = controller.getStatusColor(activity.status);
    
    return GestureDetector(
      onTap: () => Get.toNamed('/new-activity', arguments: activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activity.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activity.type.toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activity.subject,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (activity.location != null && activity.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(activity.location!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      activity.startDate ?? 'No date',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (activity.linkedEntityName != null) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(_getEntityIcon(activity.linkedEntityType), size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          activity.linkedEntityName!,
                          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEntityIcon(String? type) {
    if (type == null) return Icons.link;
    switch (type.toLowerCase()) {
      case 'lead': return Icons.bolt;
      case 'deal': return Icons.monetization_on_outlined;
      case 'account': return Icons.business;
      case 'contact': return Icons.person;
      default: return Icons.link;
    }
  }
}
