import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/accounts_controller.dart';
import '../../../Services/lookups_service.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/searchable_dropdown.dart';

class AddAccountModal extends StatefulWidget {
  const AddAccountModal({super.key});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  final AccountsController _accountsController = Get.find<AccountsController>();
  final LookupsService _lookups = Get.find<LookupsService>();

  final _accountNameCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _annualRevenueCtrl = TextEditingController();
  final _employeesCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  int? _accountTypeId;
  int? _interestLevelId;
  int? _paymentTermId;
  int? _paymentTermDays;
  String? _industry;
  int? _selectedCountryId;
  String? _country;
  String? _city;
  int? _zoneId;
  int? _agentId;

  List<dynamic> _cities = [];
  bool _isLoadingCities = false;
  bool _isSaving = false;

  final List<String> _industriesList = [
    "Technology", "Healthcare", "Finance", "Manufacturing", 
    "Retail", "Education", "Services", "Other"
  ];

  void _onCountryChanged(int? newCountryId) async {
    if (newCountryId == null) return;
    final countryObj = _lookups.countries.firstWhereOrNull((c) => c.id == newCountryId);
    setState(() {
      _selectedCountryId = newCountryId;
      _country = countryObj?.title;
      _city = null;
      _isLoadingCities = true;
    });
    
    final cities = await _lookups.fetchCitiesForCountry(newCountryId);
    setState(() {
      _cities = cities;
      _isLoadingCities = false;
    });
  }

  void _submit() async {
    if (_accountNameCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Account Name is required', 
          backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);
    
    final payload = {
      'accountName': _accountNameCtrl.text,
      'accountTypeId': _accountTypeId,
      'interestLevelId': _interestLevelId,
      'industry': _industry,
      'website': _websiteCtrl.text.isNotEmpty ? _websiteCtrl.text : null,
      'phone': _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
      'email': _emailCtrl.text.isNotEmpty ? _emailCtrl.text : null,
      'billingStreet': _addressCtrl.text.isNotEmpty ? _addressCtrl.text : null,
      'billingCity': _city,
      'billingCountry': _country,
      'zoneId': _zoneId,
      'paymentTermId': _paymentTermId,
      'paymentTermDays': _paymentTermDays,
      'annualRevenue': _annualRevenueCtrl.text.isNotEmpty ? _annualRevenueCtrl.text : null,
      'employees': _employeesCtrl.text.isNotEmpty ? int.tryParse(_employeesCtrl.text) : null,
      'agentId': _agentId,
      'description': _descriptionCtrl.text.isNotEmpty ? _descriptionCtrl.text : null,
    };

    final success = await _accountsController.createAccount(payload);
    setState(() => _isSaving = false);
    if (success) {
      Get.back();
      // Inform users of success on the parent view
      Get.snackbar('Success', 'Account created successfully',
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
                      Expanded(child: _buildTextField('Account Name *', _accountNameCtrl)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          _lookups.accountTypes.length; // Ensure dependency is tracked
                          return _buildDropdown<int>('Account Type', _accountTypeId, _lookups.accountTypes.toList(), (val) => setState(() => _accountTypeId = val));
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown<String>('Industry', _industry, _industriesList, (val) => setState(() => _industry = val)),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Contact & Location'),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Phone', _phoneCtrl, TextInputType.phone)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Email', _emailCtrl, TextInputType.emailAddress)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField('Street Address', _addressCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          _lookups.countries.length; // Ensure dependency is tracked
                          return _buildDropdown<int>('Country', _selectedCountryId, _lookups.countries.toList(), _onCountryChanged);
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          _lookups.zones.length; // Ensure dependency is tracked
                          return _buildDropdown<int>('Zone', _zoneId, _lookups.zones.toList(), (val) => setState(() => _zoneId = val));
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isLoadingCities
                    ? const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator()))
                    : _buildDropdown<String>('City', _city, _cities, (val) => setState(() => _city = val), disabled: _selectedCountryId == null, displayKey: 'title', valueKey: 'title'),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Business Details'),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Annual Revenue', _annualRevenueCtrl, TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Employees', _employeesCtrl, TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Website', _websiteCtrl, TextInputType.url)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          _lookups.agents.length; // Ensure dependency is tracked
                          return _buildDropdown<int>('Assigned to Agent', _agentId, _lookups.agents.toList(), (val) => setState(() => _agentId = val), displayKey: 'fullName');
                        }),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Description / Notes'),
                  _buildTextField('Description', _descriptionCtrl, TextInputType.multiline, 3),
                  
                  const SizedBox(height: 12),
                  Obx(() {
                    _lookups.paymentTerms.length; // Ensure dependency is tracked
                    return _buildDropdown<int>('Payment Terms', _paymentTermId, _lookups.paymentTerms.toList(), (val) => setState(() => _paymentTermId = val));
                  }),
                  
                  const SizedBox(height: 12),
                  Obx(() {
                    _lookups.paymentTerms.length; // Ensure dependency is tracked
                    final isCredit = _paymentTermId != null && 
                      _lookups.paymentTerms.firstWhereOrNull((t) => t.id == _paymentTermId)?.title == "Credit";
                    if (isCredit) {
                      return _buildDropdown<int>('Credit Term Days', _paymentTermDays, [
                        {'id': 10, 'title': '10 Days'},
                        {'id': 15, 'title': '15 Days'},
                        {'id': 20, 'title': '20 Days'}
                      ], (val) => setState(() => _paymentTermDays = val));
                    }
                    return const SizedBox.shrink();
                  }),
                  
                  const SizedBox(height: 24),
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
              Icon(Icons.business, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Add New Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildDropdown<T>(String label, T? value, List<dynamic> items, Function(T?) onChanged, {bool disabled = false, String displayKey = 'title', String valueKey = 'id', String? hintText}) {
    return SearchableDropdown<T>(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
      disabled: disabled,
      displayKey: displayKey,
      valueKey: valueKey,
      hintText: hintText,
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
                : const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
