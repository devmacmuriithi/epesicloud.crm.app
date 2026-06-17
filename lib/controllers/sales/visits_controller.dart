import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/fieldforce_models.dart';
import '../../models/crm_models.dart';
import '../../Services/fieldforce_service.dart';
import '../../Services/crm_service.dart';
import '../../views/sales/visit_details_view.dart';
import 'map_controller.dart';

class VisitsController extends GetxController {
  final FieldforceService _service = Get.find<FieldforceService>();
  final CrmService _crmService = Get.find<CrmService>();
  final _storage = GetStorage();

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var visits = <VisitRecord>[].obs;

  // Visit details
  var currentVisit = Rxn<VisitRecord>();
  var workspaceOrders = <VisitOrder>[].obs;
  var workspaceCompetitorRates = <CompetitorRate>[].obs;
  var workspaceOutletRates = <OutletRate>[].obs;
  var workspaceStockAvailability = <StockAvailability>[].obs;
  var workspaceShelfPlacements = <ShelfPlacement>[].obs;
  var workspacePromotionAudits = <PromotionAudit>[].obs;
  var workspaceComplaints = <Complaint>[].obs;
  var workspacePhotos = <VisitPhoto>[].obs;

  var isLoadingOrders = false.obs;
  var isLoadingCompetitorRates = false.obs;
  var isLoadingOutletRates = false.obs;
  var isLoadingComplaints = false.obs;
  var isLoadingPhotos = false.obs;
  var isLoadingStockAvailability = false.obs;
  var isLoadingShelfPlacements = false.obs;
  var isLoadingPromotionAudits = false.obs;

