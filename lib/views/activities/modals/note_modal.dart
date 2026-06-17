import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/communication_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../models/crm_models.dart';

class NoteModal extends StatelessWidget {
  final String? initialEntityType;
  final int? initialEntityId;

  const NoteModal({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.sticky_note_2, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  const Text('Add Note', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              NoteForm(
                initialEntityType: initialEntityType,
                initialEntityId: initialEntityId,
                onSuccess: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteForm extends StatefulWidget {
  final String? initialEntityType;
  final int? initialEntityId;
  final VoidCallback? onSuccess;

  const NoteForm({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
    this.onSuccess,
  });

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final controller = Get.put(CommunicationController());
  
  String? selectedType;
  int? selectedId;
  
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialEntityType ?? 'account';
    selectedId = widget.initialEntityId;
  }

  Future<void> _handleSubmit() async {
    if (selectedId == null) {
      Get.snackbar('Error', 'Please select a linked entity');
      return;
    }

    if (bodyController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter note content');
      return;
    }

    final data = {
      'title': titleController.text.isEmpty ? 'Untitled Note' : titleController.text,
      'content': bodyController.text,
      // Map to explicit backend fields
      if (selectedType == 'lead') 'leadId': selectedId,
      if (selectedType == 'account') 'accountId': selectedId,
      if (selectedType == 'contact') 'contactId': selectedId,
      if (selectedType == 'deal') 'dealId': selectedId,
    };

    final success = await controller.submitNote(data);
    if (success) {
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

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Linked Entity Selection
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


            _buildLabel('Title (Optional)'),
            _buildTextField(titleController, 'Enter note title'),
            const SizedBox(height: 12),

            _buildLabel('Content *'),
            TextField(
              controller: bodyController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your note here...',
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white, size: 18),
                    SizedBox(width: 12),
                    Text('Save Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
      );
    });
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)));

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
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
