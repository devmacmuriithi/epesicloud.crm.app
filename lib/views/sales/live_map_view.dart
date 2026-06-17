import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/sales/map_controller.dart' as crm_map;
import '../../models/location_models.dart';
import '../../utils/app_colors.dart';

class LiveMapView extends StatefulWidget {
  const LiveMapView({super.key});

  @override
  State<LiveMapView> createState() => _LiveMapViewState();
}

class _LiveMapViewState extends State<LiveMapView> {
  late final crm_map.CrmMapController _mapCtrl;
  final _flutterMapCtrl = MapController();
  LiveLocationEntry? _selected;

  @override
  void initState() {
    super.initState();
    _mapCtrl = Get.find<crm_map.CrmMapController>();
    _mapCtrl.startLiveMap();
  }

  @override
  void dispose() {
    _mapCtrl.stopLiveMap();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: const Text(
          'Live Agent Map',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() => _mapCtrl.isLoadingLive.value
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
                  onPressed: _mapCtrl.fetchLiveFeed,
                  tooltip: 'Refresh',
                )),
        ],
      ),
      body: Obx(() {
        final feed = _mapCtrl.liveFeed;
        final error = _mapCtrl.liveError.value;

        if (error.isNotEmpty && feed.isEmpty) {
          return _buildError(error, _mapCtrl.fetchLiveFeed);
        }

        // Default centre: Nairobi
        final centre = feed.isNotEmpty
            ? LatLng(feed.first.latitude, feed.first.longitude)
            : const LatLng(-1.2921, 36.8219);

        return Stack(
          children: [
            FlutterMap(
              mapController: _flutterMapCtrl,
              options: MapOptions(
                initialCenter: centre,
                initialZoom: feed.length == 1 ? 14.0 : 10.0,
                onTap: (_, __) => setState(() => _selected = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.epesicloud.crm',
                ),
                MarkerLayer(
                  markers: feed.map((e) => _buildAgentMarker(e)).toList(),
                ),
              ],
            ),
            if (_selected != null) _buildInfoCard(_selected!),
            if (feed.isEmpty && !_mapCtrl.isLoadingLive.value)
              _buildEmptyOverlay(),
          ],
        );
      }),
    );
  }

  Marker _buildAgentMarker(LiveLocationEntry e) {
    return Marker(
      point: LatLng(e.latitude, e.longitude),
      width: 100,
      height: 56,
      child: GestureDetector(
        onTap: () => setState(() => _selected = e),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Text(
                e.agentName ?? 'Agent ${e.agentId}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.location_pin, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(LiveLocationEntry e) {
    final timeAgo = e.createdAt != null ? _formatTimeAgo(e.createdAt!) : 'Unknown time';
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
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.agentName ?? 'Agent ${e.agentId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (e.outletName != null)
                        Text(e.outletName!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                _infoChip(Icons.directions_walk, e.action ?? 'background'),
                const SizedBox(width: 8),
                _infoChip(Icons.access_time, timeAgo),
                if (e.visitId != null) ...[
                  const SizedBox(width: 8),
                  _infoChip(Icons.work_outline, 'Visit #${e.visitId}'),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
            Icon(Icons.location_off, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('No agents online', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Agent locations will appear here once they are active on a visit.',
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

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
