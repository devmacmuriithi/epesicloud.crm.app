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
class Zone {
  final int id;
  final String name;
  final String? color;

  Zone({required this.id, required this.name, this.color});

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      name: json['name'] ?? '',
      color: json['color'],
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
  final Zone? zone;
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
    this.zone,
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
      zone: json['zone'] != null ? Zone.fromJson(json['zone']) : null,
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
  final int agentId;
  final int? routePlanStopId;
  final double? checkInLatitude;
  final double? checkInLongitude;

  StartVisitRequest({
    required this.accountId,
    required this.agentId,
    this.routePlanStopId,
    this.checkInLatitude,
    this.checkInLongitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'agentId': agentId,
      if (routePlanStopId != null) 'routePlanStopId': routePlanStopId,
      if (checkInLatitude != null) 'checkInLatitude': checkInLatitude,
      if (checkInLongitude != null) 'checkInLongitude': checkInLongitude,
    };
  }
}

class VisitOrder {
  final int id;
  final int? productId;
  final int quantity;
  final String unitPrice;
  final String totalAmount;
  final String status;
  final String? notes;
  final String? photoUrl;
  final String? photoCaption;
  final String? captionType;
  final DateTime? createdAt;

  VisitOrder({
    required this.id,
    this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.photoUrl,
    this.photoCaption,
    this.captionType,
    this.createdAt,
  });

