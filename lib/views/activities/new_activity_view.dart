import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/new_activity_controller.dart';
import '../../utils/app_colors.dart';
import './modals/log_call_modal.dart';
import './modals/send_sms_modal.dart';
import './modals/send_email_modal.dart';

class NewActivityView extends StatelessWidget {
  const NewActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewActivityController());

    return Obx(() {
      final type = controller.actType.value.toLowerCase();
      final isSpecialized = !controller.isEditing && (type == 'call' || type == 'sms' || type == 'email');

      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Get.back(),
          ),
          title: Text(controller.isEditing ? 'Edit Activity' : 'New Activity',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            if (controller.isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, controller),
              ),
          ],
        ),
        bottomNavigationBar: isSpecialized
            ? null // Specialized forms have their own buttons
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: controller.saveActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(controller.isEditing ? 'Save Changes' : 'Create Activity',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Activity Type'),
              _buildActivityTypeSelector(controller),
              const SizedBox(height: 24),

              if (isSpecialized) ...[
                if (type == 'call')
                  LogCallForm(
                    initialEntityType: controller.linkType.value.toLowerCase(),
                    initialEntityId: controller.selectedRecord.value?.id,
                    initialEntityName: controller.selectedRecord.value != null 
                        ? controller.getRecordName(controller.selectedRecord.value) 
                        : null,
                    onSuccess: () => Get.back(result: true),
                  )
                else if (type == 'sms')
                  SendSMSForm(
                    initialEntityType: controller.linkType.value.toLowerCase(),
                    initialEntityId: controller.selectedRecord.value?.id,
                    onSuccess: () => Get.back(result: true),
                  )
                else if (type == 'email')
                  SendEmailForm(
                    initialEntityType: controller.linkType.value.toLowerCase(),
                    initialEntityId: controller.selectedRecord.value?.id,
                    onSuccess: () => Get.back(result: true),
                  ),
              ] else ...[
                // Generic Form
                _buildLabel('Date', icon: Icons.calendar_today),
                InkWell(
                  onTap: () => controller.pickDate(context),
                  child: _buildDatePickerBox(controller.selectedDateStr, icon: Icons.calendar_today),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Time', icon: Icons.access_time),
                          InkWell(
                            onTap: () => controller.pickStartTime(context),
                            child: _buildDatePickerBox(controller.startTimeStr, icon: Icons.access_time),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Time', icon: Icons.timer_outlined),
                          InkWell(
                            onTap: () => controller.pickEndTime(context),
                            child: _buildDatePickerBox(controller.endTimeStr, icon: Icons.timer_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel('Location'),
                _buildTextField(
                  hint: 'Add office location or meeting link',
                  prefixIcon: Icons.location_on_outlined,
                  controller: controller.locationController,
                ),
                const SizedBox(height: 20),

                _buildLabel('Outcome / Notes'),
                _buildTextField(
                  hint: 'Summary of the discussion...',
                  maxLines: 4,
                  controller: controller.notesController,
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    const Icon(Icons.link, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('Link To', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),

                _buildDropdownBox(controller.linkType, ['Lead', 'Deal', 'Account', 'Contact']),
                const SizedBox(height: 16),

                _buildSearchableSelect(
                  controller,
                  'Select ${controller.linkType.value}',
                  controller.availableRecords,
                ),
                const SizedBox(height: 32),

                // Reminder Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notifications, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('15 minutes before start',
                                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child:
                            const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLabel(String text, {bool isSmall = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: isSmall ? AppColors.textSecondary : AppColors.primary,
              fontSize: isSmall ? 10 : 15,
              fontWeight: FontWeight.bold,
              letterSpacing: isSmall ? 1.0 : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20) : null,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildActivityTypeSelector(NewActivityController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Row(
        children: [
          _buildActivityTypeOption(controller, 'Call', Icons.call),
          _buildActivityTypeOption(controller, 'Meeting', Icons.people_alt),
          _buildActivityTypeOption(controller, 'Email', Icons.email),
        ],
      )),
    );
  }

  Widget _buildActivityTypeOption(NewActivityController controller, String type, IconData icon) {
    final isSelected = controller.actType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setActivityType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 20),
              const SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownBox(RxString rxValue, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Obx(() {
        // Double-check value exists in options to prevent common DropdownButton error
        final value = options.contains(rxValue.value) ? rxValue.value : options.first;
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            dropdownColor: AppColors.surface,
            items: options.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) rxValue.value = newValue;
            },
          ),
        );
      }),
    );
  }

  Widget _buildDatePickerBox(RxString rxValue, {IconData icon = Icons.calendar_today}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final isNotSet = rxValue.value.contains('Select') || rxValue.value.contains('Set');
            return Text(
              rxValue.value,
              style: TextStyle(
                color: isNotSet ? AppColors.textSecondary : Colors.white,
                fontSize: 14,
                fontWeight: isNotSet ? FontWeight.normal : FontWeight.bold,
              ),
            );
          }),
          Icon(icon, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildSearchableSelect(NewActivityController controller, String hint, List<dynamic> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  border: InputBorder.none,
                ),
              ),
              Obx(() {
                if (controller.isLoadingRecords.value) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                
                if (controller.searchQuery.isNotEmpty || controller.selectedRecord.value == null) {
                  return Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final name = controller.getRecordName(option);
                        return ListTile(
                          title: Text(name, style: const TextStyle(fontSize: 14)),
                          onTap: () {
                            controller.selectedRecord.value = option;
                            controller.searchQuery.value = '';
                            FocusScope.of(context).unfocus();
                          },
                          trailing: controller.selectedRecord.value == option 
                              ? const Icon(Icons.check, color: AppColors.primary, size: 18) 
                              : null,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        Obx(() {
          if (controller.selectedRecord.value != null && controller.searchQuery.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Linked to: ${controller.getRecordName(controller.selectedRecord.value)}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _confirmDelete(BuildContext context, NewActivityController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this activity? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.deleteActivity();
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
