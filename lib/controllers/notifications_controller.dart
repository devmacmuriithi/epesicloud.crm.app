import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isRead = false,
  });
}

class NotificationsController extends GetxController {
  final notifications = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyNotifications();
  }

  void _loadDummyNotifications() {
    notifications.addAll([
      NotificationItem(
        title: 'New Lead Assigned',
        message: 'You have been assigned a new lead: Tech Solutions Inc.',
        time: '10 MIN AGO',
        icon: Icons.person_add,
      ),
      NotificationItem(
        title: 'Meeting Reminder',
        message: 'Your meeting with Sarah starts in 30 minutes.',
        time: '1 HOUR AGO',
        icon: Icons.event,
        isRead: true,
      ),
      NotificationItem(
        title: 'Deal Won!',
        message: 'Congratulations! The Cloud Migration deal has been won.',
        time: '2 HOURS AGO',
        icon: Icons.emoji_events,
      ),
      NotificationItem(
        title: 'Task Overdue',
        message: 'Send follow-up email to Acme Corp is overdue.',
        time: 'YESTERDAY',
        icon: Icons.assignment_late,
        isRead: true,
      ),
    ]);
  }

  void markAllAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = NotificationItem(
        title: notifications[i].title,
        message: notifications[i].message,
        time: notifications[i].time,
        icon: notifications[i].icon,
        isRead: true,
      );
    }
  }
}
