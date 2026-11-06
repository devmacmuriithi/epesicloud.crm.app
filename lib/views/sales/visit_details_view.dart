import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/sales/visits_controller.dart';
import '../../models/fieldforce_models.dart';
import '../../models/crm_models.dart';
import '../../utils/app_colors.dart';

class VisitDetailsView extends StatefulWidget {
  final VisitRecord visit;
  const VisitDetailsView({super.key, required this.visit});

  @override
  State<VisitDetailsView> createState() => _VisitDetailsViewState();
}

class _VisitDetailsViewState extends State<VisitDetailsView> with SingleTickerProviderStateMixin {
  final VisitsController controller = Get.find<VisitsController>();
  static const List<int> _visibleTabIndices = [0, 5, 6, 7];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _visibleTabIndices.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    // Initial fetch to sync aggregate data and start tab listeners
    controller.fetchVisitWorkspace(widget.visit.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSheet(int index) {
    switch (index) {
      case 0:
        controller.loadProducts();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddOrderSheet(controller: controller, visitId: widget.visit.id),
        );
        break;
      case 1:
        controller.loadProducts();
        controller.loadCompetitors();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddCompetitorRateSheet(controller: controller, visitId: widget.visit.id),
        );
        break;
      case 2:
        controller.loadProducts();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddOutletRateSheet(controller: controller, visitId: widget.visit.id),
        );
        break;
      case 3:
        controller.loadProducts();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddStockAvailabilitySheet(controller: controller, visitId: widget.visit.id),
        );
        break;
      case 4:
        controller.loadProducts();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddShelfPlacementSheet(controller: controller, visitId: widget.visit.id),
        );
        break;
      case 5:
        controller.loadProducts();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddPromotionAuditSheet(controller: controller, visitId: widget.visit.id),
        );
        break;
      case 6:
        controller.loadComplaintTypes();
        controller.loadProducts();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddComplaintSheet(controller: controller, visitId: widget.visit.id),
        );
        break;
      case 7:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddPhotoSheet(controller: controller, visitId: widget.visit.id),
        );
        break;
    }
  }

  bool _isListNotEmpty(int index) {
    switch (index) {
      case 0: return controller.workspaceOrders.isNotEmpty;
      case 1: return controller.workspaceCompetitorRates.isNotEmpty;
      case 2: return controller.workspaceOutletRates.isNotEmpty;
      case 3: return controller.workspaceStockAvailability.isNotEmpty;
      case 4: return controller.workspaceShelfPlacements.isNotEmpty;
      case 5: return controller.workspacePromotionAudits.isNotEmpty;
      case 6: return controller.workspaceComplaints.isNotEmpty;
      case 7: return controller.workspacePhotos.isNotEmpty;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _visibleTabIndices.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                expandedHeight: 120,
                backgroundColor: AppColors.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => Get.back(),
                ),
                title: Obx(() {
                  final v = controller.currentVisit.value ?? widget.visit;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Visit Workspace #${v.id}',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(v.accountName,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  );
                }),
                actions: [
                  Obx(() {
                    final v = controller.currentVisit.value ?? widget.visit;
                    if (v.isCompleted) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('COMPLETED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }
                    return TextButton.icon(
                      onPressed: () => controller.showCheckoutModal(context, v),
                      icon: const Icon(Icons.logout, color: Colors.green, size: 18),
                      label: const Text('End Visit', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    );
                  }),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: [
                    Tab(text: 'Reservations'),
                    // Tab(text: 'Competitor Rates'),
                    // Tab(text: 'Outlet Rates'),
                    // Tab(text: 'Stock'),
                    // Tab(text: 'Shelves'),
                    Tab(text: 'Promotions'),
                    Tab(text: 'Complaints'),
                    Tab(text: 'Photos'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _OrdersTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(0)),
              // _CompetitorRatesTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(1)),
              // _OutletRatesTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(2)),
              // _StockAvailabilityTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(3)),
              // _ShelfPlacementsTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(4)),
              _PromotionAuditsTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(5)),
              _ComplaintsTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(6)),
              _PhotosTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(7)),
            ],
          ),
        ),
        floatingActionButton: Obx(() {
          final actualIndex = _visibleTabIndices[_tabController.index];
          final isNotEmpty = _isListNotEmpty(actualIndex);
          if (!isNotEmpty) return const SizedBox.shrink();
          
          return FloatingActionButton(
            onPressed: () => _showAddSheet(actualIndex),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          );
        }),
      ),
    );
  }
}

