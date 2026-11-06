import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/account_details_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/crm_models.dart';
import '../activities/new_activity_view.dart';
import '../activities/modals/log_call_modal.dart';
import '../activities/modals/send_email_modal.dart';
import '../activities/modals/send_sms_modal.dart';
import '../../controllers/new_activity_controller.dart';
import '../../controllers/deals_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../deals/modals/add_deal_modal.dart';
import '../../widgets/activity_action_bottom_sheet.dart';

class AccountDetailsView extends StatefulWidget {
  const AccountDetailsView({super.key});

  @override
  State<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends State<AccountDetailsView> {
  late final AccountDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AccountDetailsController());
    
    // Register controllers used by creation sheets if not already present
    if (!Get.isRegistered<DealsController>()) Get.lazyPut(() => DealsController());
    if (!Get.isRegistered<ContactsController>()) Get.lazyPut(() => ContactsController());
    
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
          'entityType': 'account',
          'entityId': controller.account.id,
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
        child: _AccountNewNoteSheet(controller),
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
        child: _AccountUploadDocumentSheet(controller),
      ),
    );
    controller.fetchDocuments();
  }

  // ── FAB per tab ───────────────────────────────────────────────────
  Widget? _buildFab() {
    final idx = controller.tabController.index;
    if (idx == 4) {
      return FloatingActionButton(
        heroTag: 'account_note_fab',
        backgroundColor: AppColors.primary,
        onPressed: _showNewNoteSheet,
        child: const Icon(Icons.note_add, color: Colors.white),
      );
    }
    if (idx == 5) {
      return FloatingActionButton(
        heroTag: 'account_doc_fab',
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
      floatingActionButton: _buildFab(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        centerTitle: false,
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.business, color: AppColors.primary, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.account.accountName,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (controller.account.accountType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                controller.account.accountType!.toUpperCase(),
                                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(
                            controller.account.phone ?? '-',
                            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(
                            '${controller.account.billingCity ?? ''}, ${controller.account.billingState ?? ''}',
                            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildCommunicationRow(context, controller),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.tabController.animateTo(4),
                    icon: const Icon(Icons.sticky_note_2_outlined, size: 18),
                    label: const Text('Notes'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.tabController.animateTo(5),
                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                    label: const Text('Docs'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.background,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Scaffold(
                            backgroundColor: Colors.transparent,
                            appBar: AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              leading: IconButton(
                                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                                onPressed: () => Get.back(),
                              ),
                              title: const Text('Edit Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              centerTitle: true,
                            ),
                            body: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField('Account Name', controller.account.accountName),
                                  const SizedBox(height: 16),
                                  _buildTextField('Industry', controller.account.industry ?? 'e.g. Technology'),
                                  const SizedBox(height: 16),
                                  _buildTextField('Website', controller.account.website ?? 'e.g. www.acmecorp.com'),
                                  const SizedBox(height: 16),
                                  _buildTextField('Phone Number', controller.account.phone ?? 'e.g. +1 555 0123'),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                        Get.snackbar('Success', 'Account updated successfully',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: AppColors.success,
                                            colorText: Colors.white,
                                            margin: const EdgeInsets.all(16));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TabBar
          TabBar(
            controller: controller.tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            dividerColor: AppColors.divider,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'Contacts'),
              Tab(text: 'Deals'),
              Tab(text: 'Activity'),
              Tab(text: 'Notes'),
              Tab(text: 'Documents'),
            ],
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildInfoTab(controller),
                _buildContactsTab(),
                _buildDealsTab(),
                Obx(() => _buildActivityTab()),
                _buildNotesTab(),
                _buildDocumentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(AccountDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSectionTitle('COMPANY DETAILS'),
          _buildInfoBox([
            _buildInfoRow('Industry', controller.account.industry ?? 'N/A'),
            const Divider(color: AppColors.divider, height: 24),
            _buildInfoRow('Website', controller.account.website ?? '-', isLink: true),
            const Divider(color: AppColors.divider, height: 24),
            _buildInfoRow('Account Number', controller.account.accountNumber ?? '-'),
            const Divider(color: AppColors.divider, height: 24),
            _buildInfoRow('Payment Terms', controller.account.paymentTerm ?? '-'),
            ...(controller.account.paymentTermDays != null
                ? [
                    const Divider(color: AppColors.divider, height: 24),
                    _buildInfoRow('Credit Term Days', '${controller.account.paymentTermDays} Days'),
                  ]
                : []),
          ]),
          const SizedBox(height: 24),

        


        
        ],
      ),
    );
  }

  Widget _buildInfoSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
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
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isLink ? AppColors.primary : Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipRow(String name, String role, String avatarUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 12)),
            const SizedBox(height: 2),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandableAddressSection({
    required String title,
    required IconData icon,
    required String addressLine1,
    required String addressLine2,
  }) {
    return Container(
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
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(addressLine1, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 14, height: 1.5)),
          Text(addressLine2, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    return Obx(() {
      final contacts = controller.contacts;

      if (controller.isLoadingContacts.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.people_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text('Account Contacts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${contacts.length} contacts',
                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Get.bottomSheet(_AccountNewContactSheet(controller)),
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
            child: contacts.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No contacts linked to this account', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6))),
                    ],
                  ),
                )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                contact.initials,
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contact.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  if (contact.title != null)
                                    Text(contact.title!, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(contact.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onPressed: () => Get.toNamed('/contact-details', arguments: contact),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildDealsTab() {
    return Obx(() {
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
                const Icon(Icons.handshake_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text('Account Deals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${deals.length} deals',
                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddDealSheet,
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
            child: deals.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.handshake_outlined, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No deals linked to this account', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6))),
                    ],
                  ),
                )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: deals.length,
                    itemBuilder: (context, index) {
                      final deal = deals[index];
                      // Real data mappings: stageName is mapped from joined salesStage table
                      bool isWon = deal.isWon;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                                    child: Text(deal.dealName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  Text(
                                    '${controller.account.billingCountry == 'Kenya' ? 'Kes' : '\$'} ${deal.salePrice.toStringAsFixed(0)}', 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isWon ? AppColors.success.withOpacity(0.2) : AppColors.warning.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      deal.stage ?? 'Deal Stage',
                                      style: TextStyle(
                                        color: isWon ? AppColors.success : AppColors.warning,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    deal.closingDate != null 
                                      ? DateFormat('MMM dd, yyyy').format(DateTime.parse(deal.closingDate!))
                                      : 'No date', 
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  void _showAddDealSheet() {
    final dealsController = Get.find<DealsController>();
    dealsController.preSelectedAccountId = controller.account.id;
    Get.bottomSheet(
      const AddDealModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

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
    return Obx(() {
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
                const Text('Account Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${notes.length} notes',
                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Get.bottomSheet(
                    _AccountNewNoteSheet(controller),
                    isScrollControlled: true,
                  ),
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
    });
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
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
                      fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
  // DOCUMENTS TAB
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDocumentsTab() {
    return Obx(() {
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
                const Text('Account Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  onPressed: () => Get.bottomSheet(_AccountUploadDocumentSheet(controller)),
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
        ],
      );
    });
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
            icon: Icon(Icons.download_outlined,
                color: AppColors.textSecondary.withOpacity(0.7), size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hintText, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          controller: TextEditingController(text: hintText.contains('e.g.') ? '' : hintText),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunicationRow(BuildContext context, AccountDetailsController controller) {
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
                  entityType: 'account',
                  entityId: controller.account.id,
                  entityName: controller.account.accountName,
                  phone: controller.account.phone,
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
                  entityType: 'account',
                  entityId: controller.account.id,
                  entityName: controller.account.accountName,
                  phone: controller.account.phone,
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
                  entityType: 'account',
                  entityId: controller.account.id,
                  entityName: controller.account.accountName,
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
}

// ── Data Models ──────────────────────────────────────────────────────────
// Data models are now synced with crm_models.dart

// ═══════════════════════════════════════════════════════════════════════
// NEW NOTE BOTTOM-SHEET (Account)
// ═══════════════════════════════════════════════════════════════════════
class _AccountNewNoteSheet extends StatefulWidget {
  final AccountDetailsController controller;

  const _AccountNewNoteSheet(this.controller);

  @override
  State<_AccountNewNoteSheet> createState() => _AccountNewNoteSheetState();
}

class _AccountNewNoteSheetState extends State<_AccountNewNoteSheet> {
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
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'e.g. Account strategy notes',
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
                        const SizedBox(height: 20),
                        const Text('Note',
                            style: TextStyle(
                                color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bodyController,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Write your note here...',
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
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.push_pin, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pin this note',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  SizedBox(height: 4),
                                  Text('Pinned notes appear at the top',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            Switch(value: false, onChanged: (_) {}, activeColor: AppColors.primary),
                          ]),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// ═══════════════════════════════════════════════════════════════════════
// UPLOAD DOCUMENT BOTTOM-SHEET (Account)
// ═══════════════════════════════════════════════════════════════════════
class _AccountUploadDocumentSheet extends StatefulWidget {
  final AccountDetailsController controller;
  const _AccountUploadDocumentSheet(this.controller);

  @override
  State<_AccountUploadDocumentSheet> createState() => _AccountUploadDocumentSheetState();
}

class _AccountUploadDocumentSheetState extends State<_AccountUploadDocumentSheet> {
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
                          shape: BoxShape.circle),
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
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
class _AccountNewContactSheet extends StatefulWidget {
  final AccountDetailsController controller;
  const _AccountNewContactSheet(this.controller);

  @override
  State<_AccountNewContactSheet> createState() => _AccountNewContactSheetState();
}

class _AccountNewContactSheetState extends State<_AccountNewContactSheet> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _emailController.text.isEmpty) {
      Get.snackbar('Validation', 'First Name, Last Name and Email are required',
          backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);
    final contactsController = Get.find<ContactsController>();
    
    final payload = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'title': _titleController.text,
      'accountId': widget.controller.account.id,
      'tenantId': widget.controller.account.tenantId,
    };

    final success = await contactsController.createContact(payload);
    setState(() => _isSaving = false);
    
    if (success) {
      widget.controller.fetchContacts();
      Get.back();
      Get.snackbar('Success', 'Contact added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white);
    }
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
        title: const Text('New Account Contact',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('First Name',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                hintText: 'e.g. John',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Last Name',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Doe',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Job Title',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Manager',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Email Address',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'e.g. john@example.com',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Phone Number',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'e.g. +254...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
