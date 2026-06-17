import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sales/daily_route_controller.dart';
import '../../controllers/sales/visits_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/fieldforce_models.dart';
import 'package:intl/intl.dart';

class DailyRouteView extends StatelessWidget {
  const DailyRouteView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DailyRouteController());
    // Ensure VisitsController is available for the FAB unplanned visit modal and checkout
    final visitsController = Get.put(VisitsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.fetchDailyRoute,
        child: Obx(() {
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
                  Text(controller.errorMessage.value,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchDailyRoute,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stops = controller.routeResponse.value?.stops ?? [];
          final unplanned = controller.routeResponse.value?.unplannedVisits ?? [];

          if (stops.isEmpty && unplanned.isEmpty) {
            return _buildEmptyState(context, controller);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStats(controller),
              if (stops.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('STOPS SEQUENCE',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                const SizedBox(height: 16),
                ...stops.map((stop) => _buildStopCard(context, controller, stop)),
              ],
              if (unplanned.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('UNPLANNED VISITS TODAY',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                const SizedBox(height: 16),
                ...unplanned.map((u) => _buildUnplannedVisitCard(context, visitsController, u)),
              ],
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => visitsController.showUnplannedVisitModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Unplanned Visit', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DailyRouteController controller) {
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.route_outlined,
                    size: 52, color: AppColors.primary.withOpacity(0.5)),
              ),
              const SizedBox(height: 24),
              const Text(
                'No route assigned for today',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                today,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your manager has not yet published a route plan for today. Pull down to refresh, or start an unplanned visit below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: controller.fetchDailyRoute,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(DailyRouteController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Planned', controller.totalPlanned.value.toString(), Colors.blue),
          _statItem('Visited', controller.totalVisited.value.toString(), Colors.green),
          _statItem('Missed', controller.totalMissed.value.toString(), Colors.red),
          _statItem('Pending', controller.totalPending.value.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildStopCard(BuildContext context, DailyRouteController controller, RouteStop stop) {
    final isVisited = stop.computedState == 'visited';
    final isPending = stop.computedState == 'planned' || stop.computedState == 'pending' || stop.computedState == null;
    final state = stop.computedState ?? 'planned';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVisited ? Colors.green.withOpacity(0.3) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        onTap: (isVisited && stop.visit != null)
            ? () {
                final visitRecord = VisitRecord(
                  id: stop.visit!.id,
                  accountId: stop.visit!.accountId,
                  accountName: stop.account?['accountName'] ?? 'Unknown',
                  visitStatus: stop.visit!.visitStatus,
                  checkInAt: stop.visit!.checkInAt,
                  checkOutAt: stop.visit!.checkOutAt,
                );
                final visitsController = Get.find<VisitsController>();
                visitsController.goToVisitDetails(visitRecord);
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
          children: [
            Container(
              width: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(state).withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stop.sequenceOrder.toString(),
                      style: TextStyle(
                          color: _getStatusColor(state),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const Icon(Icons.arrow_downward, size: 12, color: Colors.black26),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(stop.account?['accountName'] ?? 'Unknown outlet',
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        _buildStatusBadge(state),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(stop.zone?.name ?? 'No Zone',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => controller.startVisit(stop.accountId, routePlanStopId: stop.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Start Visit'),
                        ),
                      ),
                    ] else if (isVisited && stop.visit != null) ...[
                      const SizedBox(height: 8),
                      Text('Visited at ${DateFormat('HH:mm').format(DateTime.parse(stop.visit!.checkInAt))}',
                          style: const TextStyle(color: Colors.green, fontSize: 12)),
                      if (stop.visit?.visitStatus == 'active') ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              final controller = Get.find<VisitsController>();
                              final visitRecord = VisitRecord(
                                id: stop.visit!.id,
                                accountId: stop.visit!.accountId,
                                accountName: stop.account?['accountName'] ?? 'Unknown',
                                visitStatus: 'active',
                                checkInAt: stop.visit!.checkInAt,
                              );
                              controller.showCheckoutModal(context, visitRecord);
                            },
                            icon: const Icon(Icons.logout_rounded, size: 14),
                            label: const Text('Check Out Now'),
                            style: TextButton.styleFrom(foregroundColor: Colors.green),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildUnplannedVisitCard(BuildContext context, VisitsController visitsController, UnplannedVisit u) {
    return InkWell(
      onTap: () {
        final visitRecord = VisitRecord(
          id: u.id,
          accountId: u.accountId,
          accountName: 'Unplanned Visit', 
          visitStatus: 'completed',
          checkInAt: u.checkInAt,
        );
        visitsController.goToVisitDetails(visitRecord);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.stars, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Unplanned Visit', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  Text('Started at ${DateFormat('HH:mm').format(DateTime.parse(u.checkInAt))}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String state) {
    switch (state.toLowerCase()) {
      case 'visited': return Colors.green;
      case 'missed': return Colors.red;
      case 'planned':
      case 'pending': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String state) {
    final color = _getStatusColor(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(state.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