// ─── Orders Tab ──────────────────────────────────────────────────────────────
class _OrdersTab extends StatelessWidget {
  final VisitsController controller;
  final int visitId;
  final VoidCallback onAdd;
  const _OrdersTab({required this.controller, required this.visitId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingOrders.value && controller.workspaceOrders.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      final orders = controller.workspaceOrders;
      if (orders.isEmpty) {
        return _buildEmptyState(
          icon: Icons.shopping_cart_outlined,
          title: 'No Reservations Yet',
          subtitle: 'Create the first reservation for this visit.',
          onAdd: onAdd,
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(visitId, 0),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            final product = controller.products.firstWhereOrNull((p) => p.id == order.productId);
            
            return Card(
              color: AppColors.cardBg,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: ListTile(
                title: Text(product?.productName ?? 'Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Qty: ${order.quantity} • Unit Price: ${order.unitPrice}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(order.totalAmount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(order.status.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─── Competitor Rates Tab ────────────────────────────────────────────────────
class _CompetitorRatesTab extends StatelessWidget {
  final VisitsController controller;
  final int visitId;
  final VoidCallback onAdd;
  const _CompetitorRatesTab({required this.controller, required this.visitId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCompetitorRates.value && controller.workspaceCompetitorRates.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final rates = controller.workspaceCompetitorRates;
      if (rates.isEmpty) {
        return _buildEmptyState(
          icon: Icons.trending_up,
          title: 'No Competitor Rates',
          subtitle: 'Log competitor pricing data.',
          onAdd: onAdd,
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(visitId, 1),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rates.length,
          itemBuilder: (_, i) => _RateCard(rate: rates[i], controller: controller),
        ),
      );
    });
  }
}

// ─── Outlet Rates Tab ────────────────────────────────────────────────────────
class _OutletRatesTab extends StatelessWidget {
  final VisitsController controller;
  final int visitId;
  final VoidCallback onAdd;
  const _OutletRatesTab({required this.controller, required this.visitId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingOutletRates.value) return const Center(child: CircularProgressIndicator());
      final rates = controller.workspaceOutletRates;
      if (rates.isEmpty) return _buildEmptyState(icon: Icons.storefront, title: 'No Outlet Rates', subtitle: 'Log prices observed at this outlet.', onAdd: onAdd);
      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(visitId, 2),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rates.length,
          itemBuilder: (_, i) {
            final rate = rates[i];
            final product = controller.products.firstWhereOrNull((p) => p.id == rate.productId);
            return Card(
              color: AppColors.cardBg,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.divider)),
              child: ListTile(
                title: Text(product?.productName ?? 'Product ID: ${rate.productId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Buy: ${rate.buyingPrice} • Sell: ${rate.sellingPrice}'),
                trailing: Text(DateFormat('MMM dd').format(rate.createdAt ?? DateTime.now()), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─── Complaints Tab ──────────────────────────────────────────────────────────
class _ComplaintsTab extends StatelessWidget {
  final VisitsController controller;
  final int visitId;
  final VoidCallback onAdd;
  const _ComplaintsTab({required this.controller, required this.visitId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingComplaints.value) return const Center(child: CircularProgressIndicator());
      final complaints = controller.workspaceComplaints;
      if (complaints.isEmpty) return _buildEmptyState(icon: Icons.report_problem_outlined, title: 'No Complaints', subtitle: 'Record any issues raised by the customer.', onAdd: onAdd);
      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(visitId, 3),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: complaints.length,
          itemBuilder: (_, i) {
            final complaint = complaints[i];
            final type = controller.complaintTypes.firstWhereOrNull((t) => t.id == complaint.complaintTypeId);
            return Card(
              color: AppColors.cardBg,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.divider)),
              child: ListTile(
                title: Text(type?.title ?? 'Complaint #${complaint.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(complaint.notes ?? 'No details provided'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: (complaint.severityLevel ?? '').toLowerCase() == 'high' ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text((complaint.severityLevel ?? 'MEDIUM').toUpperCase(), style: TextStyle(color: (complaint.severityLevel ?? '').toLowerCase() == 'high' ? Colors.red : Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─── Photos Tab ──────────────────────────────────────────────────────────────
class _PhotosTab extends StatelessWidget {
  final VisitsController controller;
  final int visitId;
  final VoidCallback onAdd;
  const _PhotosTab({required this.controller, required this.visitId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPhotos.value) return const Center(child: CircularProgressIndicator());
      final photos = controller.workspacePhotos;
      if (photos.isEmpty) return _buildEmptyState(icon: Icons.camera_alt_outlined, title: 'No Photos', subtitle: 'Capture photos of shelf visibility and branding.', onAdd: onAdd);
      
      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(visitId, 4),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: photos.length,
          itemBuilder: (_, i) => GestureDetector(
            onLongPress: () {
              // Option to view full image or delete
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                   _buildImage(photos[i].photoUrl),
                  if (photos[i].caption != null)
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        color: Colors.black.withOpacity(0.5),
                        child: Text(photos[i].caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _buildEmptyState({required IconData icon, required String title, required String subtitle, required VoidCallback onAdd}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: AppColors.textSecondary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          SizedBox(
            width: 160, // Constrain width
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, 
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RateCard extends StatelessWidget {
  final CompetitorRate rate;
  final VisitsController controller;
  const _RateCard({required this.rate, required this.controller});

  @override
  Widget build(BuildContext context) {
    final competitor = controller.competitors.firstWhereOrNull((c) => c.id == rate.competitorId);
    final product = controller.products.firstWhereOrNull((p) => p.id == rate.productId);
    
    return Card(
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(competitor?.title ?? 'Competitor ID: ${rate.competitorId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                if (rate.hasOffer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('OFFER', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(product?.productName ?? 'Product ID: ${rate.productId}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                _PriceChip(label: 'Buy', value: rate.buyingPrice ?? '-'),
                const SizedBox(width: 12),
                _PriceChip(label: 'Sell', value: rate.sellingPrice ?? '-'),
                if (rate.hasOffer) ...[
                  const SizedBox(width: 12),
                  _PriceChip(label: 'Offer', value: rate.offerPrice ?? '-', isHighlight: true),
                ],
              ],
            ),
            if (rate.notes != null && rate.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8)),
                child: Text(rate.notes!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  const _PriceChip({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: isHighlight ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

// ─── Add Order Sheet ────────────────────────────────────────────────────────
class _AddOrderSheet extends StatefulWidget {
  final VisitsController controller;
  final int visitId;
  const _AddOrderSheet({required this.controller, required this.visitId});

  @override
  State<_AddOrderSheet> createState() => _AddOrderSheetState();
}

class _AddOrderSheetState extends State<_AddOrderSheet> {
  ProductModel? selectedProduct;
  final qtyController = TextEditingController(text: '1');
  final priceController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;

  @override
  void initState() {
    super.initState();
    qtyController.addListener(() => setState(() {}));
    priceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    qtyController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    final qty = double.tryParse(qtyController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;
    return qty * price;
  }

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'New Reservation',
      onSubmit: () {
        if (selectedProduct == null) return;
        final qty = double.tryParse(qtyController.text) ?? 1;
        final price = double.tryParse(priceController.text) ?? 0;
        
        if (qty <= 0) {
          Get.snackbar('Invalid Input', 'Please enter a valid quantity', backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
        if (price <= 0) {
          Get.snackbar('Invalid Input', 'Please enter a valid price', backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        Get.back();
        widget.controller.addVisitOrder(widget.visitId, {
          'productId': selectedProduct!.id,
          'quantity': qty,
          'unitPrice': price,
          'notes': notesController.text.trim(),
          if (evidenceUrl != null) 'photoUrl': evidenceUrl,
          if (evidenceUrl != null) 'photoCaption': 'Order evidence',
          if (evidenceUrl != null) 'captionType': 'Display',
        });
      },
      children: [
        _buildProductPicker(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Quantity',
                controller: qtyController,
                keyboardType: TextInputType.number,
                icon: Icons.exposure_plus_1,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Unit Price',
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                icon: Icons.attach_money,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calculated Total:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(
                'KES ${_totalAmount.toStringAsFixed(2)}', 
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Notes',
          controller: notesController,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _EvidencePicker(
          photoUrl: evidenceUrl,
          onCapture: () async {
            final res = await widget.controller.captureAndUploadPhoto(widget.visitId);
            if (res != null) setState(() => evidenceUrl = res);
          },
        ),
      ],
    );
  }

  Widget _buildProductPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Unit', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showProductSelection(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.search, color: selectedProduct == null ? AppColors.textSecondary : AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedProduct?.productName ?? 'Tap to search available units',
                    style: TextStyle(color: selectedProduct == null ? AppColors.textSecondary : AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProductSelection() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select Unit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: widget.controller.products.length,
                itemBuilder: (_, i) {
                  final p = widget.controller.products[i];
                  return ListTile(
                    title: Text(p.productName, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(p.productCode, style: const TextStyle(color: AppColors.textSecondary)),
                    onTap: () {
                      setState(() {
                        selectedProduct = p;
                        priceController.text = p.price?.toString() ?? '';
                      });
                      Get.back();
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Competitor Rate Sheet ────────────────────────────────────────────────
class _AddCompetitorRateSheet extends StatefulWidget {
  final VisitsController controller;
  final int visitId;
  const _AddCompetitorRateSheet({required this.controller, required this.visitId});

  @override
  State<_AddCompetitorRateSheet> createState() => _AddCompetitorRateSheetState();
}

class _AddCompetitorRateSheetState extends State<_AddCompetitorRateSheet> {
  ProductModel? selectedProduct;
  LookupModel? selectedCompetitor;
  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();
  final offerPriceController = TextEditingController();
  final newProductDetailsController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;
  bool hasOffer = false;
  bool hasNewProduct = false;

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Competitor Rate',
      onSubmit: () {
        if (selectedProduct == null || selectedCompetitor == null) {
          Get.snackbar('Missing Info', 'Please select unit and competitor', backgroundColor: Colors.orange);
          return;
        }
        final price = double.tryParse(sellPriceController.text) ?? 0;
        if (price <= 0) {
          Get.snackbar('Invalid Price', 'Please enter a valid selling price', backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        Get.back();
        widget.controller.addCompetitorRate(widget.visitId, {
          'productId': selectedProduct!.id,
          'competitorId': selectedCompetitor!.id,
          'buyingPrice': double.tryParse(buyPriceController.text) ?? 0,
          'sellingPrice': price,
          'hasOffer': hasOffer,
          'offerPrice': hasOffer ? (double.tryParse(offerPriceController.text) ?? 0) : null,
          'hasNewProduct': hasNewProduct,
          'newProductDetails': hasNewProduct ? newProductDetailsController.text.trim() : null,
          'notes': notesController.text.trim(),
          if (evidenceUrl != null) 'photoUrl': evidenceUrl,
          if (evidenceUrl != null) 'photoCaption': 'Competitor tag',
          if (evidenceUrl != null) 'captionType': 'Display',
        });
      },
      children: [
        _buildProductPicker(),
        const SizedBox(height: 16),
        _buildCompetitorPicker(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Buying Price',
                controller: buyPriceController,
                keyboardType: TextInputType.number,
                icon: Icons.price_change_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                label: 'Selling Price',
                controller: sellPriceController,
                keyboardType: TextInputType.number,
                icon: Icons.price_change_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Offer?', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                Switch(
                  value: hasOffer,
                  onChanged: (v) => setState(() => hasOffer = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Product?', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                Switch(
                  value: hasNewProduct,
                  onChanged: (v) => setState(() => hasNewProduct = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
        if (hasOffer) ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Offer Price',
            controller: offerPriceController,
            keyboardType: TextInputType.number,
            icon: Icons.local_offer_outlined,
          ),
        ],
        if (hasNewProduct) ...[
          const SizedBox(height: 16),
          _buildTextField(label: 'New Product Details', controller: newProductDetailsController, maxLines: 2),
        ],
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),
        const SizedBox(height: 16),
        _EvidencePicker(
          photoUrl: evidenceUrl,
          onCapture: () async {
            final res = await widget.controller.captureAndUploadPhoto(widget.visitId);
            if (res != null) setState(() => evidenceUrl = res);
          },
        ),
      ],
    );
  }

  Widget _buildProductPicker() {
    return _SelectionBox(
      label: 'Our Product',
      value: selectedProduct?.productName ?? 'Select unit...',
      onTap: () => _showPicker('Select Unit', widget.controller.products, (p) {
        setState(() {
          selectedProduct = p as ProductModel;
          sellPriceController.text = selectedProduct!.price?.toString() ?? '';
        });
      }),
    );
  }

  Widget _buildCompetitorPicker() {
    return _SelectionBox(
      label: 'Competitor',
      value: selectedCompetitor?.title ?? 'Select competitor...',
      onTap: () => _showPicker('Select Competitor', widget.controller.competitors, (c) {
        setState(() => selectedCompetitor = c as LookupModel);
      }),
    );
  }

  void _showPicker(String title, List items, Function(dynamic) onSelect) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  String name = item is ProductModel ? item.productName : (item as LookupModel).title;
                  return ListTile(
                    title: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
                    onTap: () { onSelect(item); Get.back(); },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Outlet Rate Sheet ───────────────────────────────────────────────────
class _AddOutletRateSheet extends StatefulWidget {
  final VisitsController controller;
  final int visitId;
  const _AddOutletRateSheet({required this.controller, required this.visitId});

  @override
  State<_AddOutletRateSheet> createState() => _AddOutletRateSheetState();
}

class _AddOutletRateSheetState extends State<_AddOutletRateSheet> {
  ProductModel? selectedProduct;
  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();
  final offerPriceController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;
  bool hasOffer = false;

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Outlet Rate (Shelf Price)',
      onSubmit: () {
        if (selectedProduct == null) return;
        final buyPrice = double.tryParse(buyPriceController.text) ?? 0;
        final sellPrice = double.tryParse(sellPriceController.text) ?? 0;

        if (sellPrice <= 0) {
          Get.snackbar('Invalid Price', 'Please enter a valid selling price', backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        Get.back();
        widget.controller.addOutletRate(widget.visitId, {
          'productId': selectedProduct!.id,
          'buyingPrice': buyPrice > 0 ? buyPrice : null,
          'sellingPrice': sellPrice,
          'hasOffer': hasOffer,
          'offerPrice': hasOffer ? (double.tryParse(offerPriceController.text) ?? 0) : null,
          'notes': notesController.text.trim(),
          if (evidenceUrl != null) 'photoUrl': evidenceUrl,
          if (evidenceUrl != null) 'photoCaption': 'Offer sticker',
          if (evidenceUrl != null) 'captionType': 'Display',
        });
      },
      children: [
        _SelectionBox(
          label: 'Product',
          value: selectedProduct?.productName ?? 'Select unit...',
          onTap: () => _showProductPicker(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Retailer Buy Price', controller: buyPriceController, keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Retailer Sell Price', controller: sellPriceController, keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),
        const SizedBox(height: 16),
        _EvidencePicker(
          photoUrl: evidenceUrl,
          onCapture: () async {
            final res = await widget.controller.captureAndUploadPhoto(widget.visitId);
            if (res != null) setState(() => evidenceUrl = res);
          },
        ),
      ],
    );
  }

  void _showProductPicker() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: ListView.builder(
          itemCount: widget.controller.products.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(widget.controller.products[i].productName),
            onTap: () { 
              setState(() {
                selectedProduct = widget.controller.products[i];
                sellPriceController.text = selectedProduct!.price?.toString() ?? '';
              }); 
              Get.back(); 
            },
          ),
        ),
      ),
    );
  }
}

// ─── Add Complaint Sheet ─────────────────────────────────────────────────────
class _AddComplaintSheet extends StatefulWidget {
  final VisitsController controller;
  final int visitId;
  const _AddComplaintSheet({required this.controller, required this.visitId});

  @override
  State<_AddComplaintSheet> createState() => _AddComplaintSheetState();
}

class _AddComplaintSheetState extends State<_AddComplaintSheet> {
  LookupModel? selectedType;
  ProductModel? selectedProduct;
  String severity = 'MEDIUM';
  final notesController = TextEditingController();
  String? evidenceUrl;

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Report Complaint',
      onSubmit: () {
        if (selectedType == null) return;
        Get.back();
        widget.controller.addComplaint(widget.visitId, {
          'complaintTypeId': selectedType!.id,
          'productId': selectedProduct?.id,
          'severityLevel': severity.toLowerCase(),
          'notes': notesController.text.trim(),
          if (evidenceUrl != null) 'photoUrl': evidenceUrl,
          if (evidenceUrl != null) 'photoCaption': 'Damaged packs',
          if (evidenceUrl != null) 'captionType': 'Shelves',
        });
      },
      children: [
        _SelectionBox(
          label: 'Complaint Category',
          value: selectedType?.title ?? 'Select category...',
          onTap: () => _showTypePicker(),
        ),
        const SizedBox(height: 16),
        _SelectionBox(
          label: 'Related Product (Optional)',
          value: selectedProduct?.productName ?? 'None',
          onTap: () => _showProductPicker(),
        ),
        const SizedBox(height: 16),
        _buildSeveritySelector(),
        const SizedBox(height: 16),
        _buildTextField(label: 'Complaint Details', controller: notesController, maxLines: 4),
        const SizedBox(height: 16),
        _EvidencePicker(
          photoUrl: evidenceUrl,
          onCapture: () async {
            final res = await widget.controller.captureAndUploadPhoto(widget.visitId);
            if (res != null) setState(() => evidenceUrl = res);
          },
        ),
      ],
    );
  }

  Widget _buildSeveritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Severity Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['LOW', 'MEDIUM', 'HIGH'].map((s) {
            final isSelected = severity == s;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => severity = s),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _getSeverityColor(s).withOpacity(0.1) : AppColors.inputBg,
                    border: Border.all(color: isSelected ? _getSeverityColor(s) : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(s, style: TextStyle(color: isSelected ? _getSeverityColor(s) : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getSeverityColor(String s) {
    if (s == 'LOW') return Colors.blue;
    if (s == 'MEDIUM') return Colors.orange;
    return Colors.red;
  }

  void _showTypePicker() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Obx(() => ListView.builder(
          itemCount: widget.controller.complaintTypes.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(widget.controller.complaintTypes[i].title),
            onTap: () { setState(() => selectedType = widget.controller.complaintTypes[i]); Get.back(); },
          ),
        )),
      ),
    );
  }

  void _showProductPicker() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: ListView.builder(
          itemCount: widget.controller.products.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(widget.controller.products[i].productName),
            onTap: () { setState(() => selectedProduct = widget.controller.products[i]); Get.back(); },
          ),
        ),
      ),
    );
  }
}

// ─── Add Photo Sheet ────────────────────────────────────────────────────────
class _AddPhotoSheet extends StatefulWidget {
  final VisitsController controller;
  final int visitId;
  const _AddPhotoSheet({required this.controller, required this.visitId});

  @override
  State<_AddPhotoSheet> createState() => _AddPhotoSheetState();
}

class _AddPhotoSheetState extends State<_AddPhotoSheet> {
  String? photoUrl; // In real app, this would be a local path or uploaded URL
  final captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Visit Photo',
      onSubmit: () {
        if (photoUrl == null) return;
        Get.back();
        widget.controller.addVisitPhoto(widget.visitId, photoUrl!, captionController.text.trim());
      },
      children: [
        GestureDetector(
          onTap: () async {
            final result = await widget.controller.captureAndUploadPhoto(widget.visitId);
            if (result != null) {
              setState(() => photoUrl = result);
            }
          },
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
            child: photoUrl == null 
              ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_enhance, size: 48, color: AppColors.textSecondary), Text('Tap to capture photo', style: TextStyle(color: AppColors.textSecondary))])
              : ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildImage(photoUrl!)),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Caption', controller: captionController, hint: 'Describe the photo...'),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _buildImage(String path) {
  if (path.startsWith('data:image')) {
    try {
      final base64String = path.split(',').last;
      return Image.memory(base64Decode(base64String), fit: BoxFit.cover, 
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.red));
    } catch (e) {
      return const Icon(Icons.broken_image, color: Colors.red);
    }
  }
  return Image.network(path, fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: AppColors.textSecondary));
}

class _BaseBottomSheet extends StatelessWidget {
  final String title;
  final VoidCallback onSubmit;
  final List<Widget> children;

  const _BaseBottomSheet({required this.title, required this.onSubmit, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary), onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Column(children: children))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Submit to Workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _SelectionBox({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [const Icon(Icons.list_alt, color: AppColors.primary, size: 20), const SizedBox(width: 12), Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary)))]),
          ),
        ),
      ],
    );
  }
}

Widget _buildTextField({required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, IconData? icon, int maxLines = 1, String? hint}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
          filled: true,
          fillColor: AppColors.inputBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    ],
  );
}

class _EvidencePicker extends StatelessWidget {
  final String? photoUrl;
  final VoidCallback onCapture;
  const _EvidencePicker({required this.photoUrl, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Evidence (Optional)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onCapture,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
            child: photoUrl == null 
              ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_enhance, color: AppColors.textSecondary), SizedBox(height: 4), Text('Tap to attach photo', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))])
              : ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildImage(photoUrl!)),
          ),
        ),
      ],
    );
  }
}


// ─── Stock Availability Tab & Sheet ──────────────────────────────────────────────────────────
class _StockAvailabilityTab extends StatelessWidget {
  final VisitsController controller;
  final int visitId;
  final VoidCallback onAdd;
  const _StockAvailabilityTab({required this.controller, required this.visitId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingStockAvailability.value && controller.workspaceStockAvailability.isEmpty) return const Center(child: CircularProgressIndicator());
      
      final items = controller.workspaceStockAvailability;
      if (items.isEmpty) return _buildEmptyState(icon: Icons.inventory_2_outlined, title: 'No Stock Availability', subtitle: 'Start auditing stock availability.', onAdd: onAdd);

      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(visitId, 5),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final product = controller.products.firstWhereOrNull((p) => p.id == item.productId);
            
            return Card(
              color: AppColors.cardBg,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.divider)),
              child: ListTile(
                title: Text(product?.productName ?? 'Product #${item.productId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Available: ${item.unitsAvailableCount} • Damaged: ${item.damagedCount}\nNotes: ${item.notes ?? "-"}'),
              ),
            );
          },
        ),
      );
    });
  }
}

class _AddStockAvailabilitySheet extends StatefulWidget {
  final VisitsController controller;
  final int visitId;
  const _AddStockAvailabilitySheet({required this.controller, required this.visitId});

  @override
  State<_AddStockAvailabilitySheet> createState() => _AddStockAvailabilitySheetState();
}

class _AddStockAvailabilitySheetState extends State<_AddStockAvailabilitySheet> {
  ProductModel? selectedProduct;
  final availableController = TextEditingController();
  final damagedController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;

  void _showPicker(String title, List items, Function(dynamic) onSelect) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  String name = item is ProductModel ? item.productName : (item as LookupModel).title;
                  return ListTile(
                    title: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
                    onTap: () { onSelect(item); Get.back(); },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Stock Availability',
      onSubmit: () {
        if (selectedProduct == null) {
          Get.snackbar('Missing Info', 'Please select a unit', backgroundColor: Colors.orange);
          return;
        }
        Get.back();
        widget.controller.addStockAvailability(widget.visitId, {
          'productId': selectedProduct!.id,
          'unitsAvailableCount': double.tryParse(availableController.text) ?? 0,
          'damagedCount': double.tryParse(damagedController.text) ?? 0,
          'notes': notesController.text.trim(),
          if (evidenceUrl != null) 'photoUrl': evidenceUrl,
          if (evidenceUrl != null) 'photoCaption': 'Stock Evidence',
          if (evidenceUrl != null) 'captionType': 'Shelves',
        });
      },
      children: [
        _SelectionBox(
          label: 'Product',
          value: selectedProduct?.productName ?? 'Select unit...',
          onTap: () => _showPicker('Select Unit', widget.controller.products, (p) => setState(() => selectedProduct = p as ProductModel)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Units Available', controller: availableController, keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Damaged Count', controller: damagedController, keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),
        const SizedBox(height: 16),
        _EvidencePicker(
          photoUrl: evidenceUrl,
          onCapture: () async {
            final res = await widget.controller.captureAndUploadPhoto(widget.visitId);
            if (res != null) setState(() => evidenceUrl = res);
          },
        ),
      ],
    );
  }
}

// ─── Shelf Placements Tab & Sheet ────────────────────────────────────────────────────────
class _ShelfPlacementsTab extends StatelessWidget {
  final VisitsController controller;
  final int visitId;
  final VoidCallback onAdd;
  const _ShelfPlacementsTab({required this.controller, required this.visitId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingShelfPlacements.value && controller.workspaceShelfPlacements.isEmpty) return const Center(child: CircularProgressIndicator());
      
      final items = controller.workspaceShelfPlacements;
      if (items.isEmpty) return _buildEmptyState(icon: Icons.shelves, title: 'No Shelf Placements', subtitle: 'Audit shelf placements.', onAdd: onAdd);

      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(visitId, 6),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final product = controller.products.firstWhereOrNull((p) => p.id == item.productId);
            
            return Card(
              color: AppColors.cardBg,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.divider)),
              child: ListTile(
                title: Text(product?.productName ?? 'Product #${item.productId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Planogram: ${item.isPlanogramCompliant == true ? "Yes" : "No"} • Facings: ${item.facingsCount}\nNotes: ${item.notes ?? "-"}'),
              ),
            );
          },
        ),
      );
    });
  }
}

