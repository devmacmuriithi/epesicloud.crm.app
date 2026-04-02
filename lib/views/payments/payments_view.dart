import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/payments_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/crm_models.dart';
import 'payment_details_view.dart';

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentsController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Payments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: controller.tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            dividerColor: AppColors.divider,
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            tabs: const [
              Tab(text: 'History'),
              Tab(text: 'Log Payment'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildHistoryTab(context, controller),
                _buildLogPaymentTab(controller, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, PaymentsController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.payments.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.payments.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Text('No payments found', style: TextStyle(color: AppColors.textSecondary)),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchPayments(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.payments.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.divider, height: 1),
                itemBuilder: (context, index) {
                  return _buildTransactionItem(controller.payments[index], controller);
                },
              ),
              const SizedBox(height: 32),
              _buildQuickLogCard(context, controller),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTransactionItem(PaymentModel payment, PaymentsController controller) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const PaymentDetailsView(), arguments: {
          'receiptNumber': payment.receiptNumber,
          'dateString': payment.paymentDate,
          'value': controller.formatAmount(payment.amount),
          'status': 'PAID', // Backend currently returns paid/reconciled items mostly
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payments, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.receiptNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payment.paymentDate,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.formatAmount(payment.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PAID',
                    style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLogPaymentTab(PaymentsController controller, BuildContext context) {
    return _buildPaymentForm(controller, context, isTab: true);
  }

  void _showRecordPaymentSheet(BuildContext context, PaymentsController controller) {
    controller.resetForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () => Get.back(),
            ),
            title: const Text('Record Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildPaymentForm(controller, context),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(PaymentsController controller, BuildContext context, {bool isTab = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isTab) ...[
          const Text('Record New Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Fill in the details to record a new payment.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
        ],
        
        // 1. Amount (Full Width)
        _buildSectionTitle('Amount *'),
        _buildTextField('0.00', controller.amountController, keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
        const SizedBox(height: 20),

        // 2. Payment Date | Payment Method
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Payment Date *'),
                  Obx(() => GestureDetector(
                    onTap: () => _pickDate(context, controller),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MM/dd/yyyy').format(controller.paymentDate.value),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Payment Method *'),
                  Obx(() => _buildDropdown<int>(
                    'Select method',
                    controller.selectedMethodId.value,
                    controller.paymentMethods,
                    (val) => controller.selectedMethodId.value = val,
                  )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3. Account (First) | Related Deal (Filtered)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Account *'),
                  Obx(() => _buildDropdown<int>(
                    'Select account',
                    controller.selectedAccountId.value,
                    controller.accounts,
                    (val) => controller.selectedAccountId.value = val,
                  )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Related Deal'),
                  Obx(() => _buildDropdown<int>(
                    controller.selectedAccountId.value == null ? 'Select account first' : 'Select deal',
                    controller.selectedDealId.value,
                    controller.filteredDeals.map((d) => LookupModel(id: d.id, title: d.dealName)).toList(),
                    (val) => controller.selectedDealId.value = val,
                    enabled: controller.selectedAccountId.value != null,
                  )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 4. Reference Number | Status
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Reference Number'),
                  _buildTextField('e.g. INV-001', controller.referenceController, prefixIcon: Icons.receipt_long),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Status'),
                  Obx(() => _buildDropdown<String>(
                    'Select status',
                    controller.status.value,
                    [
                      LookupModel(id: 0, title: 'pending'),
                      LookupModel(id: 1, title: 'completed'),
                      LookupModel(id: 2, title: 'reconciled'),
                      LookupModel(id: 3, title: 'cancelled'),
                    ],
                    (val) => controller.status.value = val ?? 'pending',
                    isStringValue: true,
                  )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 5. Notes (Full Width)
        _buildSectionTitle('Notes'),
        _buildTextField('Enter payment notes...', controller.notesController, maxLines: 3),
        
        const SizedBox(height: 40),
        
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isSaving.value ? null : () async {
              final success = await controller.submitPayment();
              if (success) {
                if (!isTab) Get.back();
                controller.tabController.animateTo(0);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: controller.isSaving.value 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Record Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        )),
        if (!isTab) const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }

  void _pickDate(BuildContext context, PaymentsController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.paymentDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.paymentDate.value = picked;
    }
  }

  Widget _buildDropdown<T>(String hint, T? value, List<dynamic> items, Function(T?) onChanged, {bool enabled = true, bool isStringValue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          onChanged: enabled ? onChanged : null,
          items: items.map((item) {
            final val = isStringValue ? item.title : item.id;
            return DropdownMenuItem<T>(
              value: val as T,
              child: Text(item.title, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController textController, {TextInputType? keyboardType, int maxLines = 1, IconData? prefixIcon}) {
    return TextField(
      controller: textController,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary) : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
    );
  }

  Widget _buildQuickLogCard(BuildContext context, PaymentsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Log',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Need to record a new payment received today? Use the Log Payment tab for full details.',
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRecordPaymentSheet(context, controller),
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text('New Payment Entry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
