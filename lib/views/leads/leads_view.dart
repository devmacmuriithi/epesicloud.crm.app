import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/leads_controller.dart';
import '../../controllers/accounts_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/lead_model.dart';
import '../../models/crm_models.dart';
import '../../Services/lookups_service.dart';
import 'modals/add_lead_modal.dart';
import '../accounts/modals/add_account_modal.dart';

class LeadsView extends StatelessWidget {
  const LeadsView({super.key});

  @override
  Widget build(BuildContext context) {
    final leadsController = Get.put(LeadsController());
    final accountsController = Get.put(AccountsController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              heroTag: null,
              onPressed: () {
                final tabIndex = DefaultTabController.of(context).index;
                if (tabIndex == 0) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddLeadModal(),
                  );
                } else if (tabIndex == 1) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddAccountModal(),
                  );
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            );
          }
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const TabBar(
                tabs: [
                  Tab(text: 'Leads'),
                  Tab(text: 'Accounts'),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLeadsTab(leadsController),
                    _buildAccountsTab(accountsController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadsTab(LeadsController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _buildSearchAndFilters(
            'Search leads by name or company...',
            controller,
            isLeads: true,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.leads.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.leads.isEmpty) {
              return const Center(child: Text('No leads found'));
            }
            return RefreshIndicator(
              onRefresh: () => controller.fetchLeads(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.leads.length,
                itemBuilder: (context, index) {
                  return _buildLeadCard(controller.leads[index], controller);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAccountsTab(AccountsController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _buildSearchAndFilters(
            'Search accounts by name or industry...',
            controller,
            isLeads: false,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.accounts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.accounts.isEmpty) {
              return const Center(child: Text('No accounts found'));
            }
            return RefreshIndicator(
              onRefresh: () => controller.fetchAccounts(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: controller.accounts.length,
                itemBuilder: (context, index) {
                  return _buildAccountCard(controller.accounts[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.hub, size: 28, color: AppColors.primary),
          const SizedBox(width: 12),
          const Text(
            'Epesicloud Crm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary),
                onPressed: () => Get.toNamed('/notifications'),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(String hint, dynamic controller, {required bool isLeads}) {
    final lookupsService = Get.find<LookupsService>();

    return Column(
      children: [
        TextField(
          onChanged: (value) => controller.setSearchQuery(value),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          bool isAllSelected;
          if (isLeads) {
            isAllSelected = controller.selectedStatus.value.id == -1 && 
                            controller.selectedSource.value.id == -1;
          } else {
            isAllSelected = controller.selectedStatus.value.id == -1;
          }
          
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    isLeads ? 'All Leads' : 'All Accounts',
                    isSelected: isAllSelected,
                    onTap: () => controller.resetFilters(),
                  ),
                ),
                // Status/Type Pills
                ...(isLeads ? lookupsService.leadStatusTypes : lookupsService.accountTypes).map((item) {
                  final isSelected = controller.selectedStatus.value.id == item.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      item.title,
                      isSelected: isSelected,
                      onTap: () => controller.setStatus(item),
                    ),
                  );
                }).toList(),
                // Source Pills (Only for Leads)
                if (isLeads)
                  ...lookupsService.leadSources.map((source) {
                    final isSelected = controller.selectedSource.value.id == source.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        source.title,
                        isSelected: isSelected,
                        onTap: () => controller.setSource(source),
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

  Widget _buildSelectionSheet(String title, List<LookupModel> options, LookupModel selected, Function(LookupModel) onSelect) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final item = options[index];
                final isSelected = item.id == selected.id;
                return ListTile(
                  title: Text(item.title, style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    onSelect(item);
                    Get.back();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, VoidCallback? onTap}) {
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

  Widget _buildLeadCard(LeadModel lead, LeadsController controller) {
    Color statusColor;
    final status = lead.status.toUpperCase();
    switch (status) {
      case 'QUALIFIED': statusColor = AppColors.success; break;
      case 'NEGOTIATION': statusColor = AppColors.warning; break;
      case 'NEW LEAD': 
      case 'NEW':
        statusColor = AppColors.primary; break;
      default: statusColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: () => controller.openLeadDetails(lead),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.brown[400], // matching Johnathan's avatar color
                child: Text(
                  lead.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).join().toUpperCase().isNotEmpty
                      ? lead.name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).join().toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lead.company,
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lead.status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_getSourceIcon('Website'), size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Website',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'SCORE:',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreBar(lead.leadScore ?? 0),
              ),
              const SizedBox(width: 12),
              Text(
                '${lead.leadScore ?? 0}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                'Just now',
                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ), // close Container
    ); // close GestureDetector
  }

  Widget _buildScoreBar(int score) {
    // 4 segments
    return Row(
      children: List.generate(4, (index) {
        bool isActive = score > (index * 25);
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  IconData _getSourceIcon(String source) {
    if (source.contains('LinkedIn')) return Icons.link;
    if (source.contains('Email')) return Icons.email;
    if (source.contains('Referral')) return Icons.share;
    return Icons.language;
  }

  Widget _buildAccountCard(AccountModel account) {
    return GestureDetector(
      onTap: () => Get.toNamed('/account-details', arguments: account),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.business, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.accountName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.industry ?? 'General Industry',
                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (account.accountType != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      account.accountType!.toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  account.phone ?? '-',
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 13),
                ),
                const Spacer(),
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  account.billingCity ?? '-',
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