class _AddShelfPlacementSheet extends StatefulWidget {
  final VisitsController controller;
  final int visitId;
  const _AddShelfPlacementSheet({required this.controller, required this.visitId});

  @override
  State<_AddShelfPlacementSheet> createState() => _AddShelfPlacementSheetState();
}

class _AddShelfPlacementSheetState extends State<_AddShelfPlacementSheet> {
  ProductModel? selectedProduct;
  bool isPlanogramCompliant = false;
  bool isEyeLevel = false;
  bool hasPrimeShelfSpace = false;
  final facingsController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;

  void _showPicker(String title, List items, Function(dynamic) onSelect) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  String name = item is ProductModel ? item.productName : (item as LookupModel).title;
                  return ListTile(
                    title: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
                    onTap: () { onSelect(item); Get.back(); },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Shelf Placement',
      onSubmit: () {
        if (selectedProduct == null) {
          Get.snackbar('Missing Info', 'Please select a unit', backgroundColor: Colors.orange);
          return;
        }
        Get.back();
        widget.controller.addShelfPlacement(widget.visitId, {
          'productId': selectedProduct!.id,
          'isPlanogramCompliant': isPlanogramCompliant,
          'isEyeLevel': isEyeLevel,
          'hasPrimeShelfSpace': hasPrimeShelfSpace,
          'facingsCount': double.tryParse(facingsController.text) ?? 0,
          'notes': notesController.text.trim(),
          if (evidenceUrl != null) 'photoUrl': evidenceUrl,
          if (evidenceUrl != null) 'photoCaption': 'Shelf placement',
          if (evidenceUrl != null) 'captionType': 'Shelves',
        });
      },
      children: [
        _SelectionBox(
          label: 'Product',
          value: selectedProduct?.productName ?? 'Select unit...',
          onTap: () => _showPicker('Select Unit', widget.controller.products, (p) => setState(() => selectedProduct = p as ProductModel)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Planogram Compliant?'), Switch(value: isPlanogramCompliant, onChanged: (v) => setState(() => isPlanogramCompliant = v), activeColor: AppColors.primary)],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Is Eye Level?'), Switch(value: isEyeLevel, onChanged: (v) => setState(() => isEyeLevel = v), activeColor: AppColors.primary)],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Has Prime Space?'), Switch(value: hasPrimeShelfSpace, onChanged: (v) => setState(() => hasPrimeShelfSpace = v), activeColor: AppColors.primary)],
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Facings Count', controller: facingsController, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),
        const SizedBox(height: 16),
        _EvidencePicker(
          photoUrl: evidenceUrl,
          onCapture: () async {
            final res = await widget.controller.captureAndUploadPhoto(widget.visitId);
            if (res != null) setState(() => evidenceUrl = res);
          },
        ),
      ],
    );
  }
}

