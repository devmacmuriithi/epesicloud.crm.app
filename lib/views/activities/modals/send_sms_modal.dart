import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/communication_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../models/lead_model.dart';
import '../../../models/crm_models.dart';

class SendSMSModal extends StatelessWidget {
  final String? initialEntityType;
  final int? initialEntityId;
  final String? initialPhone;

  const SendSMSModal({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
    this.initialPhone,
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
              const Icon(Icons.message, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text('Send SMS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          SendSMSForm(
            initialEntityType: initialEntityType,
            initialEntityId: initialEntityId,
            initialPhone: initialPhone,
            onSuccess: () => Get.back(result: true),
          ),
        ],
      ),
    );
  }
}

class SendSMSForm extends StatefulWidget {
  final String? initialEntityType;
  final int? initialEntityId;
  final String? initialPhone;
  final VoidCallback? onSuccess;

  const SendSMSForm({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
    this.initialPhone,
    this.onSuccess,
  });

  @override
  State<SendSMSForm> createState() => _SendSMSFormState();
}

class _SendSMSFormState extends State<SendSMSForm> {
  final controller = Get.put(CommunicationController());
  
  String? selectedType;
  int? selectedId;
  final messageController = TextEditingController();
  int charCount = 0;
  int maxChars = 160;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialEntityType ?? 'account';
    selectedId = widget.initialEntityId;
    messageController.addListener(() {
      setState(() {
        charCount = messageController.text.length;
      });
    });
  }

  void _handleSubmit() async {
    if (selectedId == null) {
      Get.snackbar('Error', 'Please select a linked entity');
      return;
    }

    if (messageController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a message');
      return;
    }

    final now = DateTime.now();
    
    final smsType = controller.activityTypes.firstWhereOrNull(
      (t) => (t['title'] ?? '').toLowerCase() == 'sms' || (t['name'] ?? '').toLowerCase() == 'sms'
    );

    final data = {
      'subject': 'SMS Delivery',
      'description': messageController.text,
      'activityTypeId': smsType?['id'] ?? 4,
      'startDate': DateFormat('yyyy-MM-dd').format(now),
      'startDateTime': now.toIso8601String(),
      'endDateTime': now.add(const Duration(minutes: 1)).toIso8601String(),
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
    int smsCount = (charCount / maxChars).ceil();
    if (smsCount == 0) smsCount = 1;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linked Entity Selection (CRUCIAL)
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


            // Message
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                Text('$charCount/$maxChars chars ($smsCount SMS)', 
                  style: TextStyle(fontSize: 11, color: charCount > maxChars ? Colors.red : AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your message...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send SMS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
