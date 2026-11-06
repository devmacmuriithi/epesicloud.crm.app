import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'activity_action_bottom_sheet.dart';
import '../views/activities/modals/note_modal.dart';

class CardInteractionButtons extends StatelessWidget {
  final String entityType; // 'deal', 'lead', 'account'
  final int entityId;
  final String entityName;
  final String? phone;
  final String? email;
  final VoidCallback? onActivityLogged;

  const CardInteractionButtons({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    this.phone,
    this.email,
    this.onActivityLogged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.call,
          tooltip: 'Call',
          color: AppColors.success,
          onTap: () => _handleCall(context),
        ),
        const SizedBox(width: 8),
        _buildButton(
          icon: Icons.textsms_outlined,
          tooltip: 'SMS',
          color: const Color(0xFFF59E0B),
          onTap: () => _handleSms(context),
        ),
        const SizedBox(width: 8),
        _buildButton(
          icon: Icons.note_add_outlined,
          tooltip: 'Note',
          color: AppColors.primary,
          onTap: () => _handleNote(context),
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  void _handleCall(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ActivityActionBottomSheet(
        actionType: 'call',
        entityType: entityType,
        entityId: entityId,
        entityName: entityName,
        phone: phone,
        email: email,
        onActivityLogged: onActivityLogged,
      ),
    );
  }

  void _handleSms(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ActivityActionBottomSheet(
        actionType: 'sms',
        entityType: entityType,
        entityId: entityId,
        entityName: entityName,
        phone: phone,
        email: email,
        onActivityLogged: onActivityLogged,
      ),
    );
  }

  void _handleNote(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteModal(
        initialEntityType: entityType,
        initialEntityId: entityId,
      ),
    );
    if (result == true && onActivityLogged != null) {
      onActivityLogged!();
    }
  }
}
