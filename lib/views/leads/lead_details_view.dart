import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lead_details_controller.dart';
import '../../controllers/new_activity_controller.dart';
import '../../views/activities/new_activity_view.dart';
import '../../controllers/deals_controller.dart';
import '../../views/deals/modals/add_deal_modal.dart';
import '../../utils/app_colors.dart';
import '../../models/crm_models.dart';
import '../../views/activities/modals/log_call_modal.dart';
import '../../views/activities/modals/send_email_modal.dart';
import '../../views/activities/modals/send_sms_modal.dart';
import '../../widgets/activity_action_bottom_sheet.dart';

class LeadDetailsView extends StatefulWidget {
  const LeadDetailsView({super.key});

  @override
  State<LeadDetailsView> createState() => _LeadDetailsViewState();
}

class _LeadDetailsViewState extends State<LeadDetailsView>
    with SingleTickerProviderStateMixin {
  late final LeadDetailsController controller;
  bool _fabExpanded = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LeadDetailsController());
    controller.tabController.addListener(() {
      if (mounted) setState(() => _fabExpanded = false);
    });
  }

  // ── Bottom-sheet helpers ────────────────────────────────────────────
  Future<void> _showNewActivitySheet() async {
    // Reset the controller so the form is fresh
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
          'entityType': 'lead',
          'entityId': controller.lead.id,
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
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: _NewNoteSheet(controller),
      ),
    );
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
        child: _UploadDocumentSheet(controller),
      ),
    );
    controller.fetchDocuments();
  }

  // ── FAB per tab ────────────────────────────────────────────────────
  Widget? _buildFab() {
    final idx = controller.tabController.index;
    if (idx == 2) {
      return FloatingActionButton(
        heroTag: 'lead_note_fab',
        backgroundColor: AppColors.primary,
        onPressed: _showNewNoteSheet,
        child: const Icon(Icons.note_add, color: Colors.white),
      );
    }
    if (idx == 3) {
      return FloatingActionButton(
        heroTag: 'lead_doc_fab',
        backgroundColor: AppColors.primary,
        onPressed: _showUploadDocumentSheet,
        child: const Icon(Icons.upload_file, color: Colors.white),
      );
    }
    if (idx == 4) {
      return FloatingActionButton(
        heroTag: 'lead_deal_fab',
        backgroundColor: AppColors.primary,
        onPressed: _showNewDealSheet,
        child: const Icon(Icons.add_business, color: Colors.white),
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
          title: const Text('Lead Details',
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
            // Header Profile
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/150?u=jonathan'),
            ),
            const SizedBox(height: 16),
            Text(
              controller.lead.name,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${controller.lead.status.toUpperCase()} at ${controller.lead.company}',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            _buildCommunicationRow(),
            const SizedBox(height: 8),

            // TabBar
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
                Tab(text: 'Deals'),
              ],
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildOverviewTab(controller),
                  Obx(() => _buildActivityTab()),
                  Obx(() => _buildNotesTab()),
                  Obx(() => _buildDocumentsTab()),
                  Obx(() => _buildDealsTab()),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildCommunicationRow({bool isFullWidth = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isFullWidth ? 0 : 20, vertical: 8),
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
                  entityType: 'lead',
                  entityId: controller.lead.id,
                  entityName: controller.lead.name,
                  phone: controller.lead.phone,
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
                  entityType: 'lead',
                  entityId: controller.lead.id,
                  entityName: controller.lead.name,
                  phone: controller.lead.phone,
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
                  entityType: 'lead',
                  entityId: controller.lead.id,
                  entityName: controller.lead.name,
                  email: controller.lead.email,
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

  // ═══════════════════════════════════════════════════════════════════════
  // OVERVIEW TAB
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildOverviewTab(LeadDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Cards
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  label: 'STATUS',
                  valueWidget: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(controller.lead.status.capitalizeFirst ?? 'New',
                        style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  label: 'SCORE',
                  valueWidget: Text(controller.lead.leadScore?.toString() ?? '0',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  label: 'REVENUE',
                  valueWidget: Text(controller.lead.annualRevenue != null ? '\$${controller.lead.annualRevenue!.toStringAsFixed(0)}' : '-',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sections
          _buildSectionHeader(Icons.person_outline, 'Identity'),
          _buildInfoBox([
            _buildInfoRow('First Name', controller.lead.firstName),
            const SizedBox(height: 16),
            _buildInfoRow('Last Name', controller.lead.lastName),
            if (controller.lead.salutation != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow('Salutation', controller.lead.salutation!),
            ],
          ]),
          const SizedBox(height: 20),

          _buildSectionHeader(Icons.business_outlined, 'Company Info'),
          _buildInfoBox([
            _buildInfoRow('Company', controller.lead.company),
            const SizedBox(height: 16),
            _buildInfoRow('Industry', controller.lead.industry ?? 'General'),
            const SizedBox(height: 16),
            _buildInfoRow('Employees', controller.lead.numberOfEmployees?.toString() ?? '-'),
          ]),
          const SizedBox(height: 20),

          _buildSectionHeader(
              Icons.alternate_email_outlined, 'Contact Info'),
          _buildInfoBox([
            _buildContactRow('Email', controller.lead.email,
                isLink: true),
            const SizedBox(height: 16),
            _buildContactRow('Phone', controller.lead.phone ?? '-'),
            const SizedBox(height: 16),
            _buildContactRow('Mobile', controller.lead.mobile ?? '-'),
          ]),

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
      margin: const EdgeInsets.symmetric(vertical: 8),
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
              const Text('Lead Notes',
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
                onPressed: _showNewNoteSheet,
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
              const Icon(Icons.folder_open_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text('Lead Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${docs.length} files',
                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showUploadDocumentSheet,
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
          child: docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('No documents found', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5))),
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

  // ═══════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildMiniStatCard(
      {required String label, required Widget valueWidget}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary.withOpacity(0.6),
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoBox(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildContactRow(String label, String value,
      {bool isLink = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: isLink ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DEALS TAB
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDealsTab() {
    final deals = controller.deals;

    if (controller.isLoadingDeals.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.business_center_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text('Lead Deals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${deals.length} deals',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showNewDealSheet,
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
          child: deals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_center_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('No deals found',
                          style: TextStyle(
                              color:
                                  AppColors.textSecondary.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    final deal = deals[index];
                    return _buildDealCard(deal);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDealCard(DealModel deal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/deal-details', arguments: deal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deal.dealName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Text(
                  'Kes ${deal.salePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    deal.stage?.toUpperCase() ?? 'NEW',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  'Closing: ${deal.closingDate ?? "TBD"}',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNewDealSheet() async {
    if (!Get.isRegistered<DealsController>()) {
      Get.lazyPut(() => DealsController());
    }
    final dealsController = Get.find<DealsController>();
    dealsController.preSelectedLeadId = controller.lead.id;
    dealsController.preSelectedLeadName = controller.lead.name;
    
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddDealModal(),
    );
    
    if (result == true) {
      controller.fetchDeals();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// NEW NOTE BOTTOM-SHEET (shared between Lead & Deal)
// ═══════════════════════════════════════════════════════════════════════
class _NewNoteSheet extends StatefulWidget {
  final LeadDetailsController controller;

  const _NewNoteSheet(this.controller);

  @override
  State<_NewNoteSheet> createState() => _NewNoteSheetState();
}

class _NewNoteSheetState extends State<_NewNoteSheet> {
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
    return Builder(
      builder: (context) {
        final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'New Note',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ElevatedButton(
                          onPressed: () => widget.controller.saveNote(
                            _titleController.text,
                            _bodyController.text,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Flexible so the scroll view has a bounded height and can scroll
                Flexible(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                                borderSide: const BorderSide(color: AppColors.divider)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.divider)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primary)),
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
                          maxLines: 5,
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
                                borderSide: const BorderSide(color: AppColors.divider)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.divider)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
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
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => widget.controller.saveNote(
                              _titleController.text,
                              _bodyController.text,
                            ),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Data Models ──────────────────────────────────────────────────────────
// Data models are now synced with crm_models.dart

// ═══════════════════════════════════════════════════════════════════════
// UPLOAD DOCUMENT BOTTOM-SHEET
// ═══════════════════════════════════════════════════════════════════════
class _UploadDocumentSheet extends StatefulWidget {
  final LeadDetailsController controller;
  const _UploadDocumentSheet(this.controller);

  @override
  State<_UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<_UploadDocumentSheet> {
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
            // Upload area
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
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5,
                      style: BorderStyle.solid),
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