  var products = <ProductModel>[].obs;
  var competitors = <LookupModel>[].obs;
  var complaintTypes = <LookupModel>[].obs;

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
    fetchVisits();
  }

  CrmMapController get _mapCtrl => Get.find<CrmMapController>();

  void _notifyCheckIn(int visitId) {
    _mapCtrl.activeVisitId = visitId;
    _mapCtrl.sendLocationPing(visitId: visitId, action: 'Check in');
  }

  void _notifyCheckOut(int visitId) {
    _mapCtrl.sendLocationPing(visitId: visitId, action: 'Checkout');
    _mapCtrl.activeVisitId = null;
  }

  Future<void> fetchVisits() async {
    try {
      isLoading(true);
      hasError(false);
      final fetchedVisits = await _service.getVisits();
      visits.value = fetchedVisits;
    } catch (e) {
      hasError(true);
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  Future<void> startUnplannedVisit(int accountId) async {
    try {
      final agentId = _agentId;
      if (agentId == 0) {
        Get.snackbar('Error', 'Cannot resolve agent ID');
        return;
      }
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final request = StartVisitRequest(
        accountId: accountId,
        agentId: agentId,
      );
      
      await _service.startVisit(request);
      Get.back();
      Get.snackbar('Visit Active', 'Unplanned visit successfully started');
      
      fetchVisits();
    } catch (e) {
      Get.back();
      Get.snackbar('Error', e.toString());
    }
  }

  void goToVisitDetails(VisitRecord visit) {
    currentVisit.value = visit;
    if (visit.visitStatus == 'active' || visit.visitStatus == 'checked_in') {
      _notifyCheckIn(visit.id);
    }
    Get.to(() => VisitDetailsView(visit: visit));
  }

  void showUnplannedVisitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UnplannedVisitSheet(controller: this),
    );
  }

  void _showSaving(String message) {
    // No-op: saving snackbars removed in favour of showing only the result.
  }

  void _showSaved(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
      backgroundColor: const Color(0xFF2E7D32),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }

  void _showSaveError(String message) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13))),
        ],
      ),
      backgroundColor: const Color(0xFFC62828),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }

  void showCheckoutModal(BuildContext context, VisitRecord visit) {
    Get.defaultDialog(
      title: 'Checkout',
      middleText: 'Are you sure you want to end this visit?',
      onConfirm: () async {
        Get.back();
        _showSaving('Checking out, please wait...');
        try {
          await _service.checkOutVisit(visit.id);
          _notifyCheckOut(visit.id);
          _showSaved('Visit ended successfully');
          fetchVisits();
        } catch (e) {
          _showSaveError(e.toString());
        }
      },
      textCancel: 'Cancel'
    );
  }

  Future<void> fetchVisitWorkspace(int visitId) async {
    refreshTab(visitId, 0);
    refreshTab(visitId, 1);
    refreshTab(visitId, 2);
    refreshTab(visitId, 3);
    refreshTab(visitId, 4);
    refreshTab(visitId, 5);
    refreshTab(visitId, 6);
    refreshTab(visitId, 7);
  }

  Future<void> refreshTab(int visitId, int tabIndex) async {
    try {
      switch (tabIndex) {
        case 0:
          isLoadingOrders(true);
          workspaceOrders.value = await _service.getVisitOrders(visitId);
          isLoadingOrders(false);
          break;
        case 1:
          isLoadingCompetitorRates(true);
          workspaceCompetitorRates.value = await _service.getVisitCompetitorRates(visitId);
          isLoadingCompetitorRates(false);
          break;
        case 2:
          isLoadingOutletRates(true);
          workspaceOutletRates.value = await _service.getVisitOutletRates(visitId);
          isLoadingOutletRates(false);
          break;
        case 3:
          isLoadingStockAvailability(true);
          workspaceStockAvailability.value = await _service.getStockAvailability(visitId);
          isLoadingStockAvailability(false);
          break;
        case 4:
          isLoadingShelfPlacements(true);
          workspaceShelfPlacements.value = await _service.getShelfPlacements(visitId);
          isLoadingShelfPlacements(false);
          break;
        case 5:
          isLoadingPromotionAudits(true);
          workspacePromotionAudits.value = await _service.getPromotionAudits(visitId);
          isLoadingPromotionAudits(false);
          break;
        case 6:
          isLoadingComplaints(true);
          workspaceComplaints.value = await _service.getVisitComplaints(visitId);
          isLoadingComplaints(false);
          break;
        case 7:
          isLoadingPhotos(true);
          workspacePhotos.value = await _service.getVisitPhotos(visitId);
          isLoadingPhotos(false);
          break;
      }
    } catch (e) {
      Get.snackbar('Refresh Error', e.toString());
    }
  }

  Future<void> loadProducts() async {
    if (products.isEmpty) {
      try {
        products.value = await _crmService.getProducts();
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> loadCompetitors() async {
    if (competitors.isEmpty) {
      try {
        competitors.value = await _crmService.getCompetitors();
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> loadComplaintTypes() async {
    if (complaintTypes.isEmpty) {
      try {
        complaintTypes.value = await _crmService.getComplaintTypes();
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> addVisitOrder(int visitId, Map<String, dynamic> data) async {
    _showSaving('Saving order...');
    try {
      final res = await _service.addVisitOrder(visitId, data);
      workspaceOrders.add(res);
      _showSaved('Order saved successfully');
    } catch (e) {
      _showSaveError(e.toString());
    }
  }

  Future<void> addCompetitorRate(int visitId, Map<String, dynamic> data) async {
    _showSaving('Saving competitor rate...');
    try {
      final res = await _service.addCompetitorRate(visitId, data);
      workspaceCompetitorRates.add(res);
      _showSaved('Competitor rate saved');
    } catch (e) {
      _showSaveError(e.toString());
    }
  }

  Future<String?> captureAndUploadPhoto(int visitId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      }
    } catch (e) {
      Get.snackbar('Camera Error', e.toString());
    }
    return null;
  }

  Future<void> addOutletRate(int visitId, Map<String, dynamic> data) async {
    _showSaving('Saving outlet rate...');
    try {
      final res = await _service.addOutletRate(visitId, data);
      workspaceOutletRates.add(res);
      _showSaved('Outlet rate saved');
    } catch (e) {
      _showSaveError(e.toString());
    }
  }

  Future<void> addComplaint(int visitId, Map<String, dynamic> data) async {
    _showSaving('Saving complaint...');
    try {
      final res = await _service.addComplaint(visitId, data);
      workspaceComplaints.add(res);
      _showSaved('Complaint recorded successfully');
    } catch (e) {
      _showSaveError(e.toString());
    }
  }

  Future<void> addVisitPhoto(int visitId, String photoUrl, String caption) async {
    _showSaving('Uploading photo...');
    try {
      final res = await _service.addVisitPhoto(visitId, {'photoUrl': photoUrl, 'notes': caption});
      workspacePhotos.add(res);
      _showSaved('Photo uploaded successfully');
    } catch (e) {
      _showSaveError(e.toString());
    }
  }

  Future<void> addStockAvailability(int visitId, Map<String, dynamic> data) async {
    _showSaving('Saving stock data...');
    try {
      final res = await _service.addStockAvailability(visitId, data);
      workspaceStockAvailability.add(res);
      _showSaved('Stock availability saved');
    } catch (e) {
      _showSaveError(e.toString());
    }
  }

  Future<void> addShelfPlacement(int visitId, Map<String, dynamic> data) async {
    _showSaving('Saving shelf placement...');
    try {
      final res = await _service.addShelfPlacement(visitId, data);
      workspaceShelfPlacements.add(res);
      _showSaved('Shelf placement saved');
    } catch (e) {
      _showSaveError(e.toString());
    }
  }

  Future<void> addPromotionAudit(int visitId, Map<String, dynamic> data) async {
    _showSaving('Saving promotion audit...');
    try {
      final res = await _service.addPromotionAudit(visitId, data);
      workspacePromotionAudits.add(res);
      _showSaved('Promotion audit saved');
    } catch (e) {
      _showSaveError(e.toString());
    }
  }
}

// ── Unplanned Visit Account Picker ────────────────────────────────────────
class _UnplannedVisitSheet extends StatefulWidget {
  final VisitsController controller;
  const _UnplannedVisitSheet({required this.controller});

  @override
  State<_UnplannedVisitSheet> createState() => _UnplannedVisitSheetState();
}

class _UnplannedVisitSheetState extends State<_UnplannedVisitSheet> {
  final _searchController = TextEditingController();
  List<AccountModel> _all = [];
  List<AccountModel> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAccounts() async {
    try {
      final crmService = Get.find<CrmService>();
      final accounts = await crmService.getAccounts();
      if (mounted) {
        setState(() {
          _all = accounts;
          _filtered = accounts;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((a) => a.accountName.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        children: [
          // Handle
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              const Icon(Icons.add_location_alt, color: Color(0xFF1976D2), size: 24),
              const SizedBox(width: 10),
              const Expanded(child: Text('Start Unplanned Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 12),
          // Search
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search accounts...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No accounts found', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final account = _filtered[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                              child: Text(
                                account.accountName.isNotEmpty ? account.accountName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(account.accountName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: account.industry != null ? Text(account.industry!, style: const TextStyle(fontSize: 12)) : null,
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.controller.startUnplannedVisit(account.id);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
