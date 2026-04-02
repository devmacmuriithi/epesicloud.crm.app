import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Services/crm_service.dart';
import '../Services/auth_service.dart';
import '../models/crm_models.dart';


class DashboardController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();
  final AuthService _authService = Get.find<AuthService>();
  
  var selectedIndex = 0.obs;
  var isLoading = false.obs;

  // Stats data
  final pipelineValue = "Kes 0".obs;
  final activeDeals = 0.obs;
  final winRate = "0%".obs;
  final newLeads = 0.obs;
  final totalAccounts = 0.obs;
  final totalContacts = 0.obs;
  final activitiesThisWeek = 0.obs;
  final paymentsThisMonth = "Kes 0".obs;
  final activities = <ActivityModel>[].obs;

  String get userName => _authService.currentUser.value?.email.split('@')[0].capitalizeFirst ?? 'User';

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final stats = await _crmService.getDashboardStats();
      final formatter = NumberFormat.currency(symbol: 'Kes ', decimalDigits: 0);
      
      pipelineValue.value = formatter.format(stats.pipelineValue);
      activeDeals.value = stats.activeDeals;
      winRate.value = "${stats.winRate}%";
      newLeads.value = stats.newLeads;
      totalAccounts.value = stats.totalAccounts;
      totalContacts.value = stats.totalContacts;
      activitiesThisWeek.value = stats.activitiesThisWeek;
      paymentsThisMonth.value = formatter.format(stats.paymentsThisMonth);

      // Fetch recent activities
      final allActivities = await _crmService.getActivities();
      // Sort by due date (or created date if available) - assuming most recent first
      activities.value = allActivities.take(5).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch dashboard stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (index == 1) {
      Get.toNamed('/leads');
    }
  }

  final isSearchExpanded = false.obs;
}
