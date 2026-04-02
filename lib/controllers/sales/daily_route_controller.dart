import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/fieldforce_models.dart';
import '../../Services/fieldforce_service.dart';

class DailyRouteController extends GetxController {
  final FieldforceService _service = Get.put(FieldforceService());
  
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var routeResponse = Rxn<DailyRouteResponse>();
  
  var totalPlanned = 0.obs;
  var totalVisited = 0.obs;
  var totalMissed = 0.obs;
  var totalPending = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDailyRoute();
  }

  Future<void> fetchDailyRoute() async {
    try {
      isLoading(true);
      hasError(false);
      var response = await _service.getDailyRoute();
      routeResponse.value = response;
      _calculateStats(response);
    } catch (e) {
      hasError(true);
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  void _calculateStats(DailyRouteResponse response) {
    totalPlanned.value = response.stops.length;
    totalVisited.value = response.stops.where((s) => s.computedState == 'visited' || s.visit != null).length;
    totalMissed.value = response.stops.where((s) => s.computedState == 'missed').length;
    totalPending.value = totalPlanned.value - totalVisited.value - totalMissed.value;
  }

  Future<void> startVisit(int accountId, {int? routePlanStopId}) async {
    try {
      Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final request = StartVisitRequest(
        accountId: accountId,
        routePlanStopId: routePlanStopId,
      );
      
      await _service.startVisit(request);
      Get.back(); // Close loading dialog
      Get.snackbar('Visit Active', 'Visit successfully started', 
          backgroundColor: Colors.green, colorText: Colors.white);
      
      fetchDailyRoute();
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', e.toString(), 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
