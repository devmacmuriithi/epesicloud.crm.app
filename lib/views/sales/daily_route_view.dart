import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sales/daily_route_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/fieldforce_models.dart';

class DailyRouteView extends StatelessWidget {
  const DailyRouteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DailyRouteController controller = Get.put(DailyRouteController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error fetching route: ${controller.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchDailyRoute,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Retry'),
                )
              ],
            ),
          );
        }

        final plan = controller.routeResponse.value?.plan;
        if (plan == null) {
          return const Center(
            child: Text('No daily route planned for today.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          );
        }

        final stops = controller.routeResponse.value?.stops ?? [];
        return RefreshIndicator(
          onRefresh: controller.fetchDailyRoute,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSummaryCards(controller),
              const SizedBox(height: 24),
              Text(
                'Route Sequence - ${stops.length} Stops',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              ...stops.map((stop) => _buildStopCard(stop, controller)).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards(DailyRouteController controller) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Planned', controller.totalPlanned.value, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Visited', controller.totalVisited.value, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Missed', controller.totalMissed.value, Colors.red)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Pending', controller.totalPending.value, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStopCard(RouteStop stop, DailyRouteController controller) {
    final bool isVisited = stop.computedState == 'visited' || stop.visit != null;
    final String accountName = stop.account?['accountName'] ?? 'Unknown Account';
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isVisited ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${stop.sequenceOrder}',
                  style: TextStyle(
                    color: isVisited ? Colors.green : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: stop.isMandatory ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stop.isMandatory ? 'Mandatory' : 'Optional',
                          style: TextStyle(
                            fontSize: 10,
                            color: stop.isMandatory ? Colors.red : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stop.status.toUpperCase(),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                if (isVisited) {
                  // Wait, open existing visit flow.
                  // For now we'll just show a snackbar or navigate to visit workspace
                  Get.snackbar('Navigate', 'Opening visit workspace...');
                } else {
                  controller.startVisit(stop.accountId, routePlanStopId: stop.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isVisited ? AppColors.surface : AppColors.primary,
                foregroundColor: isVisited ? AppColors.primary : Colors.white,
                elevation: 0,
                side: isVisited ? const BorderSide(color: AppColors.primary) : null,
              ),
              child: Text(isVisited ? 'Open Visit' : 'Start Visit'),
            ),
          ],
        ),
      ),
    );
  }
}
