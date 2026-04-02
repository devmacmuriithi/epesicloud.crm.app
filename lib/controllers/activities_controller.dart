import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import '../models/crm_models.dart';
import '../Services/crm_service.dart';

class ActivitiesController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();
  
  final allActivities = <ActivityModel>[].obs;
  final activities = <ActivityModel>[].obs; // This will show the filtered list
  final isLoading = false.obs;

  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;

  final List<String> filters = ['All', 'Call', 'Meeting', 'Task', 'Email', 'SMS'];

  @override
  void onInit() {
    super.onInit();
    fetchActivities();
    
    // Listen to filter/search changes
    ever(selectedFilter, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
  }

  Future<void> fetchActivities() async {
    isLoading.value = true;
    try {
      final fetched = await _crmService.getActivities();
      allActivities.assignAll(fetched);
      _applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch activities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void _applyFilters() {
    List<ActivityModel> filtered = allActivities;

    // 1. Category Filter (Activity Type)
    if (selectedFilter.value != 'All') {
      final category = selectedFilter.value.toLowerCase();
      filtered = filtered.where((a) => a.type.toLowerCase().contains(category)).toList();
    }

    // 2. Search Query Filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((a) => 
        a.subject.toLowerCase().contains(query) ||
        a.type.toLowerCase().contains(query) ||
        (a.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    activities.assignAll(filtered);
  }

  void filterActivities(String query) {
    searchQuery.value = query;
  }

  Color getStatusColor(String status) {
    status = status.toUpperCase();
    if (status.contains('PROGRESS') || status.contains('IN_PROGRESS')) return const Color(0xFF60A5FA);
    if (status.contains('COMPLETED') || status.contains('DONE')) return AppColors.success;
    if (status.contains('NOT STARTED') || status.contains('PLANNED') || status.contains('PLANNING')) return AppColors.warning;
    return AppColors.textSecondary;
  }

  IconData getTypeIcon(String type) {
    type = type.toLowerCase();
    if (type.contains('call')) return Icons.call;
    if (type.contains('meeting')) return Icons.people_alt;
    if (type.contains('email')) return Icons.email;
    return Icons.event_note;
  }
}
