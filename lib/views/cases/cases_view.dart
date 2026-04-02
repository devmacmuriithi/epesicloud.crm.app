import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cases_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/crm_models.dart';

class CasesView extends StatelessWidget {
  const CasesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CasesController());

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCaseSheet(context, controller),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildSearchAndFilters(controller),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.cases.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (controller.cases.isEmpty) {
                  return const Center(
                    child: Text('No cases found', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchCases(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.cases.length,
                    itemBuilder: (context, index) {
                      return _buildCaseCard(context, controller.cases[index], controller);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.support_agent, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Cases',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary),
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(CasesController controller) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => controller.filterCases(value),
          decoration: InputDecoration(
            hintText: 'Search by Case #...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 4),
          Icon(icon, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, CaseModel caseModel, CasesController controller) {
    return GestureDetector(
      onTap: () => Get.toNamed('/case-details', arguments: caseModel),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${caseModel.caseNumber}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: controller.getPriorityColor(caseModel.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${caseModel.priority.toUpperCase()} PRIORITY',
                      style: TextStyle(
                        color: controller.getPriorityColor(caseModel.priority),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              caseModel.title ?? "Untitled Case",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              caseModel.description ?? "No description provided",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(caseModel.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    caseModel.status.toUpperCase(),
                    style: TextStyle(
                      color: controller.getStatusColor(caseModel.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCaseSheet(BuildContext context, CasesController controller) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Create New Case',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Linked Entity Type
                    Obx(() => _buildDropdownField(
                      'Linked Entity Type', 
                      ['Account', 'Contact', 'Lead', 'Deal'],
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedEntityType.value = val;
                          controller.selectedEntityId.value = null;
                        }
                      },
                      value: controller.selectedEntityType.value,
                    )),
                    const SizedBox(height: 16),
                    
                    // Linked Entity Reference
                    Obx(() {
                      final type = controller.selectedEntityType.value;
                      List<DropdownMenuItem<int>> items = [];
                      
                      if (type == 'Account') {
                        items = controller.accounts.map((e) => DropdownMenuItem(value: e.id, child: Text(e.accountName))).toList();
                      } else if (type == 'Contact') {
                        items = controller.contacts.map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName))).toList();
                      } else if (type == 'Lead') {
                        items = controller.leads.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.firstName} ${e.lastName}'))).toList();
                      } else if (type == 'Deal') {
                        items = controller.deals.map((e) => DropdownMenuItem(value: e.id, child: Text(e.dealName))).toList();
                      }

                      return _buildReferenceDropdownField(
                        'Linked Entity Reference', 
                        items,
                        onChanged: (val) => controller.selectedEntityId.value = val,
                        value: controller.selectedEntityId.value,
                      );
                    }),
                    const SizedBox(height: 16),

                    // Case Type
                    Obx(() => _buildReferenceDropdownField(
                      'Case Type', 
                      controller.caseTypes.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title))).toList(),
                      onChanged: (val) => controller.selectedCaseTypeId.value = val,
                      value: controller.selectedCaseTypeId.value,
                    )),
                    const SizedBox(height: 16),

                    // Priority
                    Obx(() => _buildDropdownField(
                      'Priority', 
                      ['Low', 'Medium', 'High', 'Urgent'],
                      onChanged: (val) {
                        if (val != null) controller.selectedPriority.value = val;
                      },
                      value: controller.selectedPriority.value,
                    )),
                    const SizedBox(height: 16),

                    // Title
                    _buildTextField('Title', 'Enter case summary...', 
                        controller: controller.titleController),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField('Description', 'Provide detailed information...', 
                        controller: controller.descriptionController, maxLines: 5),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () async {
                          final success = await controller.submitCase();
                          if (success) {
                            Get.back();
                            Get.snackbar('Success', 'New support case created successfully', 
                                backgroundColor: AppColors.success, colorText: Colors.white,
                                margin: const EdgeInsets.all(16), snackPosition: SnackPosition.BOTTOM);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isLoading.value 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Create Case',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, {void Function(String?)? onChanged, String? value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value ?? items.first,
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceDropdownField(String label, List<DropdownMenuItem<int>> items, {void Function(int?)? onChanged, int? value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: value,
              hint: const Text('Select reference...'),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
