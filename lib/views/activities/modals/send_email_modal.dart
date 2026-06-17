import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/communication_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../models/lead_model.dart';
import '../../../models/crm_models.dart';

class SendEmailModal extends StatefulWidget {
  final String? initialEntityType;
  final int? initialEntityId;
  final String? initialEmail;
  final bool sendAfterLog;

  const SendEmailModal({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
    this.initialEmail,
    this.sendAfterLog = false,
  });

  @override
  State<SendEmailModal> createState() => _SendEmailModalState();
}

class _SendEmailModalState extends State<SendEmailModal> {
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.email, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(widget.sendAfterLog ? 'Log & Send Email' : 'Log Email', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            SendEmailForm(
              initialEntityType: widget.initialEntityType,
              initialEntityId: widget.initialEntityId,
              initialEmail: widget.initialEmail,
              sendAfterLog: widget.sendAfterLog,
              onSuccess: null,
            ),
          ],
        ),
      ),
    );
  }
}

class SendEmailForm extends StatefulWidget {
  final String? initialEntityType;
  final int? initialEntityId;
  final String? initialEmail;
  final bool sendAfterLog;
  final VoidCallback? onSuccess;

  const SendEmailForm({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
    this.initialEmail,
    this.sendAfterLog = false,
    this.onSuccess,
  });

  @override
  State<SendEmailForm> createState() => _SendEmailFormState();
}

class _SendEmailFormState extends State<SendEmailForm> {
  final controller = Get.put(CommunicationController());
  
  String? selectedType;
  int? selectedId;
  String? selectedPriority;
  
  final toController = TextEditingController();
  final ccController = TextEditingController();
  final bccController = TextEditingController();
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialEntityType ?? 'account';
    selectedId = widget.initialEntityId;
    toController.text = widget.initialEmail ?? '';
  }

  Future<void> _handleSubmit() async {
    if (selectedId == null) {
      Get.snackbar('Error', 'Please select a linked entity');
      return;
    }

    if (toController.text.isEmpty || subjectController.text.isEmpty || bodyController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in required fields (To, Subject, Message)');
      return;
    }

    final location = [
      toController.text,
      ccController.text.isNotEmpty ? 'CC:${ccController.text}' : null,
      bccController.text.isNotEmpty ? 'BCC:${bccController.text}' : null,
    ].where((e) => e != null).join(', ');

    final now = DateTime.now();
    
    final emailType = controller.activityTypes.firstWhereOrNull(
      (t) => (t['title'] ?? '').toLowerCase() == 'email' || (t['name'] ?? '').toLowerCase() == 'email'
    );

    final data = {
      'subject': 'Email: ${subjectController.text}',
      'description': bodyController.text,
      'location': location,
      'priority': selectedPriority ?? 'Medium',
      'activityTypeId': emailType?['id'] ?? 3,
      'startDate': DateFormat('yyyy-MM-dd').format(now),
      'startDateTime': now.toIso8601String(),
      'endDateTime': now.add(const Duration(minutes: 5)).toIso8601String(),
      // Map to explicit backend fields
      if (selectedType == 'lead') 'leadId': selectedId,
      if (selectedType == 'account') 'accountId': selectedId,
      if (selectedType == 'contact') 'contactId': selectedId,
      if (selectedType == 'deal') 'dealId': selectedId,
    };

    final success = await controller.submitActivity(data);
    if (success) {
      if (widget.sendAfterLog) {
        final to = toController.text;
        final subject = subjectController.text;
        final body = bodyController.text;
        if (to.isNotEmpty) {
          try {
            await launchUrl(
              Uri(
                scheme: 'mailto',
                path: to,
                queryParameters: {
                  if (subject.isNotEmpty) 'subject': subject,
                  if (body.isNotEmpty) 'body': body,
                },
              ),
              mode: LaunchMode.externalApplication,
            );
          } catch (_) {}
        }
      }
      if (widget.onSuccess != null) widget.onSuccess!();
      if (mounted) Navigator.of(context, rootNavigator: true).pop(true);
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
            // Linked Entity Selection
            if (widget.initialEntityId == null) ...[
              const Text('Linked To', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
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


            // Recipients
            _buildLabel('To *'),
            _buildTextField(toController, 'recipient@example.com', Icons.person_outline),
            const SizedBox(height: 12),
            
            _buildLabel('Subject *'),
            _buildTextField(subjectController, 'Enter email subject'),
            const SizedBox(height: 12),

            _buildLabel('Priority'),
            _buildDropdown(
              value: selectedPriority,
              items: controller.priorities
                  .map((p) => DropdownMenuItem(value: p['title'] ?? p['name'], child: Text(p['title'] ?? p['name'])))
                  .toList(),
              onChanged: (val) => setState(() => selectedPriority = val as String?),
            ),
            const SizedBox(height: 12),

            _buildLabel('Message *'),
            TextField(
              controller: bodyController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Compose your email...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, color: Colors.white, size: 18),
                    const SizedBox(width: 12),
                    Text(widget.sendAfterLog ? 'Log & Send Email' : 'Log Email', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)));

  Widget _buildTextField(TextEditingController ctrl, String hint, [IconData? icon]) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
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
