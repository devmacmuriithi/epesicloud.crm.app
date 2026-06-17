import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_navigator_controller.dart';
import '../utils/app_colors.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/leads/leads_view.dart';
import '../views/sales/sales_module_view.dart';
import '../views/activities/activities_view.dart';
import '../views/calendar/calendar_view.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppNavigatorController());

    final List<Widget> pages = [
      const DashboardView(),
      const SalesModuleView(),

      const LeadsView(),
      const ActivitiesView(),
      // Index 4 is 'More', handled by bottom sheet
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: (index) {
              if (index == 4) {
                _showMoreBottomSheet(context);
              } else {
                controller.changeTabIndex(index);
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.background,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
                            BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Sales'),

              BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Leads'),
              BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Activities'),
              BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
            ],
          )),
    );
  }

  void _showMoreBottomSheet(BuildContext context) {
    // Implementing the 'More' bottom sheet matching the Image 5 design
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background, // Match the dark background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Epesicloud Crm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildBottomSheetItem(
                    icon: Icons.calendar_today,
                    label: 'Calendar',
                    color: AppColors.primary,
                    onTap: () {
                      Get.back();
                      Get.to(() => const CalendarView());
                    },
                  ),
                  _buildBottomSheetDivider(),
                  _buildBottomSheetItem(
                    icon: Icons.checklist,
                    label: 'Tasks',
                    color: AppColors.textSecondary,
                    onTap: () {
                      Get.back();
                      Get.toNamed('/tasks');
                    },
                  ),
                  _buildBottomSheetDivider(),
                  _buildBottomSheetItem(
                    icon: Icons.work_outline,
                    label: 'Cases',
                    color: AppColors.textSecondary,
                    onTap: () {
                      Get.back();
                      Get.toNamed('/cases');
                    },
                  ),
                  _buildBottomSheetDivider(),
                  _buildBottomSheetItem(
                    icon: Icons.payments_outlined,
                    label: 'Payments',
                    color: AppColors.textSecondary,
                    onTap: () {
                      Get.back();
                      Get.toNamed('/payments');
                    },
                  ),
                  _buildBottomSheetDivider(),
                  _buildBottomSheetItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Products',
                    color: AppColors.textSecondary,
                    onTap: () {
                      Get.back();
                      Get.toNamed('/products');
                    },
                  ),
                  _buildBottomSheetDivider(),
                  _buildBottomSheetItem(
                    icon: Icons.location_on_outlined,
                    label: 'Live Agent Map',
                    color: AppColors.textSecondary,
                    onTap: () {
                      Get.back();
                      Get.toNamed('/live-map');
                    },
                  ),
                  _buildBottomSheetDivider(),
                  _buildBottomSheetItem(
                    icon: Icons.store_mall_directory_outlined,
                    label: 'Accounts Map',
                    color: AppColors.textSecondary,
                    onTap: () {
                      Get.back();
                      Get.toNamed('/accounts-map');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Making background transparent so Container decorations show
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: color == AppColors.primary ? AppColors.primary : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomSheetDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 56, right: 16),
      child: Divider(color: AppColors.divider, height: 1),
    );
  }
}
