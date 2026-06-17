import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/fieldforce_models.dart';
import '../../Services/fieldforce_service.dart';

class DailyRouteController extends GetxController {
  final FieldforceService _service = Get.find<FieldforceService>();
  final _storage = GetStorage();

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var routeResponse = Rxn<DailyRouteResponse>();

  var totalPlanned = 0.obs;
  var totalVisited = 0.obs;
  var totalMissed = 0.obs;
  var totalPending = 0.obs;

  int get _agentId {
    final userData = _storage.read('user_data');
    if (userData is Map) {
      final id = userData['userId'] ?? userData['id'];
      return int.tryParse(id?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    fetchDailyRoute();
  }

  Future<void> fetchDailyRoute() async {
    try {
      isLoading(true);
      hasError(false);
      final response = await _service.getDailyRoute();
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

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> startVisit(int accountId, {int? routePlanStopId}) async {
    try {
      Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final agentId = _agentId;
      if (agentId == 0) {
        Get.back();
        Get.snackbar('Error', 'Cannot resolve agent ID. Please re-login.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final position = await _getLocation();

      final request = StartVisitRequest(
        accountId: accountId,
        agentId: agentId,
        routePlanStopId: routePlanStopId,
        checkInLatitude: position?.latitude,
        checkInLongitude: position?.longitude,
      );

      await _service.startVisit(request);
      Get.back();
      Get.snackbar('Visit Active', 'Visit successfully started',
          backgroundColor: Colors.green, colorText: Colors.white);
      fetchDailyRoute();
    } catch (e) {
      Get.back();
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