// ─── Promotion Audits Tab & Sheet ──────────────────────────────────────────────────
class _PromotionAuditsTab extends StatelessWidget {
  final VisitsController controller;
  final int visitId;
  final VoidCallback onAdd;
  const _PromotionAuditsTab({required this.controller, required this.visitId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPromotionAudits.value && controller.workspacePromotionAudits.isEmpty) return const Center(child: CircularProgressIndicator());
      
      final items = controller.workspacePromotionAudits;
      if (items.isEmpty) return _buildEmptyState(icon: Icons.campaign_outlined, title: 'No Promotion Audits', subtitle: 'Start auditing active promotions.', onAdd: onAdd);

      return RefreshIndicator(
        onRefresh: () => controller.refreshTab(visitId, 7),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final product = controller.products.firstWhereOrNull((p) => p.id == item.productId);
            
            return Card(
              color: AppColors.cardBg,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.divider)),
              child: ListTile(
                title: Text(product?.productName ?? 'Product #${item.productId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Installed: ${item.promotionalMaterialsInstalled == true ? "Yes" : "No"} • Active/Visible: ${item.promotionActiveVisible == true ? "Yes" : "No"}\nNotes: ${item.notes ?? "-"}'),
              ),
            );
          },
        ),
      );
    });
  }
}

