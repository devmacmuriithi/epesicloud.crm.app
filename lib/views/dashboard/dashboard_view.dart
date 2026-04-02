import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/app_navigator_controller.dart';
import '../../utils/app_colors.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchStats(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserHeader(controller),
                      const SizedBox(height: 24),
                      _buildStatsGrid(controller),
                      const SizedBox(height: 32),
                      _buildRecentActivityHeader(controller),
                      const SizedBox(height: 16),
                      _buildActivityList(controller),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(DashboardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Obx(() => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.support_agent, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Epesicloud Crm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          if (controller.isSearchExpanded.value)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                height: 36,
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => controller.isSearchExpanded.value = false,
                    ),
                  ),
                ),
              ),
            )
          else ...[
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textSecondary),
              onPressed: () => controller.isSearchExpanded.value = true,
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary),
                  onPressed: () {
                    // Navigate to NotificationsView
                    Get.toNamed('/notifications');
                  },
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
        ],
      )),
    );
  }

  Widget _buildUserHeader(DashboardController controller) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex'),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                'Good morning, ${controller.userName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(height: 4),
              Text(
                'Your pipeline is looking strong today.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'PIPELINE VALUE',
                  value: controller.pipelineValue.value,
                  trend: '+12%',
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.handshake_outlined,
                  label: 'ACTIVE DEALS',
                  value: controller.activeDeals.value.toString(),
                  trend: '+4',
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.bar_chart_rounded,
                  label: 'WIN RATE',
                  value: controller.winRate.value,
                  trend: '+2%',
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.person_add_outlined,
                  label: 'NEW LEADS',
                  value: controller.newLeads.value.toString(),
                  badge: 'New',
                  iconColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.business,
                  label: 'TOTAL ACCOUNTS',
                  value: controller.totalAccounts.value.toString(),
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_alt_outlined,
                  label: 'TOTAL CONTACTS',
                  value: controller.totalContacts.value.toString(),
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.history,
                  label: 'ACTIVITIES THIS WEEK',
                  value: controller.activitiesThisWeek.value.toString(),
                  iconColor: AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.payments_outlined,
                  label: 'PAYMENTS THIS MONTH',
                  value: controller.paymentsThisMonth.value,
                  iconColor: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    String? trend,
    String? badge,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(DashboardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            final nav = Get.find<AppNavigatorController>();
            nav.changeTabIndex(3); // Switch to Activities tab
          },
          child: const Text('View All', style: TextStyle(color: AppColors.success)),
        ),
      ],
    );
  }

  Widget _buildActivityList(DashboardController controller) {
    return Obx(() {
      if (controller.activities.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Text('No recent activities', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5))),
              ],
            ),
          ),
        );
      }

      return Column(
        children: controller.activities.map((a) {
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

          return _buildActivityItem(
            type: a.type,
            title: a.subject,
            subtitle: a.description ?? a.type,
            time: a.dueDate ?? 'RECENT',
          );
        }).toList(),
      );
    });
  }

  Widget _buildActivityItem({
    required String type,
    required String title,
    required String subtitle,
    required String time,
  }) {
    Color activityColor = AppColors.primary;
    if (type.toLowerCase().contains('call')) {
      activityColor = AppColors.success;
    } else if (type.toLowerCase().contains('email')) {
      activityColor = const Color(0xFF3B82F6);
    } else if (type.toLowerCase().contains('sms') || type.toLowerCase().contains('message')) {
      activityColor = const Color(0xFF06B6D4);
    }

    return InkWell(
      onTap: () => Get.toNamed('/activity-details'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activityColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type.toUpperCase(),
                style: TextStyle(
                  color: activityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
