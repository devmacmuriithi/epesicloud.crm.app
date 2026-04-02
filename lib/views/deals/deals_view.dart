// Updated: 2026-03-30 13:34
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/deals_controller.dart';
import '../../utils/app_colors.dart';

import '../../models/crm_models.dart';
import 'modals/add_deal_modal.dart';

import '../../Services/lookups_service.dart';

class DealsView extends StatefulWidget {
  final bool isEmbedded;
  const DealsView({super.key, this.isEmbedded = false});

  @override
  State<DealsView> createState() => _DealsViewState();
}

class _DealsViewState extends State<DealsView> {
  late final DealsController controller;
  final LookupsService lookupsService = Get.find<LookupsService>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(DealsController());
    
    // Check for openModal argument after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is Map && args.containsKey('openModal') && args['openModal'] == true) {
        _showAddDealModal();
      }
    });
  }

  void _showAddDealModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddDealModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _showAddDealModal,
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.isEmbedded) _buildAppBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildSearchAndFilters(controller),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.deals.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (controller.deals.isEmpty) {
                  return const Center(
                    child: Text('No deals found', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchDeals(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.deals.length,
                    itemBuilder: (context, index) {
                      return _buildDealCard(controller.deals[index], controller);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'Track your sales progress',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: IconButton(
              icon: const Icon(Icons.show_chart, color: AppColors.primary),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(DealsController controller) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => controller.filterDeals(value),
          decoration: InputDecoration(
            hintText: 'Search deals...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final isAllSelected = controller.selectedType.value.id == -1;
          
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    'All Deals',
                    isSelected: isAllSelected,
                    onTap: () => controller.resetFilters(),
                  ),
                ),
                ...lookupsService.dealTypes.map((type) {
                  final isSelected = controller.selectedType.value.id == type.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      type.title,
                      isSelected: isSelected,
                      onTap: () => controller.setDealType(type),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDealCard(DealModel deal, DealsController controller) {
    Color stageColor = AppColors.primary;
    final stageLower = (deal.stage ?? '').toLowerCase();
    if (stageLower.contains('negotiation')) {
      stageColor = const Color(0xFF60A5FA);
    } else if (stageLower.contains('proposal')) {
      stageColor = const Color(0xFFF59E0B);
    } else if (stageLower.contains('qualified') || stageLower.contains('qualification')) {
      stageColor = const Color(0xFF10B981);
    } else if (stageLower.contains('contract')) {
      stageColor = const Color(0xFFA78BFA);
    }

    return GestureDetector(
      onTap: () => controller.openDealDetails(deal),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stageColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (deal.stage ?? '').toUpperCase(),
                    style: TextStyle(color: stageColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ),
                Text(
                  controller.formatValue(deal.amount),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deal.dealName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Closing: ${deal.closingDate}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
