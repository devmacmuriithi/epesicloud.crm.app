class LiveLocationEntry {
  final int id;
  final int agentId;
  final String? agentName;
  final int? visitId;
  final double latitude;
  final double longitude;
  final String? action;
  final String? outletName;
  final DateTime? createdAt;

  LiveLocationEntry({
    required this.id,
    required this.agentId,
    this.agentName,
    this.visitId,
    required this.latitude,
    required this.longitude,
    this.action,
    this.outletName,
    this.createdAt,
  });

  factory LiveLocationEntry.fromJson(Map<String, dynamic> json) {
    return LiveLocationEntry(
      id: json['id'] ?? 0,
      agentId: json['agentId'] ?? json['agent_id'] ?? 0,
      agentName: json['agentName'] ?? json['agent_name'],
      visitId: json['visitId'] ?? json['visit_id'],
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(json['longitude'] ?? json['lng']),
      action: json['action'],
      outletName: json['outletName'] ?? json['outlet_name'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class AccountMapItem {
  final int id;
  final String accountName;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? city;
  final String? status;

  AccountMapItem({
    required this.id,
    required this.accountName,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.city,
    this.status,
  });

  factory AccountMapItem.fromJson(Map<String, dynamic> json) {
    return AccountMapItem(
      id: json['id'] ?? 0,
      accountName: json['accountName'] ?? json['account_name'] ?? '',
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(json['longitude'] ?? json['lng']),
      phone: json['phone'],
      city: json['city'],
      status: json['status'] == null ? null : (json['status'] == true || json['status'] == 'active' ? 'active' : 'inactive'),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
