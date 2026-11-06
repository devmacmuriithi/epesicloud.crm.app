import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/deals_controller.dart';
import '../../../controllers/leads_controller.dart';
import '../../../controllers/accounts_controller.dart';
import '../../../Services/lookups_service.dart';
import '../../../utils/app_colors.dart';
import '../../../models/crm_models.dart';
import '../../../widgets/searchable_dropdown.dart';

class AddDealModal extends StatefulWidget {
  final ProductModel? initialProduct;
  const AddDealModal({super.key, this.initialProduct});

  @override
  State<AddDealModal> createState() => _AddDealModalState();
}

class _AddDealModalState extends State<AddDealModal> {
  final DealsController _dealsController = Get.find<DealsController>();
  final LookupsService _lookups = Get.find<LookupsService>();

  // Ensure these exist, or handle gracefully
  LeadsController? get _leadsController => Get.isRegistered<LeadsController>() ? Get.find<LeadsController>() : null;
  AccountsController? get _accountsController => Get.isRegistered<AccountsController>() ? Get.find<AccountsController>() : null;

  final _quantityCtrl = TextEditingController(text: '1');
  final _salePriceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  int? _productId;
  int? _dealTypeId;
  int? _pipelineId;
  int? _stageId;
  DateTime? _expectedCloseDate;
  
