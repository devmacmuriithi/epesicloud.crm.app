import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/communication_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../models/lead_model.dart';
import '../../../models/crm_models.dart';

class LogCallModal extends StatelessWidget {
  final String? initialEntityType;
  final int? initialEntityId;
  final String? initialEntityName;

  const LogCallModal({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
    this.initialEntityName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.phone, color: AppColors.success, size: 28),
              const SizedBox(width: 12),
              const Text('Log Call', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          LogCallForm(
            initialEntityType: initialEntityType,
            initialEntityId: initialEntityId,
            initialEntityName: initialEntityName,
            onSuccess: () => Get.back(result: true),
          ),
        ],
      ),
    );
  }
}

class LogCallForm extends StatefulWidget {
  final String? initialEntityType;
  final int? initialEntityId;
  final String? initialEntityName;
  final VoidCallback? onSuccess;

  const LogCallForm({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
    this.initialEntityName,
    this.onSuccess,
  });

  @override
  State<LogCallForm> createState() => _LogCallFormState();
}

class _LogCallFormState extends State<LogCallForm> {
  final controller = Get.put(CommunicationController());
  
  String? selectedType;
  int? selectedId;
  int? selectedActivityTypeId;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialEntityType ?? 'account';
    selectedId = widget.initialEntityId;
  }

  void _handleSubmit() async {
    if (selectedId == null) {
      Get.snackbar('Error', 'Please select a linked entity');
      return;
    }

    final fullDateTime = DateTime(
      selectedDate.year, 
      selectedDate.month, 
      selectedDate.day, 
      selectedTime.hour, 
      selectedTime.minute
    );

    final data = {
      'subject': 'Logged Call with ${widget.initialEntityName ?? selectedType}',
      'description': notesController.text,
      'activityTypeId': selectedActivityTypeId ?? 1,
      'startDate': DateFormat('yyyy-MM-dd').format(selectedDate),
      'startDateTime': fullDateTime.toIso8601String(),
      'endDateTime': fullDateTime.add(const Duration(minutes: 15)).toIso8601String(),
      // Map to explicit backend fields
      if (selectedType == 'lead') 'leadId': selectedId,
      if (selectedType == 'account') 'accountId': selectedId,
      if (selectedType == 'contact') 'contactId': selectedId,
      if (selectedType == 'deal') 'dealId': selectedId,
    };

    final success = await controller.submitActivity(data);
    if (success && widget.onSuccess != null) {
      widget.onSuccess!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linked To Selection
            if (widget.initialEntityId == null) ...[
              const Text('Linked To', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      value: selectedType,
                      items: ['account', 'contact', 'lead', 'deal'].map((t) => DropdownMenuItem(value: t, child: Text(t.capitalizeFirst!))).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedType = val;
                          selectedId = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildDropdown(
                      value: selectedId,
                      items: _buildEntityItems(),
                      onChanged: (val) => setState(() => selectedId = val as int?),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],


            // Call Type
            const Text('Call Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
            const SizedBox(height: 8),
            _buildDropdown(
              value: selectedActivityTypeId,
              items: controller.activityTypes
                  .where((t) => (t['title'] ?? '').toLowerCase().contains('call'))
                  .map((t) => DropdownMenuItem(value: t['id'], child: Text(t['title'] ?? 'Call')))
                  .toList(),
              onChanged: (val) => setState(() => selectedActivityTypeId = val as int?),
            ),
            const SizedBox(height: 16),

            // Date/Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                          if (picked != null) setState(() => selectedDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                          child: Text(DateFormat('MMM dd, yyyy').format(selectedDate), style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: selectedTime);
                          if (picked != null) setState(() => selectedTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                          child: Text(selectedTime.format(context), style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Call Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(hintText: 'Discussed terms...', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Log Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  List<DropdownMenuItem<int>> _buildEntityItems() {
    if (selectedType == 'account') {
      return controller.accounts.map((e) => DropdownMenuItem(value: e.id, child: Text(e.accountName))).toList();
    } else if (selectedType == 'contact') {
      return controller.contacts.map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName))).toList();
    } else if (selectedType == 'lead') {
      return controller.leads.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList();
    } else if (selectedType == 'deal') {
      return controller.deals.map((e) => DropdownMenuItem(value: e.id, child: Text(e.dealName))).toList();
    }
    return [];
  }

  Widget _buildDropdown({required dynamic value, required List<DropdownMenuItem<dynamic>> items, required Function(dynamic) onChanged}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)), child: DropdownButtonHideUnderline(child: DropdownButton<dynamic>(value: value, isExpanded: true, items: items, onChanged: onChanged)));
  }
}
