import re

path = 'lib/views/sales/visit_details_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update length from 5 to 8
text = text.replace('DefaultTabController(\n      length: 5,', 'DefaultTabController(\n      length: 8,')

# 2. Update Tabs
old_tabs = '''                  tabs: [
                    Tab(text: 'Orders'),
                    Tab(text: 'Competitor Rates'),
                    Tab(text: 'Outlet Rates'),
                    Tab(text: 'Complaints'),
                    Tab(text: 'Photos'),
                  ],'''
new_tabs = '''                  tabs: [
                    Tab(text: 'Orders'),
                    Tab(text: 'Competitor Rates'),
                    Tab(text: 'Outlet Rates'),
                    Tab(text: 'Stock'),
                    Tab(text: 'Shelves'),
                    Tab(text: 'Promotions'),
                    Tab(text: 'Complaints'),
                    Tab(text: 'Photos'),
                  ],'''
text = text.replace(old_tabs, new_tabs)

# 3. Update TabBarView children
old_tab_children = '''          body: TabBarView(
            controller: _tabController,
            children: [
              _OrdersTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(0)),
              _CompetitorRatesTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(1)),
              _OutletRatesTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(2)),
              _ComplaintsTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(3)),
              _PhotosTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(4)),
            ],
          ),'''
new_tab_children = '''          body: TabBarView(
            controller: _tabController,
            children: [
              _OrdersTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(0)),
              _CompetitorRatesTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(1)),
              _OutletRatesTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(2)),
              _StockAvailabilityTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(3)),
              _ShelfPlacementsTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(4)),
              _PromotionAuditsTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(5)),
              _ComplaintsTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(6)),
              _PhotosTab(controller: controller, visitId: widget.visit.id, onAdd: () => _showAddSheet(7)),
            ],
          ),'''
text = text.replace(old_tab_children, new_tab_children)

# 4. Update _showAddSheet switch logic
old_show_add = '''    switch (index) {
      case 0: sheet = _AddOrderSheet(controller: controller, visitId: widget.visit.id); break;
      case 1: sheet = _AddCompetitorRateSheet(controller: controller, visitId: widget.visit.id); break;
      case 2: sheet = _AddOutletRateSheet(controller: controller, visitId: widget.visit.id); break;
      case 3: sheet = _AddComplaintSheet(controller: controller, visitId: widget.visit.id); break;
      case 4: sheet = _AddPhotoSheet(controller: controller, visitId: widget.visit.id); break;
    }'''

new_show_add = '''    switch (index) {
      case 0: sheet = _AddOrderSheet(controller: controller, visitId: widget.visit.id); break;
      case 1: sheet = _AddCompetitorRateSheet(controller: controller, visitId: widget.visit.id); break;
      case 2: sheet = _AddOutletRateSheet(controller: controller, visitId: widget.visit.id); break;
      case 3: sheet = _AddStockAvailabilitySheet(controller: controller, visitId: widget.visit.id); break;
      case 4: sheet = _AddShelfPlacementSheet(controller: controller, visitId: widget.visit.id); break;
      case 5: sheet = _AddPromotionAuditSheet(controller: controller, visitId: widget.visit.id); break;
      case 6: sheet = _AddComplaintSheet(controller: controller, visitId: widget.visit.id); break;
      case 7: sheet = _AddPhotoSheet(controller: controller, visitId: widget.visit.id); break;
    }'''
text = text.replace(old_show_add, new_show_add)

# 5. Update _isListNotEmpty
old_is_not_empty = '''    switch (index) {
      case 0: return controller.workspaceOrders.isNotEmpty;
      case 1: return controller.workspaceCompetitorRates.isNotEmpty;
      case 2: return controller.workspaceOutletRates.isNotEmpty;
      case 3: return controller.workspaceComplaints.isNotEmpty;
      case 4: return controller.workspacePhotos.isNotEmpty;
      default: return false;
    }'''

new_is_not_empty = '''    switch (index) {
      case 0: return controller.workspaceOrders.isNotEmpty;
      case 1: return controller.workspaceCompetitorRates.isNotEmpty;
      case 2: return controller.workspaceOutletRates.isNotEmpty;
      case 3: return controller.workspaceStockAvailability.isNotEmpty;
      case 4: return controller.workspaceShelfPlacements.isNotEmpty;
      case 5: return controller.workspacePromotionAudits.isNotEmpty;
      case 6: return controller.workspaceComplaints.isNotEmpty;
      case 7: return controller.workspacePhotos.isNotEmpty;
      default: return false;
    }'''
text = text.replace(old_is_not_empty, new_is_not_empty)

# 6. Add the missing fields (buyingPrice, hasNewProduct) to Competitor Rate
text = text.replace('''  final sellPriceController = TextEditingController();
  final offerPriceController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;
  bool hasOffer = false;''', '''  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();
  final offerPriceController = TextEditingController();
  final newProductDetailsController = TextEditingController();
  final notesController = TextEditingController();
  String? evidenceUrl;
  bool hasOffer = false;
  bool hasNewProduct = false;''')

text = text.replace('''          'competitorId': selectedCompetitor!.id,
          'sellingPrice': price,
          'hasOffer': hasOffer,
          'offerPrice': hasOffer ? (double.tryParse(offerPriceController.text) ?? 0) : null,
          'notes': notesController.text.trim(),''', '''          'competitorId': selectedCompetitor!.id,
          'buyingPrice': double.tryParse(buyPriceController.text) ?? 0,
          'sellingPrice': price,
          'hasOffer': hasOffer,
          'offerPrice': hasOffer ? (double.tryParse(offerPriceController.text) ?? 0) : null,
          'hasNewProduct': hasNewProduct,
          'newProductDetails': hasNewProduct ? newProductDetailsController.text.trim() : null,
          'notes': notesController.text.trim(),''')

text = text.replace('''            Expanded(
              child: _buildTextField(
                label: 'Selling Price',
                controller: sellPriceController,
                keyboardType: TextInputType.number,
                icon: Icons.price_change_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Column(''', '''            Expanded(
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
            Column(''')

text = text.replace('''              ],
            ),
          ],
        ),
        if (hasOffer) ...[''', '''              ],
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
        if (hasOffer) ...[''')

text = text.replace('''        ],
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),''', '''        ],
        if (hasNewProduct) ...[
          const SizedBox(height: 16),
          _buildTextField(label: 'New Product Details', controller: newProductDetailsController, maxLines: 2),
        ],
        const SizedBox(height: 16),
        _buildTextField(label: 'Notes', controller: notesController, maxLines: 2),''')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
