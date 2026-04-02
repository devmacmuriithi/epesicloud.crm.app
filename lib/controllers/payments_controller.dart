import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/crm_models.dart';
import '../Services/crm_service.dart';
import '../utils/app_colors.dart';

class PaymentsController extends GetxController with GetSingleTickerProviderStateMixin {
  final CrmService _crmService = Get.find<CrmService>();
  late TabController tabController;
  
  var payments = <PaymentModel>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Lookups
  var accounts = <LookupModel>[].obs;
  var allDeals = <DealModel>[].obs;
  var filteredDeals = <DealModel>[].obs;
  var paymentMethods = <LookupModel>[].obs;

  // Form Fields
  final amountController = TextEditingController();
  final referenceController = TextEditingController();
  final notesController = TextEditingController();
  var paymentDate = DateTime.now().obs;
  var selectedMethodId = RxnInt();
  var selectedAccountId = RxnInt();
  var selectedDealId = RxnInt();
  var status = 'pending'.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchPayments();
    fetchLookups();
    
    // Watch for account changes to filter deals
    ever(selectedAccountId, (_) => _filterDealsByAccount());
  }

  @override
  void onClose() {
    tabController.dispose();
    amountController.dispose();
    referenceController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> fetchPayments() async {
    isLoading.value = true;
    try {
      final fetchedPayments = await _crmService.getPayments();
      payments.assignAll(fetchedPayments);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch payments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLookups() async {
    try {
      final accs = await _crmService.getAccounts();
      accounts.assignAll(accs.map((a) => LookupModel(id: a.id, title: a.accountName)).toList());
      
      allDeals.assignAll(await _crmService.getDeals());
      
      paymentMethods.assignAll(await _crmService.getPaymentMethods());
    } catch (e) {
      print('Error fetching lookups for payments: $e');
    }
  }

  void _filterDealsByAccount() {
    selectedDealId.value = null; // Reset deal when account changes
    if (selectedAccountId.value == null) {
      filteredDeals.clear();
    } else {
      filteredDeals.assignAll(
        allDeals.where((d) => d.accountId == selectedAccountId.value).toList(),
      );
    }
  }

  Future<bool> submitPayment() async {
    if (amountController.text.isEmpty || selectedMethodId.value == null || selectedAccountId.value == null) {
      Get.snackbar('Validation', 'Please fill in required fields (Amount, Method, Account)', 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }

    isSaving.value = true;
    try {
      final payload = {
        'amount': double.tryParse(amountController.text) ?? 0.0,
        'paymentDate': paymentDate.value.toIso8601String(),
        'paymentMethodId': selectedMethodId.value,
        'accountId': selectedAccountId.value,
        'dealId': selectedDealId.value,
        'reference': referenceController.text,
        'description': notesController.text,
        'status': status.value,
      };

      await _crmService.createPayment(payload);
      Get.snackbar('Success', 'Payment recorded successfully', 
          backgroundColor: AppColors.success, colorText: Colors.white);
      
      resetForm();
      fetchPayments();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to record payment: $e', 
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void resetForm() {
    amountController.clear();
    referenceController.clear();
    notesController.clear();
    paymentDate.value = DateTime.now();
    selectedMethodId.value = null;
    selectedAccountId.value = null;
    selectedDealId.value = null;
    status.value = 'pending';
  }

  String formatAmount(double amount) {
    return NumberFormat.currency(symbol: 'Kes ', decimalDigits: 2).format(amount);
  }

  void filterPayments(String query) {
    if (query.isEmpty) {
      fetchPayments();
      return;
    }
    final filtered = payments.where((p) => 
      p.receiptNumber.toLowerCase().contains(query.toLowerCase())
    ).toList();
    payments.assignAll(filtered);
  }
}
