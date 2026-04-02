import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../deals/deals_view.dart';
import 'daily_route_view.dart';
import 'visits_view.dart';
import '../../utils/app_colors.dart';

class SalesModuleView extends StatelessWidget {
  const SalesModuleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1, // Default is Daily Route
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0.5,
          title: const Text(
            'Sales',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Deals'),
              Tab(text: 'Daily Route'),
              Tab(text: 'Visits'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DealsView(isEmbedded: true), // Pass a flag if needed so it doesn't render its own inner Scaffold/AppBar aggressively
            DailyRouteView(),
            VisitsView(),
          ],
        ),
      ),
    );
  }
}
