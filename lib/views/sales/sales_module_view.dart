import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../deals/deals_view.dart';
import 'daily_route_view.dart';
import 'visits_view.dart';
import '../../utils/app_colors.dart';
import '../../controllers/app_navigator_controller.dart';

class SalesModuleView extends StatefulWidget {
  const SalesModuleView({Key? key}) : super(key: key);

  @override
  State<SalesModuleView> createState() => _SalesModuleViewState();
}

class _SalesModuleViewState extends State<SalesModuleView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final nav = Get.find<AppNavigatorController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: nav.salesTabIndex.value,
    );

    // Sync tab changes from navigator
    ever(nav.salesTabIndex, (int index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });

    // Sync tab changes back to navigator (optional, but good for consistency)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        nav.salesTabIndex.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: const Text(
          'Sales',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Deals'),
            Tab(text: 'Visits'),
            Tab(text: 'Daily Route'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DealsView(isEmbedded: true),
          VisitsView(),
          DailyRouteView(),
        ],
      ),
    );
  }
}
