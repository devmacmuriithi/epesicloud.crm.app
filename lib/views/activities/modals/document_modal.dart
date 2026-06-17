import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/communication_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../models/crm_models.dart';

class DocumentModal extends StatelessWidget {
  final String? initialEntityType;
  final int? initialEntityId;

  const DocumentModal({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
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
              const Icon(Icons.description, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Text('Upload Document', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          DocumentForm(
            initialEntityType: initialEntityType,
            initialEntityId: initialEntityId,
            onSuccess: () => Get.back(),
          ),
        ],
      ),
    );
  }
}

class DocumentForm extends StatefulWidget {
  final String? initialEntityType;
  final int? initialEntityId;
  final VoidCallback? onSuccess;

  const DocumentForm({
    super.key,
    this.initialEntityType,
    this.initialEntityId,
    this.onSuccess,
  });

  @override
  State<DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<DocumentForm> {
  final controller = Get.put(CommunicationController());
  
  String? selectedType;
  int? selectedId;
  String? pickedFileName;
  String? pickedBase64;
  
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialEntityType ?? 'account';
    selectedId = widget.initialEntityId;
  }

  void _simulateFilePick() {
    // In a real app without file_picker, we would use a MethodChannel
    // For this phase, we simulate the 'In-Built Selector'
    setState(() {
      pickedFileName = 'picked_document_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}.pdf';
      // Minimum valid PDF base64 for simulation
      pickedBase64 = 'data:application/pdf;base64,JVBERi0xLjcK1erkCjEgMCBvYmoKPDwvVHlwZS9DYXRhbG9nL1BhZ2VzIDIgMCBSPj4KZW5kb2JqCjIgMCBvYmoKPDwvVHlwZS9QYWdlcy9Db3VudCAxL0tpZHNbMyAwIFJdPj4KZW5kb2JqCjMgMCBvYmoKPDwvVHlwZS9QYWdlL1BhcmVudCAyIDAgUi9NZWRpYUJveFswIDAgNTk1IDg0Ml0vUmVzb3VyY2VzPDwvRm9udDw8L0YxIDQgMCBSPj4+Pi9Db250ZW50cyA1IDAgUj4+CmVuZG9icgo0IDAgb2JqCjw8L1R5cGUvRm9udC9TdWJ0eXBlL1R5cGUxL0Jhc2VGb250L0hlbHZldGljYT4+CmVuZG9icgo1IDAgb2JqCjw8L0xlbmd0aCA0ND4+CnN0cmVhbQpCVAovRjEgMjQgVGYKNzAgNzIwIFRkCihIZWxsbyBlcGVzaWNsb3VkISkgVGoKRVQKZW5kc3RyZWFtCmVuZG9icgp4cmVmCjAgNgowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDAwMTcgMDAwMDAgbiAKMDAwMDAwMDA2NyAwMDAwMCBuIAowMDAwMDAwMTE3IDAwMDAwIG4gCjAwMDAwMDAyNjAgMDAwMDAgbiAKMDAwMDAwMDMxMSAwMDAwMCBuIAp0cmFpbGVyCjw8L1NpemUgNi9Sb290IDEgMCBSPj4Kc3RhcnR4cmVmCjQxNAolJUVPRgo=';
    });
    Get.snackbar('Success', 'File selected via in-built explorer (Simulated)');
  }

  void _handleSubmit() {
    if (selectedId == null) {
      Get.snackbar('Error', 'Please select a linked entity');
      return;
    }

    if (pickedBase64 == null) {
      Get.snackbar('Error', 'Please select a file first');
      return;
    }

    final data = {
      'fileName': pickedFileName,
      'fileUrl': pickedBase64, // Real Base64 Data URI
      'fileType': 'PDF',
      'fileSize': 1024 * 12, // ~12KB for the simulated PDF
      'description': descriptionController.text,
      // Map to explicit backend fields
      if (selectedType == 'lead') 'leadId': selectedId,
      if (selectedType == 'account') 'accountId': selectedId,
      if (selectedType == 'contact') 'contactId': selectedId,
      if (selectedType == 'deal') 'dealId': selectedId,
    };

    if (widget.onSuccess != null) widget.onSuccess!();
    controller.submitDocument(data);
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
              const SizedBox(height: 20),
            ],
            


            // Upload Area Placeholder
            GestureDetector(
              onTap: _simulateFilePick,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: pickedFileName != null ? AppColors.success : AppColors.primary.withOpacity(0.3), 
                    width: 1.5, 
                    style: BorderStyle.solid
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      pickedFileName != null ? Icons.check_circle : Icons.cloud_upload_outlined, 
                      color: pickedFileName != null ? AppColors.success : AppColors.primary, 
                      size: 40
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pickedFileName ?? 'Tap to select a file', 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(
                      pickedFileName != null ? 'In-Built Explorer Result' : 'PDF, DOC, PNG up to 25MB', 
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Description (Optional)'),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a note about this document...',
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
                    Icon(Icons.upload_file, color: Colors.white, size: 18),
                    SizedBox(width: 12),
                    Text('Upload Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
