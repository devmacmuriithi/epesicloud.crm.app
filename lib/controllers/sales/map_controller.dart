import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/location_models.dart';
import '../../Services/fieldforce_service.dart';

class CrmMapController extends GetxController {
  final FieldforceService _service = Get.find<FieldforceService>();
  final _storage = GetStorage();

  // ── Live Map state ───────────────────────────────────────────────────────
  final liveFeed = <LiveLocationEntry>[].obs;
  final isLoadingLive = false.obs;
  final liveError = ''.obs;
  Timer? _liveRefreshTimer;

  // ── Accounts Map state ───────────────────────────────────────────────────
  final accountPins = <AccountMapItem>[].obs;
  final isLoadingAccounts = false.obs;
  final accountsError = ''.obs;

  // ── Background location ping (always-on, 10-minute interval) ─────────────
  Timer? _bgPingTimer;
  int? activeVisitId;

  int get _agentId {
    final userData = _storage.read('user_data');
    if (userData is Map) {
      final id = userData['userId'] ?? userData['id'];
      return int.tryParse(id?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  String? get _agentName {
    final userData = _storage.read('user_data');
    if (userData is Map) {
      final name = userData['name']?.toString();
      if (name != null && name.isNotEmpty) return name;
      final first = userData['firstName']?.toString() ?? '';
      final last = userData['lastName']?.toString() ?? '';
      final full = '$first $last'.trim();
      if (full.isNotEmpty) return full;
      final email = userData['email']?.toString() ?? '';
      return email.isNotEmpty ? email.split('@').first : null;
    }
    return null;
  }

  bool get _isLoggedIn => _storage.read('access_token') != null;

  @override
  void onInit() {
    super.onInit();
    _startBackgroundPingTimer();
    // Fire one ping immediately so location permission is requested at startup
    Future.delayed(const Duration(seconds: 3), _fireBackgroundPing);
  }

  // ── Background ping ───────────────────────────────────────────────────────

  void _startBackgroundPingTimer() {
    _bgPingTimer?.cancel();
    _bgPingTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _fireBackgroundPing(),
    );
  }

  void _fireBackgroundPing() {
    if (!_isLoggedIn) return;
    sendLocationPing(visitId: activeVisitId, action: 'background');
  }

  // ── Live Map ─────────────────────────────────────────────────────────────

  void startLiveMap() {
    fetchLiveFeed();
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => fetchLiveFeed(),
    );
  }

  void stopLiveMap() {
    _liveRefreshTimer?.cancel();
    _liveRefreshTimer = null;
  }

  Future<void> fetchLiveFeed() async {
    isLoadingLive(true);
    liveError('');
    try {
      liveFeed.value = await _service.getLiveLocationFeed();
    } catch (e) {
      liveError(e.toString());
    } finally {
      isLoadingLive(false);
    }
  }

  // ── Accounts Map ─────────────────────────────────────────────────────────

  Future<void> fetchAccountPins() async {
    isLoadingAccounts(true);
    accountsError('');
    try {
      accountPins.value = await _service.getAccountsMap();
    } catch (e) {
      accountsError(e.toString());
    } finally {
      isLoadingAccounts(false);
    }
  }

  // ── Location ping (also called directly for action events) ───────────────

  Future<void> sendLocationPing({int? visitId, String action = 'background'}) async {
    if (!_isLoggedIn) return;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 15));

      final agentId = _agentId;
      if (agentId == 0) return;

      final payload = <String, dynamic>{
        'agentId': agentId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'action': action,
        if (visitId != null) 'visitId': visitId,
      };

      await _service.postLocationPing(payload);
    } catch (_) {
      // Silent — pings are best-effort, never surface errors to user
    }
  }

  @override
  void onClose() {
    _bgPingTimer?.cancel();
    _liveRefreshTimer?.cancel();
    super.onClose();
  }
}