class _AddPromotionAuditSheet extends StatefulWidget {
  final VisitsController controller;
  final int visitId;
  const _AddPromotionAuditSheet({required this.controller, required this.visitId});

  @override
  State<_AddPromotionAuditSheet> createState() => _AddPromotionAuditSheetState();
}

class _AddPromotionAuditSheetState extends State<_AddPromotionAuditSheet> {
  ProductModel? selectedProduct;
  bool materialsInstalled = false;
  bool activeVisible = false;
  String displayStatus = 'no';
  final notesController = TextEditingController();
  String? evidenceUrl;

  void _showPicker(String title, List items, Function(dynamic) onSelect) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  String name = item is ProductModel ? item.productName : (item as LookupModel).title;
                  return ListTile(
                    title: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
                    onTap: () { onSelect(item); Get.back(); },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Promotion Audit',
      onSubmit: () {
        if (selectedProduct == null) {
          Get.snackbar('Missing Info', 'Please select a unit', backgroundColor: Colors.orange);
          return;
        }
        Get.back();
        widget.controller.addPromotionAudit(widget.visitId, {
          'productId': selectedProduct!.id,
          'promotionalMaterialsInstalled': materialsInstalled,
          'displaySetupStatus': displayStatus,
          'promotionActiveVisible': activeVisible,
          'notes': notesController.text.trim(),
          if (evidenceUrl != null) 'photoUrl': evidenceUrl,
          if (evidenceUrl != null) 'photoCaption': 'Promotion audit evidence',
          if (evidenceUrl != null) 'captionType': 'Promotions',
        });
      },
      children: [
        _SelectionBox(
          label: 'Product',
          value: selectedProduct?.productName ?? 'Select unit...',
          onTap: () => _showPicker('Select Unit', widget.controller.products, (p) => setState(() => selectedProduct = p as ProductModel)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Materials Installed?'), Switch(value: materialsInstalled, onChanged: (v) => setState(() => materialsInstalled = v), activeColor: AppColors.primary)],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Active & Visible?'), Switch(value: activeVisible, onChanged: (v) => setState(() => activeVisible = v), activeColor: AppColors.primary)],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: displayStatus,
          decoration: InputDecoration(
            labelText: 'Display Setup Status',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
          ),
          items: const [
            DropdownMenuItem(value: 'no', child: Text('No')),
            DropdownMenuItem(value: 'stands_correctly', child: Text('Stands Correctly')),
            DropdownMenuItem(value: 'end_caps_correctly', child: Text('End Caps Correctly')),
            DropdownMenuItem(value: 'both_correctly', child: Text('Both Correctly')),
          ],
          onChanged: (v) => setState(() => displayStatus = v!),
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),
        const SizedBox(height: 16),
        _EvidencePicker(
          photoUrl: evidenceUrl,
          onCapture: () async {
            final res = await widget.controller.captureAndUploadPhoto(widget.visitId);
            if (res != null) setState(() => evidenceUrl = res);
          },
        ),
      ],
    );
  }
}
