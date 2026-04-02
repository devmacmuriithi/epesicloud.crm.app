import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/leads_controller.dart';
import '../../../Services/lookups_service.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/searchable_dropdown.dart';

class AddLeadModal extends StatefulWidget {
  const AddLeadModal({super.key});

  @override
  State<AddLeadModal> createState() => _AddLeadModalState();
}

class _AddLeadModalState extends State<AddLeadModal> {
  final LeadsController _leadsController = Get.find<LeadsController>();
  final LookupsService _lookups = Get.find<LookupsService>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  int? _accountId;
  int? _productId;
  int? _leadSourceId;
  int? _interestLevelId;
  int? _leadStatusTypeId;
  int? _agentId;

  bool _isSaving = false;

  void _submit() async {
    if (_firstNameCtrl.text.isEmpty || _lastNameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
      Get.snackbar('Error', 'First Name, Last Name and Email are required',
          backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);
    
    final payload = {
      'firstName': _firstNameCtrl.text,
      'lastName': _lastNameCtrl.text,
      'email': _emailCtrl.text,
      'phone': _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
      'company': _companyCtrl.text.isNotEmpty ? _companyCtrl.text : null,
      'accountId': _accountId,
      'leadSourceId': _leadSourceId,
      'interestLevelId': _interestLevelId,
      'leadStatusTypeId': _leadStatusTypeId,
      'productId': _productId,
      'agentId': _agentId,
      'description': _descriptionCtrl.text.isNotEmpty ? _descriptionCtrl.text : null,
    };

    final success = await _leadsController.createLead(payload);
    setState(() => _isSaving = false);
    if (success) {
      Get.back();
      // Inform users of success on the parent view
      Get.snackbar('Success', 'Lead created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Basic Information'),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('First Name *', _firstNameCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Last Name *', _lastNameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Email *', _emailCtrl, TextInputType.emailAddress)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Phone', _phoneCtrl, TextInputType.phone)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Company & Account'),
                  _buildTextField('Company', _companyCtrl),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Sales Qualification'),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          _lookups.products.length; // Ensure dependency is tracked
                          return _buildDropdown('Interested Product', _productId, _lookups.products.toList(), (val) => setState(() => _productId = val), displayKey: 'productName');
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          _lookups.leadSources.length; // Ensure dependency is tracked
                          return _buildDropdown('Lead Source', _leadSourceId, _lookups.leadSources.toList(), (val) => setState(() => _leadSourceId = val));
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          _lookups.interestLevels.length; // Ensure dependency is tracked
                          return _buildDropdown('Interest Level', _interestLevelId, _lookups.interestLevels.toList(), (val) => setState(() => _interestLevelId = val));
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          _lookups.leadStatusTypes.length; // Ensure dependency is tracked
                          return _buildDropdown('Lead Status', _leadStatusTypeId, _lookups.leadStatusTypes.toList(), (val) => setState(() => _leadStatusTypeId = val));
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    _lookups.agents.length; // Ensure dependency is tracked
                    return _buildDropdown('Assigned To', _agentId, _lookups.agents.toList(), (val) => setState(() => _agentId = val), displayKey: 'fullName');
                  }),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Description / Notes'),
                  _buildTextField('Description', _descriptionCtrl, TextInputType.multiline, 3),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.person_add, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Add New Lead', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, [TextInputType type = TextInputType.text, int maxLines = 1]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown(String label, int? value, List<dynamic> items, Function(int?) onChanged, {String displayKey = 'title'}) {
    return SearchableDropdown<int>(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
      displayKey: displayKey,
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create Lead', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
