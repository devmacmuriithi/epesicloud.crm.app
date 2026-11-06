import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sales/visits_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/fieldforce_models.dart';
import 'package:intl/intl.dart';

class VisitsView extends StatelessWidget {
  const VisitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisitsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.fetchVisits,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(controller.errorMessage.value,
                            style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.fetchVisits,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (controller.visits.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_outlined, color: Colors.black26, size: 64),
                        SizedBox(height: 16),
                        Text('No visits recorded yet',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.visits.length,
            itemBuilder: (context, index) {
              final visit = controller.visits[index];
              return InkWell(
                onTap: () => controller.goToVisitDetails(visit),
                borderRadius: BorderRadius.circular(16),
                child: _buildVisitCard(context, controller, visit),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.showUnplannedVisitModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Unplanned Visit', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, VisitsController controller, VisitRecord visit) {
    final checkIn = DateTime.tryParse(visit.checkInAt);
    final checkOut = visit.checkOutAt != null ? DateTime.tryParse(visit.checkOutAt!) : null;
    final isActive = visit.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? Colors.orange.withOpacity(0.3) : AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(visit.accountName,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(visit.visitStatus),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _timeInfo('Check-in', checkIn != null ? DateFormat('HH:mm').format(checkIn) : '--:--'),
              const SizedBox(width: 24),
              _timeInfo('Check-out', checkOut != null ? DateFormat('HH:mm').format(checkOut) : 'In Progress'),
            ],
          ),
          if (visit.notes != null && visit.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(visit.notes!,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
          ],
          if (isActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.showCheckoutModal(context, visit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Check Out'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(time, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
