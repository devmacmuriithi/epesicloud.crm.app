import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/deal_details_controller.dart';
import '../../controllers/new_activity_controller.dart';
import '../../views/activities/new_activity_view.dart';
import '../../utils/app_colors.dart';
import '../../models/crm_models.dart';
import '../../views/activities/modals/log_call_modal.dart';
import '../../views/activities/modals/send_email_modal.dart';
import '../../views/activities/modals/send_sms_modal.dart';
import '../../Services/lookups_service.dart';
import '../../widgets/activity_action_bottom_sheet.dart';


class DealDetailsView extends StatefulWidget {
  const DealDetailsView({super.key});

  @override
  State<DealDetailsView> createState() => _DealDetailsViewState();
}

class _DealDetailsViewState extends State<DealDetailsView> {
  late final DealDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DealDetailsController());
    controller.tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  // ── Bottom-sheet helpers ────────────────────────────────────────────
  Future<void> _showNewActivitySheet() async {
    Get.delete<NewActivityController>(force: true);
    final result = await Get.bottomSheet(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const NewActivityView(),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      settings: RouteSettings(
        arguments: {
          'entityType': 'deal',
          'entityId': controller.deal.value.id,
        },
      ),
    );
    
    if (result == true) {
      controller.fetchActivities();
    }
  }

  Future<void> _showNewNoteSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _DealNewNoteSheet(controller),
      ),
    );
    // Fetch refreshed list after modal closure
    controller.fetchNotes();
  }

  Future<void> _showUploadDocumentSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: _DealUploadDocumentSheet(controller),
      ),
    );
    // Fetch refreshed list after modal closure
    controller.fetchDocuments();
  }

  void _showMoveStageSheet() {
    final lookups = Get.find<LookupsService>();
    final stages = lookups.salesStages;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Move Deal Stage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (stages.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...stages.map((stage) => ListTile(
                    title: Text(stage.title),
                    trailing: controller.deal.value.stage?.toUpperCase() ==
                            stage.title.toUpperCase()
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Get.back();
                      controller.moveStage(stage);
                    },
                  )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogPaymentSheet() {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (Kes)',
                filled: true,
                fillColor: AppColors.surface,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: referenceController,
              decoration: InputDecoration(
                labelText: 'Payment Reference',
                filled: true,
                fillColor: AppColors.surface,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                filled: true,
                fillColor: AppColors.surface,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) {
                    Get.snackbar('Error', 'Please enter a valid amount');
                    return;
                  }
                  controller.logPayment(
                    amount,
                    referenceController.text,
                    notes: notesController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Payment',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddProductsSheet() {
    // Removed as per request
  }

  Widget _buildProductItem(String title, String price) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(price, style: const TextStyle(color: AppColors.primary)),
      trailing: Checkbox(value: false, onChanged: (v) {}, activeColor: AppColors.primary),
    );
  }

  // ── FAB per tab ────────────────────────────────────────────────────
  Widget? _buildFab() {
    final idx = controller.tabController.index;
    if (idx == 1) {
      return FloatingActionButton(
        heroTag: 'deal_activity_fab',
        backgroundColor: AppColors.primary,
        onPressed: _showNewActivitySheet,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    if (idx == 2) {
      return FloatingActionButton(
        heroTag: 'deal_notes_fab',
        backgroundColor: AppColors.primary,
        onPressed: _showNewNoteSheet,
        child: const Icon(Icons.note_add, color: Colors.white),
      );
    }
    if (idx == 3) {
      return FloatingActionButton(
        heroTag: 'deal_doc_fab',
        backgroundColor: AppColors.primary,
        onPressed: _showUploadDocumentSheet,
        child: const Icon(Icons.upload_file, color: Colors.white),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          title: const Text('Deal Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButton: _buildFab(),
        body: Column(
          children: [
            // ── Fixed Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.handshake_outlined, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.deal.value.dealName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Kes ${controller.deal.value.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14,
                                color: AppColors.textSecondary
                                    .withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(
                              'Closing Date: ${controller.deal.value.closingDate ?? "N/A"}',
                              style: TextStyle(
                                  color: AppColors.textSecondary
                                      .withOpacity(0.8),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _buildCommunicationRow(context),
            const SizedBox(height: 8),

            // ── TabBar ───────────────────────────────────────────────
            TabBar(
              controller: controller.tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Activity'),
                Tab(text: 'Notes'),
                Tab(text: 'Documents'),
                Tab(text: 'Payments'),
              ],
            ),

            // ── TabBarView ───────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  Obx(() => _buildOverviewTab(controller)),
                  Obx(() => _buildActivityTab()),
                  Obx(() => _buildNotesTab()),
                  Obx(() => _buildDocumentsTab()),
                  Obx(() => _buildPaymentsTab()),
                ],
              ),
            ),
          ],
        ),
      );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // OVERVIEW TAB
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildOverviewTab(DealDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pipeline Stage Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SALE STAGE',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(controller.deal.value.stage ?? 'N/A',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final lookups = Get.find<LookupsService>();
                  final stages = lookups.salesStages;
                  
                  if (stages.isEmpty) {
                    return const Center(child: LinearProgressIndicator());
                  }

                  // Find index of current stage
                  int currentIndex = stages.indexWhere((s) => s.title.toUpperCase() == controller.deal.value.stage?.toUpperCase());
                  if (currentIndex == -1) currentIndex = 0;

                  return Row(
                    children: List.generate(stages.length * 2 - 1, (index) {
                      if (index.isEven) {
                        int stageIdx = index ~/ 2;
                        bool isActive = stageIdx <= currentIndex;
                        bool isFilled = stageIdx < currentIndex || (stageIdx == currentIndex && controller.deal.value.isWon);
                        return _buildStageDot(isActive: isActive, isFilled: isFilled);
                      } else {
                        int lineIdx = index ~/ 2;
                        bool isActive = lineIdx < currentIndex;
                        return _buildStageLine(isActive: isActive);
                      }
                    }),
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(), // Removed probability display
                    ElevatedButton(
                      onPressed: _showMoveStageSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Row(children: [
                        Text('Move Stage',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.white, size: 16),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 24),
          // Action Buttons removed as per request
          const SizedBox(height: 8),

          // Relationships
          const Text('Relationships',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildRelationshipBox(
              icon: Icons.business,
              label: 'Account',
              value: controller.deal.value.accountName ?? "No account linked",
              isAvatar: false,
              onTap: () => Get.toNamed('/account-details')),
          const SizedBox(height: 12),
          _buildRelationshipBox(
              avatarUrl: 'https://i.pravatar.cc/150?u=sarahj',
              label: 'Primary Contact',
              value: controller.deal.value.contactName ?? "No contact linked",
              isAvatar: true,
              onTap: () => Get.toNamed('/contact-details')),
          const SizedBox(height: 12),
          _buildRelationshipBox(
              icon: Icons.campaign_outlined,
              label: 'Lead Source',
              value: controller.deal.value.leadSourceName ?? "No source provided",
              isAvatar: false),
          const SizedBox(height: 32),

          // CRM Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CRM Data',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('Edit Fields',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCrmDataRow('Deal Owner', controller.deal.value.agentName ?? 'Unassigned'),
                const Divider(color: AppColors.divider, height: 32),
                _buildCrmDataRow('Created Date', controller.deal.value.createdTime ?? 'N/A'),
                const Divider(color: AppColors.divider, height: 32),
                _buildCrmDataRow('Next Step', controller.deal.value.nextStep ?? 'N/A'),
                const Divider(color: AppColors.divider, height: 32),
                const Text('Deal Description',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Text(
                  controller.deal.value.description ?? 'No description provided.',
                  style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ACTIVITY TAB
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildActivityTab() {
    final feed = controller.filteredFeed;

    if (controller.isLoadingActivities.value || controller.isLoadingNotes.value || controller.isLoadingDocuments.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildActivityFilters(),
        Expanded(
          child: feed.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: AppColors.textSecondary.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('No matching entries found', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: feed.length,
                  itemBuilder: (context, index) {
                    final item = feed[index];
                    return _buildFeedItem(item, index == feed.length - 1);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActivityFilters() {
    final filters = ['All', 'Calls', 'SMS', 'Emails', 'Notes', 'Docs'];
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Obx(() {
            final isSelected = controller.currentActivityFilter.value == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) controller.currentActivityFilter.value = filter;
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
                ),
                showCheckmark: false,
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildFeedItem(dynamic item, bool isLast) {
    if (item is ActivityModel) {
      return _buildActivityFeedItem(item, isLast);
    } else if (item is NoteModel) {
      return _buildNoteFeedItem(item, isLast);
    } else if (item is DocumentModel) {
      return _buildDocumentFeedItem(item, isLast);
    }
    return const SizedBox.shrink();
  }

  Widget _buildActivityFeedItem(ActivityModel a, bool isLast) {
    IconData activityIcon = Icons.event_note;
    Color activityColor = AppColors.primary;
    if (a.type.toLowerCase().contains('call')) {
      activityIcon = Icons.phone_callback;
      activityColor = AppColors.success;
    } else if (a.type.toLowerCase().contains('email')) {
      activityIcon = Icons.email_outlined;
      activityColor = const Color(0xFF3B82F6);
    } else if (a.type.toLowerCase().contains('sms') || a.type.toLowerCase().contains('message')) {
      activityIcon = Icons.textsms_outlined;
      activityColor = const Color(0xFF06B6D4);
    }

    return _buildActivityFeedItemLine(
      type: a.type,
      color: activityColor,
      isLast: isLast,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(a.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              Text(a.dueDate ?? '', style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 4),
          Text(a.description ?? a.type, style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildActivityFeedItemLine({required String type, required Color color, required Widget child, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 1.5, color: AppColors.divider, margin: const EdgeInsets.symmetric(vertical: 4))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteFeedItem(NoteModel n, bool isLast) {
    return _buildFeedLine(
      icon: Icons.sticky_note_2_outlined,
      color: const Color(0xFFFFB020),
      isLast: isLast,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(n.title ?? 'Unified Note', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB45309)))),
              Text(n.createdAt != null ? '${n.createdAt!.day}/${n.createdAt!.month}/${n.createdAt!.year}' : '', 
                   style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 4),
          Text(n.content, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildDocumentFeedItem(DocumentModel d, bool isLast) {
    return _buildFeedLine(
      icon: Icons.description_outlined,
      color: const Color(0xFF8B5CF6),
      isLast: isLast,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(d.fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5B21B6)))),
              Text('${d.createdAt.day}/${d.createdAt.month}/${d.createdAt.year}', 
                   style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 4),
          Text('File Size: ${(d.fileSize != null ? (d.fileSize! / 1024).toStringAsFixed(1) : "0")} KB', 
               style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildFeedLine({required IconData icon, required Color color, required Widget child, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
              if (!isLast) Expanded(child: Container(width: 1.5, color: AppColors.divider, margin: const EdgeInsets.symmetric(vertical: 4))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NOTES TAB
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildNotesTab() {
    final notes = controller.notes;

    if (controller.isLoadingNotes.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.sticky_note_2_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text('Deal Notes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${notes.length} notes',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Get.bottomSheet(_DealNewNoteSheet(controller)),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sticky_note_2_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('No notes found', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return _buildNoteCard(notes[index]);
                  },
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DOCUMENTS TAB
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDocumentsTab() {
    final docs = controller.documents;

    if (controller.isLoadingDocuments.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.folder_open_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text('Deal Documents',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${docs.length} files',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showUploadDocumentSheet,
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('No documents found',
                          style: TextStyle(
                              color:
                                  AppColors.textSecondary.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _buildDocumentCard(docs[index]);
                  },
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAYMENTS TAB
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildPaymentsTab() {
    final payments = controller.payments;

    if (controller.isLoadingPayments.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.payments_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text('Deal Payments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${payments.length} payments',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showLogPaymentSheet,
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Log', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('No payments found',
                          style: TextStyle(
                              color:
                                  AppColors.textSecondary.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final p = payments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.receiptNumber,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(
                                'Kes ${p.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14,
                                  color:
                                      AppColors.textSecondary.withOpacity(0.7)),
                              const SizedBox(width: 6),
                              Text(p.paymentDate,
                                  style: TextStyle(
                                      color: AppColors.textSecondary
                                          .withOpacity(0.7),
                                      fontSize: 12)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.status.toLowerCase() == 'completed'
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.status.toUpperCase(),
                                  style: TextStyle(
                                      color: p.status.toLowerCase() ==
                                              'completed'
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          if (p.transactionReference != null &&
                              p.transactionReference!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Ref: ${p.transactionReference}',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNoteCard(NoteModel n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(n.title ?? 'Untitled Note',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14))),
          ]),
          const SizedBox(height: 10),
          Text(n.content,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withOpacity(0.9),
                  height: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: const Text('U',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ),
            const SizedBox(width: 6),
            const Text('You',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary)),
            const Spacer(),
            Text('${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withOpacity(0.6))),
          ]),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentModel d) {
    Color typeColor;
    IconData typeIcon;
    final extension = d.fileName.split('.').last.toUpperCase();
    
    switch (extension) {
      case 'PDF':
        typeColor = const Color(0xFFEF4444);
        typeIcon = Icons.picture_as_pdf_outlined;
        break;
      case 'XLS':
      case 'XLSX':
      case 'CSV':
        typeColor = const Color(0xFF22C55E);
        typeIcon = Icons.table_chart_outlined;
        break;
      case 'DOC':
      case 'DOCX':
      case 'TXT':
        typeColor = const Color(0xFF3B82F6);
        typeIcon = Icons.description_outlined;
        break;
      case 'JPG':
      case 'JPEG':
      case 'PNG':
      case 'SVG':
        typeColor = const Color(0xFF8B5CF6);
        typeIcon = Icons.image_outlined;
        break;
      default:
        typeColor = AppColors.textSecondary;
        typeIcon = Icons.insert_drive_file_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: typeColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(d.fileType ?? extension,
                          style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(d.fileSize != null ? '${(d.fileSize! / 1024).toStringAsFixed(1)} KB' : 'Size unknown',
                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12)),
                    const SizedBox(width: 8),
                    Text('· ${d.createdAt.day}/${d.createdAt.month}/${d.createdAt.year}',
                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download_outlined, color: AppColors.textSecondary.withOpacity(0.7), size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildStageDot(
      {required bool isActive, required bool isFilled}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.primary : AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
            color: isActive ? AppColors.primary : AppColors.divider,
            width: 3),
      ),
    );
  }

  Widget _buildStageLine({required bool isActive}) {
    return Expanded(
        child: Container(
            height: 3,
            color: isActive ? AppColors.primary : AppColors.divider));
  }

  Widget _buildRelationshipBox({
    IconData? icon,
    String? avatarUrl,
    required String label,
    required String value,
    required bool isAvatar,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isAvatar ? Colors.transparent : AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: isAvatar
                  ? null
                  : Border.all(color: AppColors.divider),
            ),
            child: isAvatar
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        Image.network(avatarUrl!, fit: BoxFit.cover))
                : Icon(icon, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ]),
      ),
    );
  }

  Widget _buildCrmDataRow(String label, String value,
      {Widget? trailingWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
        Row(children: [
          if (trailingWidget != null) trailingWidget,
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
        ]),
      ],
    );
  }
}

// ── Deal-specific New Note Sheet ─────────────────────────────────────────
class _DealNewNoteSheet extends StatefulWidget {
  final DealDetailsController controller;

  const _DealNewNoteSheet(this.controller);

  @override
  State<_DealNewNoteSheet> createState() => _DealNewNoteSheetState();
}

class _DealNewNoteSheetState extends State<_DealNewNoteSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New Note',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () => widget.controller.saveNote(_titleController.text, _bodyController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Save',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Follow-up action items',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Note',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              maxLines: 8,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Write your note here...',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.push_pin,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pin this note',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      SizedBox(height: 4),
                      Text('Pinned notes appear at the top',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                    value: false,
                    onChanged: (_) {},
                    activeColor: AppColors.primary),
              ]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.controller.saveNote(_titleController.text, _bodyController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Note',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _DealDetailsViewStateCommunication on _DealDetailsViewState {
  Widget _buildCommunicationRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionButton(
            icon: Icons.call,
            label: 'Call',
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => ActivityActionBottomSheet(
                  actionType: 'call',
                  entityType: 'deal',
                  entityId: controller.deal.value.id,
                  entityName: controller.deal.value.dealName,
                  onActivityLogged: () => controller.fetchActivities(),
                ),
              );
            },
          ),
          _actionButton(
            icon: Icons.textsms_outlined,
            label: 'SMS',
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => ActivityActionBottomSheet(
                  actionType: 'sms',
                  entityType: 'deal',
                  entityId: controller.deal.value.id,
                  entityName: controller.deal.value.dealName,
                  onActivityLogged: () => controller.fetchActivities(),
                ),
              );
            },
          ),
          _actionButton(
            icon: Icons.email,
            label: 'Email',
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => ActivityActionBottomSheet(
                  actionType: 'email',
                  entityType: 'deal',
                  entityId: controller.deal.value.id,
                  entityName: controller.deal.value.dealName,
                  onActivityLogged: () => controller.fetchActivities(),
                ),
              );
            },
          ),
          _actionButton(
            icon: Icons.note_add_outlined,
            label: 'Note',
            onPressed: _showNewNoteSheet,
          ),
          _actionButton(
            icon: Icons.upload_file_outlined,
            label: 'Doc',
            onPressed: _showUploadDocumentSheet,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _communicationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isOutlined,
    Color? backgroundColor,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: AppColors.primary),
        label: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      );
    }
  }
}

// ── Data Models ──────────────────────────────────────────────────────────
// Data models are now synced with crm_models.dart

// ═══════════════════════════════════════════════════════════════════════
// UPLOAD DOCUMENT BOTTOM-SHEET (Deal)
// ═══════════════════════════════════════════════════════════════════════
class _DealUploadDocumentSheet extends StatefulWidget {
  final DealDetailsController controller;
  const _DealUploadDocumentSheet(this.controller);

  @override
  State<_DealUploadDocumentSheet> createState() => _DealUploadDocumentSheetState();
}

class _DealUploadDocumentSheetState extends State<_DealUploadDocumentSheet> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Upload Document',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => widget.controller.pickAndUploadDocument(
                description: _descriptionController.text
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_outlined,
                          color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tap to select a file',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('PDF, DOC, XLS, PNG up to 25 MB',
                        style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Description (optional)',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a note about this document...',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => widget.controller.pickAndUploadDocument(
                  description: _descriptionController.text
                ),
                icon: const Icon(Icons.upload_file, color: Colors.white, size: 18),
                label: const Text('Upload Document',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