  String _linkedEntityType = 'account';
  int? _linkedEntityId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_dealsController.preSelectedAccountId != null) {
      _linkedEntityType = 'account';
      _linkedEntityId = _dealsController.preSelectedAccountId;
      _dealsController.preSelectedAccountId = null;
    } else if (_dealsController.preSelectedLeadId != null) {
      _linkedEntityType = 'lead';
      _linkedEntityId = _dealsController.preSelectedLeadId;
      _dealsController.preSelectedLeadId = null;
    }

    if (widget.initialProduct != null) {
      _productId = widget.initialProduct!.id;
      if (widget.initialProduct!.price != null) {
        _salePriceCtrl.text = widget.initialProduct!.price.toString();
      }
      
      if (widget.initialProduct!.collection?.salesPipelineId != null) {
        _pipelineId = widget.initialProduct!.collection!.salesPipelineId;
        _lookups.fetchSalesStages(pipelineId: _pipelineId);
      } else if (_lookups.pipelines.isNotEmpty) {
        _pipelineId = _lookups.pipelines.first.id;
        _lookups.fetchSalesStages(pipelineId: _pipelineId);
      }
    }
    
    // Default closing date to 7 days from now
    _expectedCloseDate = DateTime.now().add(const Duration(days: 7));

    // Default deal type to "Existing Business"
    if (_lookups.dealTypes.isNotEmpty) {
      final existing = _lookups.dealTypes.firstWhereOrNull((dt) => dt.title.toLowerCase() == 'existing business');
      if (existing != null) {
        _dealTypeId = existing.id;
      }
    }
  }

  void _submit() async {
    if (_productId == null || _expectedCloseDate == null || _linkedEntityId == null) {
      Get.snackbar('Validation', 'Product, Closing Date, and Related Entity are required',
          backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);
    
    // Auto-generate deal name based on product
    final selectedProduct = _lookups.products.firstWhereOrNull((p) => p.id == _productId);
    final selectedEntityName = _getLinkedEntityName();
    final dealName = '${selectedProduct?.productName ?? 'Deal'} - $selectedEntityName';

    int? accId = _linkedEntityType == 'account' ? _linkedEntityId : null;
    int? leadId = _linkedEntityType == 'lead' ? _linkedEntityId : null;
    int? contactId = _linkedEntityType == 'contact' ? _linkedEntityId : null;

    final payload = {
      'dealName': dealName,
      'productId': _productId,
      'quantity': int.tryParse(_quantityCtrl.text) ?? 1,
      'salePrice': _salePriceCtrl.text.isNotEmpty ? double.tryParse(_salePriceCtrl.text) : null,
      'accountId': accId,
      'leadId': leadId,
      'contactId': contactId,
      'dealTypeId': _dealTypeId,
      'closingDate': DateFormat('yyyy-MM-dd').format(_expectedCloseDate!),
      'description': _descriptionCtrl.text.isNotEmpty ? _descriptionCtrl.text : null,
      'pipelineId': _pipelineId,
      'stageId': _stageId,
    };

    final success = await _dealsController.createDeal(payload);
    setState(() => _isSaving = false);
    if (success) {
      Get.back(result: true);
      // Inform users of success on the parent view
      Get.snackbar('Success', 'Deal created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
    }
  }

  String _getLinkedEntityName() {
    if (_linkedEntityType == 'account') {
      return _accountsController?.accounts.firstWhereOrNull((a) => a.id == _linkedEntityId)?.accountName ?? 'Unknown Account';
    } else if (_linkedEntityType == 'lead') {
      return _leadsController?.leads.firstWhereOrNull((l) => l.id == _linkedEntityId)?.name ?? 'Unknown Lead';
    }
    return 'Unknown Contact'; // Contacts not fully implemented in controllers yet
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Get.theme.copyWith(
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _expectedCloseDate = date);
    }
  }

  void _onProductSelected(int? val) {
    setState(() {
      _productId = val;
      _stageId = null;
      final selectedProduct = _lookups.products.firstWhereOrNull((p) => p.id == val);
      if (selectedProduct != null) {
        // Auto-fill price
        if (selectedProduct.price != null) {
          _salePriceCtrl.text = selectedProduct.price.toString();
        }
        // Auto-set pipeline from product's collection
        if (selectedProduct.collection?.salesPipelineId != null) {
          _pipelineId = selectedProduct.collection!.salesPipelineId;
          _lookups.fetchSalesStages(pipelineId: _pipelineId);
        } else if (_pipelineId == null) {
          // Fallback: use first available pipeline
          if (_lookups.pipelines.isNotEmpty) {
            _pipelineId = _lookups.pipelines.first.id;
            _lookups.fetchSalesStages(pipelineId: _pipelineId);
          }
        } else {
          // Keep existing pipelineId, just refresh stages
          _lookups.fetchSalesStages(pipelineId: _pipelineId);
        }
      }
    });
  }

  void _onPipelineSelected(int? val) {
    setState(() {
      _pipelineId = val;
      _stageId = null;
      if (val != null) {
        _lookups.fetchSalesStages(pipelineId: val);
      }
    });
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
                  _buildSectionTitle('Product Selection'),
                  Obx(() {
                    _lookups.products.length; // Ensure dependency is tracked
                    return _buildDropdown<int>('Product *', _productId, _lookups.products.toList(), _onProductSelected, displayKey: 'productName');
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Quantity *', _quantityCtrl, TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField('Sale Price', _salePriceCtrl, TextInputType.number)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('Sales Stage'),
                  Obx(() {
                    _lookups.pipelines.length; // Ensure dependency is tracked
                    _lookups.salesStages.length; // Ensure dependency is tracked
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_pipelineId != null)
                          _buildDropdown<int>(
                            'Sales Stage *',
                            _stageId,
                            _lookups.salesStages,
                            (val) => setState(() => _stageId = val),
                          )
                        else
                          const Text(
                            'Select a unit to view sales stages',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Deal Information'),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          _lookups.dealTypes.length; // Ensure dependency is tracked
                          return _buildDropdown<int>('Deal Type', _dealTypeId, _lookups.dealTypes, (val) => setState(() => _dealTypeId = val));
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _expectedCloseDate == null ? 'Closing Date *' : DateFormat('MMM dd, yyyy').format(_expectedCloseDate!),
                                    style: TextStyle(color: _expectedCloseDate == null ? AppColors.textSecondary : AppColors.textPrimary, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Related Entity'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdown<String>('Type *', _linkedEntityType, ['account', 'lead', 'contact'], (val) {
                          setState(() {
                            _linkedEntityType = val!;
                            _linkedEntityId = null;
                          });
                        }, isStringList: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildEntityDropdown(),
                      ),
                    ],
                  ),

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

  Widget _buildEntityDropdown() {
    if (_linkedEntityType == 'account') {
      if (_accountsController == null || _accountsController!.accounts.isEmpty) {
        return const Text('No Accounts Available. Please ensure Accounts are loaded.');
      }
      return Obx(() {
        _accountsController!.accounts.length; // Ensure dependency is tracked
        return _buildDropdown<int>(
          'Select Account *', 
          _linkedEntityId, 
          _accountsController!.accounts.toList(), 
          (val) => setState(() => _linkedEntityId = val), 
          displayKey: 'accountName'
        );
      });
    } else if (_linkedEntityType == 'lead') {
      if (_leadsController == null || _leadsController!.leads.isEmpty) {
        return const Text('No Leads Available. Please ensure Leads are loaded.');
      }
      return Obx(() {
        _leadsController!.leads.length; // Ensure dependency is tracked
        return _buildDropdown<int>(
          'Select Lead *', 
          _linkedEntityId, 
          _leadsController!.leads.toList(), 
          (val) => setState(() => _linkedEntityId = val), 
          displayKey: 'name'
        );
      });
    } else {
      return const Text('Contacts module not fully mounted for selection yet.');
    }
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
              Icon(Icons.monetization_on, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Add New Deal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildDropdown<T>(String label, T? value, List<dynamic> items, Function(T?) onChanged, {String displayKey = 'title', bool isStringList = false}) {
    return SearchableDropdown<T>(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
      displayKey: displayKey,
      valueKey: isStringList ? 'title' : 'id',
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
            onPressed: (_isSaving || _productId == null || _expectedCloseDate == null || _linkedEntityId == null || (_pipelineId != null && _stageId == null)) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create Deal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
