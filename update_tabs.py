import re

path = 'lib/views/sales/visit_details_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Outlet Rate Sheet
text = text.replace('''  final sellPriceController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;''', '''  final sellPriceController = TextEditingController();
  final offerPriceController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;
  bool hasOffer = false;''')

text = text.replace('''          'sellingPrice': sellPrice,
          'notes': notesController.text.trim(),''', '''          'sellingPrice': sellPrice,
          'hasOffer': hasOffer,
          'offerPrice': hasOffer ? (double.tryParse(offerPriceController.text) ?? 0) : null,
          'notes': notesController.text.trim(),''')

text = text.replace('''        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Retailer Buy Price',
                controller: buyPriceController,
                keyboardType: TextInputType.number,
                icon: Icons.price_change_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Retailer Sell Price',
                controller: sellPriceController,
                keyboardType: TextInputType.number,
                icon: Icons.price_change_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),''', '''        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Retailer Buy Price',
                controller: buyPriceController,
                keyboardType: TextInputType.number,
                icon: Icons.price_change_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                label: 'Retailer Sell Price',
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
                const Text('Has Offer?', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                Switch(
                  value: hasOffer,
                  onChanged: (v) => setState(() => hasOffer = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            if (hasOffer) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Offer Price',
                  controller: offerPriceController,
                  keyboardType: TextInputType.number,
                  icon: Icons.local_offer_outlined,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),''')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

with open(path, 'a', encoding='utf-8') as f:
    f.write('''

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
                subtitle: Text('Available: ${item.unitsAvailableCount} • Damaged: ${item.damagedCount}\\nNotes: ${item.notes ?? "-"}'),
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

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Stock Availability',
      onSubmit: () {
        if (selectedProduct == null) {
          Get.snackbar('Missing Info', 'Please select a unit', backgroundColor: Colors.orange);
          return;
        }
        widget.controller.addStockAvailability(widget.visitId, {
          'productId': selectedProduct!.id,
          'unitsAvailableCount': double.tryParse(availableController.text) ?? 0,
          'damagedCount': double.tryParse(damagedController.text) ?? 0,
          'notes': notesController.text.trim(),
          if (evidenceUrl != null) 'photoUrl': evidenceUrl,
          if (evidenceUrl != null) 'photoCaption': 'Stock Evidence',
          if (evidenceUrl != null) 'captionType': 'Shelves',
        });
        Get.back();
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
                subtitle: Text('Planogram: ${item.isPlanogramCompliant ? "Yes" : "No"} • Facings: ${item.facingsCount}\\nNotes: ${item.notes ?? "-"}'),
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

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Shelf Placement',
      onSubmit: () {
        if (selectedProduct == null) {
          Get.snackbar('Missing Info', 'Please select a unit', backgroundColor: Colors.orange);
          return;
        }
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
        Get.back();
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
                subtitle: Text('Installed: ${item.promotionalMaterialsInstalled ? "Yes" : "No"} • Active/Visible: ${item.promotionActiveVisible ? "Yes" : "No"}\\nNotes: ${item.notes ?? "-"}'),
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

  @override
  Widget build(BuildContext context) {
    return _BaseBottomSheet(
      title: 'Promotion Audit',
      onSubmit: () {
        if (selectedProduct == null) {
          Get.snackbar('Missing Info', 'Please select a unit', backgroundColor: Colors.orange);
          return;
        }
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
        Get.back();
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
''')
