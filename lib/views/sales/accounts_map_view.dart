import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/sales/map_controller.dart' as crm_map;
import '../../models/location_models.dart';
import '../../utils/app_colors.dart';

class AccountsMapView extends StatefulWidget {
  const AccountsMapView({super.key});

  @override
  State<AccountsMapView> createState() => _AccountsMapViewState();
}

class _AccountsMapViewState extends State<AccountsMapView> {
  late final crm_map.CrmMapController _mapCtrl;
  final _flutterMapCtrl = MapController();
  AccountMapItem? _selected;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _mapCtrl = Get.find<crm_map.CrmMapController>();
    _mapCtrl.fetchAccountPins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: const Text(
          'Accounts Map',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() => _mapCtrl.isLoadingAccounts.value
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: _mapCtrl.fetchAccountPins,
                  tooltip: 'Refresh',
                )),
        ],
      ),
      body: Obx(() {
        final pins = _mapCtrl.accountPins
            .where((a) => _search.isEmpty || a.accountName.toLowerCase().contains(_search.toLowerCase()))
            .toList();
        final error = _mapCtrl.accountsError.value;

        if (error.isNotEmpty && _mapCtrl.accountPins.isEmpty) {
          return _buildError(error, _mapCtrl.fetchAccountPins);
        }

        final validPins = pins.where((a) => a.latitude != 0 && a.longitude != 0).toList();

        final centre = validPins.isNotEmpty
            ? LatLng(validPins.first.latitude, validPins.first.longitude)
            : const LatLng(-1.2921, 36.8219);

        return Stack(
          children: [
            FlutterMap(
              mapController: _flutterMapCtrl,
              options: MapOptions(
                initialCenter: centre,
                initialZoom: validPins.length == 1 ? 14.0 : 10.0,
                onTap: (_, __) => setState(() => _selected = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.epesicloud.crm',
                ),
                MarkerLayer(
                  markers: validPins.map((a) => _buildAccountMarker(a)).toList(),
                ),
              ],
            ),
            // Search bar overlay
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: const InputDecoration(
                    hintText: 'Search accounts...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            // Pin count badge
            Positioned(
              top: 72,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(
                  '${validPins.length} outlet${validPins.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_selected != null) _buildInfoCard(_selected!),
            if (validPins.isEmpty && !_mapCtrl.isLoadingAccounts.value)
              _buildEmptyOverlay(),
          ],
        );
      }),
    );
  }

  Marker _buildAccountMarker(AccountMapItem a) {
    return Marker(
      point: LatLng(a.latitude, a.longitude),
      width: 110,
      height: 52,
      child: GestureDetector(
        onTap: () => setState(() => _selected = a),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3, offset: const Offset(0, 1))],
              ),
              child: Text(
                a.accountName,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.store, color: AppColors.success, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(AccountMapItem a) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, color: AppColors.success, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.accountName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (a.city != null)
                        Text(a.city!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selected = null),
                  child: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (a.phone != null) ...[
                  _infoChip(Icons.phone, a.phone!),
                  const SizedBox(width: 8),
                ],
                _infoChip(
                  Icons.circle,
                  a.status ?? 'active',
                  color: a.status == 'inactive' ? AppColors.danger : AppColors.success,
                ),
                const SizedBox(width: 8),
                _infoChip(
                  Icons.location_on,
                  '${a.latitude.toStringAsFixed(4)}, ${a.longitude.toStringAsFixed(4)}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed('/account-details', arguments: a.id),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View Account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color ?? AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmptyOverlay() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_mall_directory_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('No outlets with GPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Accounts will appear on the map once their coordinates are set.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
