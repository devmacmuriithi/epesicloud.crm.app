class RoutePlan {
  final int id;
  final String? tenantId;
  final String title;
  final int agentId;
  final int? zoneId;
  final String routeDate;
  final String status;

  RoutePlan({
    required this.id,
    this.tenantId,
    required this.title,
    required this.agentId,
    this.zoneId,
    required this.routeDate,
    required this.status,
  });

  factory RoutePlan.fromJson(Map<String, dynamic> json) {
    return RoutePlan(
      id: json['id'],
      tenantId: json['tenantId'],
      title: json['title'] ?? '',
      agentId: json['agentId'] ?? 0,
      zoneId: json['zoneId'],
      routeDate: json['routeDate'] ?? '',
      status: json['status'] ?? 'draft',
    );
  }
}

class Visit {
  final int id;
  final int accountId;
  final int? agentId;
  final int? routePlanStopId;
  final String visitStatus;
  final String checkInAt;
  final String? checkOutAt;
  final double? checkInLatitude;
  final double? checkInLongitude;

  Visit({
    required this.id,
    required this.accountId,
    this.agentId,
    this.routePlanStopId,
    required this.visitStatus,
    required this.checkInAt,
    this.checkOutAt,
    this.checkInLatitude,
    this.checkInLongitude,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      accountId: json['accountId'] ?? 0,
      agentId: json['agentId'],
      routePlanStopId: json['routePlanStopId'],
      visitStatus: json['visitStatus'] ?? 'active',
      checkInAt: json['checkInAt'] ?? '',
      checkOutAt: json['checkOutAt'],
      checkInLatitude: json['checkInLatitude'] != null ? double.tryParse(json['checkInLatitude'].toString()) : null,
      checkInLongitude: json['checkInLongitude'] != null ? double.tryParse(json['checkInLongitude'].toString()) : null,
    );
  }
}

class UnplannedVisit {
  final int id;
  final int accountId;
  final String checkInAt;

  UnplannedVisit({
    required this.id,
    required this.accountId,
    required this.checkInAt,
  });

  factory UnplannedVisit.fromJson(Map<String, dynamic> json) {
    return UnplannedVisit(
      id: json['id'],
      accountId: json['accountId'] ?? 0,
      checkInAt: json['checkInAt'] ?? '',
    );
  }
}

class RouteStop {
  final int id;
  final int routePlanId;
  final int accountId;
  final int? zoneId;
  final int sequenceOrder;
  final String plannedVisitDate;
  final String? plannedStartTime;
  final String? plannedEndTime;
  final bool isMandatory;
  final String status;
  final String? computedState;
  final Map<String, dynamic>? account;
  final Visit? visit;

  RouteStop({
    required this.id,
    required this.routePlanId,
    required this.accountId,
    this.zoneId,
    required this.sequenceOrder,
    required this.plannedVisitDate,
    this.plannedStartTime,
    this.plannedEndTime,
    required this.isMandatory,
    required this.status,
    this.computedState,
    this.account,
    this.visit,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'],
      routePlanId: json['routePlanId'] ?? 0,
      accountId: json['accountId'] ?? 0,
      zoneId: json['zoneId'],
      sequenceOrder: json['sequenceOrder'] ?? 0,
      plannedVisitDate: json['plannedVisitDate'] ?? '',
      plannedStartTime: json['plannedStartTime'],
      plannedEndTime: json['plannedEndTime'],
      isMandatory: json['isMandatory'] ?? false,
      status: json['status'] ?? 'planned',
      computedState: json['computedState'],
      account: json['account'],
      visit: json['visit'] != null ? Visit.fromJson(json['visit']) : null,
    );
  }
}

class DailyRouteResponse {
  final RoutePlan? plan;
  final List<RouteStop> stops;
  final List<UnplannedVisit> unplannedVisits;

  DailyRouteResponse({
    this.plan,
    required this.stops,
    required this.unplannedVisits,
  });

  factory DailyRouteResponse.fromJson(Map<String, dynamic> json) {
    return DailyRouteResponse(
      plan: json['plan'] != null ? RoutePlan.fromJson(json['plan']) : null,
      stops: (json['stops'] as List?)?.map((s) => RouteStop.fromJson(s)).toList() ?? [],
      unplannedVisits: (json['unplannedVisits'] as List?)?.map((u) => UnplannedVisit.fromJson(u)).toList() ?? [],
    );
  }
}

class StartVisitRequest {
  final int accountId;
  final int? routePlanStopId;
  final double? checkInLatitude;
  final double? checkInLongitude;

  StartVisitRequest({
    required this.accountId,
    this.routePlanStopId,
    this.checkInLatitude,
    this.checkInLongitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      if (routePlanStopId != null) 'routePlanStopId': routePlanStopId,
      if (checkInLatitude != null) 'checkInLatitude': checkInLatitude,
      if (checkInLongitude != null) 'checkInLongitude': checkInLongitude,
    };
  }
}
