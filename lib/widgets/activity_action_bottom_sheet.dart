import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../views/activities/modals/log_call_modal.dart';
import '../views/activities/modals/send_sms_modal.dart';
import '../views/activities/modals/send_email_modal.dart';

class ActivityActionBottomSheet extends StatelessWidget {
  final String actionType; // 'call', 'sms', 'email'
  final String? entityType;
  final int? entityId;
  final String? entityName;
  final String? phone;
  final String? email;
  final VoidCallback? onActivityLogged;

  const ActivityActionBottomSheet({
    super.key,
    required this.actionType,
    this.entityType,
    this.entityId,
    this.entityName,
    this.phone,
    this.email,
    this.onActivityLogged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (entityName != null && entityName!.isNotEmpty)
            _buildCustomerDetails(),
          if (entityName != null && entityName!.isNotEmpty)
            const SizedBox(height: 20),
          _buildActionButtons(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    final initial =
        (entityName?.isNotEmpty == true) ? entityName![0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 20,
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
                  entityName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (phone != null && phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(phone!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ],
                if (email != null && email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          email!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (actionType) {
      case 'call':
        return Row(
          children: [
            Expanded(
              child: _sheetButton(
                icon: Icons.phone,
                label: 'Call',
                subtitle: (phone != null && phone!.isNotEmpty) ? phone : null,
                color: AppColors.success,
                onTap: () async {
                  Get.back();
                  if (phone != null && phone!.isNotEmpty) {
                    final clean = phone!.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                    try {
                      await launchUrl(
                        Uri(scheme: 'tel', path: clean),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {
                      Get.snackbar('Error', 'Could not open dialler');
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _sheetButton(
                icon: Icons.note_alt_outlined,
                label: 'Log Call',
                color: AppColors.primary,
                outlined: true,
                onTap: () async {
                  Get.back();
                  await Future.delayed(const Duration(milliseconds: 150));
                  final result = await showModalBottomSheet<bool>(
                    context: Get.context!,
                    isScrollControlled: true,
                    backgroundColor: AppColors.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => LogCallModal(
                      initialEntityType: entityType,
                      initialEntityId: entityId,
                      initialEntityName: entityName,
                    ),
                  );
                  if (result == true && onActivityLogged != null) {
                    onActivityLogged!();
                  }
                },
              ),
            ),
          ],
        );

      case 'sms':
        return Row(
          children: [
            Expanded(
              child: _sheetButton(
                icon: Icons.note_alt_outlined,
                label: 'Log SMS',
                color: Colors.orange,
                outlined: true,
                onTap: () async {
                  Get.back();
                  await Future.delayed(const Duration(milliseconds: 150));
                  final result = await showModalBottomSheet<bool>(
                    context: Get.context!,
                    isScrollControlled: true,
                    backgroundColor: AppColors.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => SendSMSModal(
                      initialEntityType: entityType,
                      initialEntityId: entityId,
                      initialPhone: phone,
                    ),
                  );
                  if (result == true && onActivityLogged != null) {
                    onActivityLogged!();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _sheetButton(
                icon: Icons.send,
                label: 'Log & Send',
                subtitle: (phone != null && phone!.isNotEmpty) ? phone : null,
                color: Colors.orange,
                onTap: () async {
                  Get.back();
                  await Future.delayed(const Duration(milliseconds: 150));
                  final result = await showModalBottomSheet<bool>(
                    context: Get.context!,
                    isScrollControlled: true,
                    backgroundColor: AppColors.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => SendSMSModal(
                      initialEntityType: entityType,
                      initialEntityId: entityId,
                      initialPhone: phone,
                      sendAfterLog: true,
                    ),
                  );
                  if (result == true && onActivityLogged != null) {
                    onActivityLogged!();
                  }
                },
              ),
            ),
          ],
        );

      case 'email':
        return Row(
          children: [
            Expanded(
              child: _sheetButton(
                icon: Icons.note_alt_outlined,
                label: 'Log Email',
                color: AppColors.primary,
                outlined: true,
                onTap: () async {
                  Get.back();
                  await Future.delayed(const Duration(milliseconds: 150));
                  final result = await showModalBottomSheet<bool>(
                    context: Get.context!,
                    isScrollControlled: true,
                    backgroundColor: AppColors.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => SendEmailModal(
                      initialEntityType: entityType,
                      initialEntityId: entityId,
                      initialEmail: email,
                    ),
                  );
                  if (result == true && onActivityLogged != null) {
                    onActivityLogged!();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _sheetButton(
                icon: Icons.send,
                label: 'Log & Send',
                subtitle: (email != null && email!.isNotEmpty) ? email : null,
                color: AppColors.primary,
                onTap: () async {
                  Get.back();
                  await Future.delayed(const Duration(milliseconds: 150));
                  final result = await showModalBottomSheet<bool>(
                    context: Get.context!,
                    isScrollControlled: true,
                    backgroundColor: AppColors.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => SendEmailModal(
                      initialEntityType: entityType,
                      initialEntityId: entityId,
                      initialEmail: email,
                      sendAfterLog: true,
                    ),
                  );
                  if (result == true && onActivityLogged != null) {
                    onActivityLogged!();
                  }
                },
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _sheetButton({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    bool outlined = false,
    required VoidCallback onTap,
  }) {
    final textColor = outlined ? color : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: outlined
                      ? color.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
