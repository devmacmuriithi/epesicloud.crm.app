import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cases_controller.dart';
import '../../utils/app_colors.dart';
import '../../models/crm_models.dart';

class CaseDetailsView extends StatelessWidget {
  const CaseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final CaseModel supportCase = Get.arguments as CaseModel;
    final controller = Get.find<CasesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            const Text('Case Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('EPESICLOUD CRM • SERVICE DESK', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case ID and Badges
            Row(
              children: [
                Text('#${supportCase.caseNumber}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(width: 12),
                _buildBadge(supportCase.status, controller.getStatusColor(supportCase.status).withOpacity(0.1), controller.getStatusColor(supportCase.status)),
                const SizedBox(width: 8),
                _buildBadge('${supportCase.priority} PRIORITY', Colors.redAccent.withOpacity(0.1), Colors.redAccent, icon: Icons.priority_high),
              ],
            ),
            const SizedBox(height: 16),
            Text(supportCase.title ?? "Untitled Case", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Created: ${supportCase.createdAt?.split('T')[0] ?? "N/A"}', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.support_agent_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Type: ${supportCase.caseOrigin ?? "General"}', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),

            // Origin Info
            _buildInfoTile('ORIGIN', supportCase.caseOrigin ?? 'Unknown', Icons.language_outlined),
            const SizedBox(height: 16),
            
            // Linked Entity
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.link, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LINKED TO', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(supportCase.linkedEntityName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(supportCase.linkedEntityType ?? 'General Case', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Description
            _buildSectionHeader(Icons.description_outlined, 'Description'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                supportCase.description ?? "No further details provided.",
                style: TextStyle(color: AppColors.textPrimary.withOpacity(0.9), fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, color: textColor, size: 12), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