  factory VisitOrder.fromJson(Map<String, dynamic> json) {
    return VisitOrder(
      id: json['id'],
      productId: json['productId'],
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unitPrice']?.toString() ?? '0.00',
      totalAmount: json['totalAmount']?.toString() ?? '0.00',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class CompetitorRate {
  final int id;
  final int? competitorId;
  final int? productId;
  final String? sellingPrice;
  final String? buyingPrice;
  final bool hasOffer;
  final String? offerPrice;
  final String? notes;
  final String? photoUrl;
  final String? photoCaption;
  final String? captionType;
  final DateTime? createdAt;

  CompetitorRate({
    required this.id,
    this.competitorId,
    this.productId,
    this.sellingPrice,
    this.buyingPrice,
    required this.hasOffer,
    this.offerPrice,
    this.notes,
    this.photoUrl,
    this.photoCaption,
    this.captionType,
    this.createdAt,
  });

  factory CompetitorRate.fromJson(Map<String, dynamic> json) {
    return CompetitorRate(
      id: json['id'],
      competitorId: json['competitorId'],
      productId: json['productId'],
      sellingPrice: json['sellingPrice']?.toString(),
      buyingPrice: json['buyingPrice']?.toString(),
      hasOffer: json['hasOffer'] ?? json['isOffer'] ?? false,
      offerPrice: json['offerPrice']?.toString(),
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      photoCaption: json['photoCaption'],
      captionType: json['captionType'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class OutletRate {
  final int id;
  final int? productId;
  final String? buyingPrice;
  final String? sellingPrice;
  final String? notes;
  final String? photoUrl;
  final String? photoCaption;
  final String? captionType;
  final DateTime? createdAt;

  OutletRate({
    required this.id,
    this.productId,
    this.buyingPrice,
    this.sellingPrice,
    this.notes,
    this.photoUrl,
    this.photoCaption,
    this.captionType,
    this.createdAt,
  });

  factory OutletRate.fromJson(Map<String, dynamic> json) {
    return OutletRate(
      id: json['id'],
      productId: json['productId'],
      buyingPrice: json['buyingPrice']?.toString(),
      sellingPrice: json['sellingPrice']?.toString(),
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      photoCaption: json['photoCaption'],
      captionType: json['captionType'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class Complaint {
  final int id;
  final int? complaintTypeId;
  final int? productId;
  final String? severityLevel;
  final String? notes;
  final String? status;
  final String? photoUrl;
  final String? photoCaption;
  final String? captionType;
  final DateTime? createdAt;

  Complaint({
    required this.id,
    this.complaintTypeId,
    this.productId,
    this.severityLevel,
    this.notes,
    this.status,
    this.photoUrl,
    this.photoCaption,
    this.captionType,
    this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      complaintTypeId: json['complaintTypeId'],
      productId: json['productId'],
      severityLevel: json['severityLevel'],
      notes: json['notes'],
      status: json['status'] ?? 'open',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class VisitPhoto {
  final int id;
  final String photoUrl;
  final String? caption;
  final String? captionType;
  final String? linkedEntity;
  final String? linkedEntityReference;
  final DateTime? createdAt;

  VisitPhoto({
    required this.id,
    required this.photoUrl,
    this.caption,
    this.captionType,
    this.linkedEntity,
    this.linkedEntityReference,
    this.createdAt,
  });

  factory VisitPhoto.fromJson(Map<String, dynamic> json) {
    return VisitPhoto(
      id: json['id'],
      photoUrl: json['photoUrl'] ?? '',
      caption: json['caption'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}


class StockAvailability {
  final int id;
  final int? productId;
  final int? unitsAvailableCount;
  final int? damagedCount;
  final String? notes;
  final String? photoUrl;
  final String? photoCaption;
  final String? captionType;
  final DateTime? createdAt;

  StockAvailability({
    required this.id,
    this.productId,
    this.unitsAvailableCount,
    this.damagedCount,
    this.notes,
    this.photoUrl,
    this.photoCaption,
    this.captionType,
    this.createdAt,
  });

  factory StockAvailability.fromJson(Map<String, dynamic> json) {
    return StockAvailability(
      id: json['id'],
      productId: json['productId'],
      unitsAvailableCount: json['unitsAvailableCount'] != null ? int.tryParse(json['unitsAvailableCount'].toString()) : null,
      damagedCount: json['damagedCount'] != null ? int.tryParse(json['damagedCount'].toString()) : null,
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      photoCaption: json['photoCaption'],
      captionType: json['captionType'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class ShelfPlacement {
  final int id;
  final int? productId;
  final bool? isPlanogramCompliant;
  final bool? isEyeLevel;
  final bool? hasPrimeShelfSpace;
  final int? facingsCount;
  final String? notes;
  final String? photoUrl;
  final String? photoCaption;
  final String? captionType;
  final DateTime? createdAt;

  ShelfPlacement({
    required this.id,
    this.productId,
    this.isPlanogramCompliant,
    this.isEyeLevel,
    this.hasPrimeShelfSpace,
    this.facingsCount,
    this.notes,
    this.photoUrl,
    this.photoCaption,
    this.captionType,
    this.createdAt,
  });

  factory ShelfPlacement.fromJson(Map<String, dynamic> json) {
    return ShelfPlacement(
      id: json['id'],
      productId: json['productId'],
      isPlanogramCompliant: json['isPlanogramCompliant'] ?? json['is_planogram_compliant'],
      isEyeLevel: json['isEyeLevel'] ?? json['is_eye_level'],
      hasPrimeShelfSpace: json['hasPrimeShelfSpace'] ?? json['has_prime_shelf_space'],
      facingsCount: json['facingsCount'] != null ? int.tryParse(json['facingsCount'].toString()) : null,
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      photoCaption: json['photoCaption'],
      captionType: json['captionType'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class PromotionAudit {
  final int id;
  final int? productId;
  final bool? promotionalMaterialsInstalled;
  final String? displaySetupStatus;
  final bool? promotionActiveVisible;
  final String? notes;
  final String? photoUrl;
  final String? photoCaption;
  final String? captionType;
  final DateTime? createdAt;

  PromotionAudit({
    required this.id,
    this.productId,
    this.promotionalMaterialsInstalled,
    this.displaySetupStatus,
    this.promotionActiveVisible,
    this.notes,
    this.photoUrl,
    this.photoCaption,
    this.captionType,
    this.createdAt,
  });

  factory PromotionAudit.fromJson(Map<String, dynamic> json) {
    return PromotionAudit(
      id: json['id'],
      productId: json['productId'],
      promotionalMaterialsInstalled: json['promotionalMaterialsInstalled'],
      displaySetupStatus: json['displaySetupStatus'],
      promotionActiveVisible: json['promotionActiveVisible'],
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      photoCaption: json['photoCaption'],
      captionType: json['captionType'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class VisitRecord {
  final int id;
  final int accountId;
  final String accountName;
  final int? agentId;
  final String visitStatus;
  final String checkInAt;
  final String? checkOutAt;
  final String? notes;
  final DateTime? createdAt;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final int? zoneId;
  final String? zoneName;

  // Aggregate Tab Collections
  final List<VisitOrder> orders;
  final List<CompetitorRate> competitorRates;
  final List<OutletRate> outletRates;
  final List<Complaint> complaints;
  final List<VisitPhoto> photos;
  final List<StockAvailability> stockAvailability;
  final List<ShelfPlacement> shelfPlacements;
  final List<PromotionAudit> promotionAudits;

  VisitRecord({
    required this.id,
    required this.accountId,
    required this.accountName,
    this.agentId,
    required this.visitStatus,
    required this.checkInAt,
    this.checkOutAt,
    this.notes,
    this.createdAt,
    this.checkInLatitude,
    this.checkInLongitude,
    this.zoneId,
    this.zoneName,
    this.orders = const [],
    this.competitorRates = const [],
    this.outletRates = const [],
    this.complaints = const [],
    this.photos = const [],
    this.stockAvailability = const [],
    this.shelfPlacements = const [],
    this.promotionAudits = const [],
  });

  factory VisitRecord.fromJson(Map<String, dynamic> json) {
    return VisitRecord(
      id: json['id'],
      accountId: json['accountId'] ?? 0,
      accountName: json['accountName'] ?? 'Unknown Account',
      agentId: json['agentId'],
      visitStatus: json['visitStatus'] ?? 'active',
      checkInAt: json['checkInAt'] ?? '',
      checkOutAt: json['checkOutAt'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      checkInLatitude: json['checkInLatitude'] != null ? double.tryParse(json['checkInLatitude'].toString()) : null,
      checkInLongitude: json['checkInLongitude'] != null ? double.tryParse(json['checkInLongitude'].toString()) : null,
      zoneId: json['zoneId'],
      zoneName: json['zoneName'],
      orders: (json['orders'] as List?)?.map((x) => VisitOrder.fromJson(x)).toList() ?? [],
      competitorRates: (json['competitorRates'] as List?)?.map((x) => CompetitorRate.fromJson(x)).toList() ?? [],
      outletRates: (json['outletRates'] as List?)?.map((x) => OutletRate.fromJson(x)).toList() ?? [],
      complaints: (json['complaints'] as List?)?.map((x) => Complaint.fromJson(x)).toList() ?? [],
      photos: (json['photos'] as List?)?.map((x) => VisitPhoto.fromJson(x)).toList() ?? [],
      stockAvailability: (json['stockAvailability'] as List?)?.map((x) => StockAvailability.fromJson(x)).toList() ?? [],
      shelfPlacements: (json['shelfPlacements'] as List?)?.map((x) => ShelfPlacement.fromJson(x)).toList() ?? [],
      promotionAudits: (json['promotionAudits'] as List?)?.map((x) => PromotionAudit.fromJson(x)).toList() ?? [],
    );
  }

  bool get isActive => visitStatus == 'active';
  bool get isCompleted => visitStatus == 'completed';
}
