import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/fieldforce_models.dart';
import '../../Services/fieldforce_service.dart';

class VisitsController extends GetxController {
  final FieldforceService _service = Get.find<FieldforceService>();
  
  var isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchVisits();
  }

  Future<void> fetchVisits() async {
    // For unplanned visits/historical we would call GET /api/visits
    // Emulate fetch state to remove loading skeleton
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading(false);
  }

  Future<void> startUnplannedVisit(int accountId) async {
    try {
      Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final request = StartVisitRequest(
        accountId: accountId,
        // No routePlanStopId signals an unplanned visit
      );
      
      // Request start
      await _service.startVisit(request);
      Get.back(); // close dialog
      Get.snackbar('Visit Active', 'Unplanned visit successfully started');
      
      fetchVisits();
    } catch (e) {
      Get.back(); // close dialog
      Get.snackbar('Error', e.toString());
    }
  }
}
