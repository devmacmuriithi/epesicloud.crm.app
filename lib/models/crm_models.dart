// Updated: 2026-03-30 13:34
class DashboardStats {
  final double pipelineValue;
  final int activeDeals;
  final int winRate;
  final int newLeads;
  final int totalAccounts;
  final int totalContacts;
  final int activitiesThisWeek;
  final double paymentsThisMonth;

  DashboardStats({
    required this.pipelineValue,
    required this.activeDeals,
    required this.winRate,
    required this.newLeads,
    required this.totalAccounts,
    required this.totalContacts,
    required this.activitiesThisWeek,
    required this.paymentsThisMonth,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      pipelineValue: double.tryParse(json['pipelineValue']?.toString() ?? '0') ?? 0,
      activeDeals: json['activeDeals'] ?? 0,
      winRate: json['winRate'] ?? 0,
      newLeads: json['newLeads'] ?? 0,
      totalAccounts: json['totalAccounts'] ?? 0,
      totalContacts: json['totalContacts'] ?? 0,
      activitiesThisWeek: json['activitiesThisWeek'] ?? 0,
      paymentsThisMonth: double.tryParse(json['paymentsThisMonth']?.toString() ?? '0') ?? 0,
    );
  }
}

class AccountModel {
  final int id;
  final String? tenantId;
  final String accountName;
  final String? accountNumber;
  final int? parentAccountId;
  final int? accountTypeId;
  final String? industry;
  final String? phone;
  final String? fax;
  final String? website;
  final int? employees;
  final double? annualRevenue;
  final int? interestLevelId;
  final String? description;
  final String? billingStreet;
  final String? billingCity;
  final String? billingState;
  final String? billingPostalCode;
  final String? billingCountry;
  final String? shippingStreet;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingPostalCode;
  final String? shippingCountry;
  final int? agentId;
  final int? supervisorId;
  final int? zoneId;
  final int? paymentTermId;
  final int? paymentTermDays;
  final String? paymentTerm;
  final String? accountType;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ActivityModel> activities;
  final List<NoteModel> notes;
  final List<DocumentModel> documents;
  AccountModel({
    required this.id,
    this.tenantId,
    required this.accountName,
    this.accountNumber,
    this.parentAccountId,
    this.accountTypeId,
    this.industry,
    this.phone,
    this.fax,
    this.website,
    this.employees,
    this.annualRevenue,
    this.interestLevelId,
    this.description,
    this.billingStreet,
    this.billingCity,
    this.billingState,
    this.billingPostalCode,
    this.billingCountry,
    this.shippingStreet,
    this.shippingCity,
    this.shippingState,
    this.shippingPostalCode,
    this.shippingCountry,
    this.agentId,
    this.supervisorId,
    this.zoneId,
    this.paymentTermId,
    this.paymentTermDays,
    this.paymentTerm,
    this.accountType,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.activities = const [],
    this.notes = const [],
    this.documents = const [],
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      tenantId: json['tenantId']?.toString(),
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'],
      parentAccountId: json['parentAccountId'],
      accountTypeId: json['accountTypeId'],
      industry: json['industry'],
      phone: json['phone']?.toString(),
      fax: json['fax']?.toString(),
      website: json['website'],
      employees: json['employees'],
      annualRevenue: json['annualRevenue'] != null ? double.tryParse(json['annualRevenue'].toString()) : null,
      interestLevelId: json['interestLevelId'],
      description: json['description'],
      billingStreet: json['billingStreet'],
      billingCity: json['billingCity'],
      billingState: json['billingState'],
      billingPostalCode: json['billingPostalCode'],
      billingCountry: json['billingCountry'],
      shippingStreet: json['shippingStreet'],
      shippingCity: json['shippingCity'],
      shippingState: json['shippingState'],
      shippingPostalCode: json['shippingPostalCode'],
      shippingCountry: json['shippingCountry'],
      agentId: json['agentId'],
      supervisorId: json['supervisorId'],
      zoneId: json['zoneId'],
      paymentTermId: json['paymentTermId'],
      paymentTermDays: json['paymentTermDays'],
      paymentTerm: json['paymentTerm'] is Map ? json['paymentTerm']['title'] : json['paymentTerm']?.toString(),
      accountType: json['accountType'] is Map ? json['accountType']['title'] : json['accountType']?.toString(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class ContactModel {
  final int id;
  final String? salutation;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? mobile;
  final String? otherPhone;
  final String? fax;
  final String? title;
  final String? department;
  final int? accountId;
  final String? city;
  final String? country;
  final String? mailingStreet;
  final String? mailingCity;
  final String? mailingState;
  final String? mailingZip;
  final String? mailingCountry;
  final String? leadSource;
  final int? agentId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContactModel({
    required this.id,
    this.salutation,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.mobile,
    this.otherPhone,
    this.fax,
    this.title,
    this.department,
    this.accountId,
    this.city,
    this.country,
    this.mailingStreet,
    this.mailingCity,
    this.mailingState,
    this.mailingZip,
    this.mailingCountry,
    this.leadSource,
    this.agentId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
  String? get createdTime => createdAt != null ? "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}" : null;

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      salutation: json['salutation'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      mobile: json['mobile'],
      otherPhone: json['otherPhone'],
      fax: json['fax'],
      title: json['title'],
      department: json['department'],
      accountId: json['accountId'],
      city: json['city'],
      country: json['country'],
      mailingStreet: json['mailingStreet'],
      mailingCity: json['mailingCity'],
      mailingState: json['mailingState'],
      mailingZip: json['mailingZip'],
      mailingCountry: json['mailingCountry'],
      leadSource: json['leadSource'],
      agentId: json['agentId'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class DealModel {
  final int id;
  final String dealName;
  final double salePrice;
  final String? closingDate;
  final String? stage;
  final int? leadId;
  final int? accountId;
  final int? contactId;
  final int? pipelineId;
  final int? stageId;
  final bool isClosed;
  final bool isWon;
  final String? description;
  final String? nextStep;
  final int? dealTypeId;
  final String? leadSourceId;
  final int? quantity;
  final int? agentId;
  final DateTime? createdAt;
  final String? accountName;
  final String? contactName;
  final String? leadSourceName;
  final String? agentName;
  final List<ActivityModel> activities;
  final List<NoteModel> notes;
  final List<DocumentModel> documents;

  DealModel({
    required this.id,
    required this.dealName,
    required this.salePrice,
    this.closingDate,
    this.stage,
    this.leadId,
    this.accountId,
    this.contactId,
    this.pipelineId,
    this.stageId,
    this.dealTypeId,
    required this.isClosed,
    required this.isWon,
    this.description,
    this.nextStep,
    this.leadSourceId,
    this.quantity,
    this.agentId,
    this.createdAt,
    this.accountName,
    this.contactName,
    this.leadSourceName,
    this.agentName,
    this.activities = const [],
    this.notes = const [],
    this.documents = const [],
  });

  double get amount => salePrice;
  String? get createdTime => createdAt != null ? "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}" : null;

  factory DealModel.fromJson(Map<String, dynamic> json) {
    try {
      return DealModel(
        id: json['id'],
        dealName: json['dealName'] ?? '',
        salePrice: double.tryParse(json['salePrice']?.toString() ?? '0') ?? 0,
        closingDate: json['closingDate']?.toString(),
        stage: json['stage'] is Map ? json['stage']['title'] : json['stage']?.toString(),
        leadId: json['leadId'],
        accountId: json['accountId'],
        contactId: json['contactId'],
        pipelineId: json['pipelineId'],
        stageId: json['stageId'],
        dealTypeId: json['dealTypeId'],
        isClosed: json['isClosed'] ?? false,
        isWon: json['isWon'] ?? false,
        description: json['description'],
        nextStep: json['nextStep'],
        leadSourceId: json['leadSourceId']?.toString(),
        quantity: json['quantity'],
        agentId: json['agentId'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        accountName: json['account'] is Map ? json['account']['accountName']?.toString() : null,
        contactName: json['contact'] is Map ? 
            '${json['contact']['firstName'] ?? ''} ${json['contact']['lastName'] ?? ''}'.trim() : null,
        leadSourceName: json['leadSource'] is Map ? json['leadSource']['title']?.toString() : null,
        agentName: json['agent'] is Map ? 
            '${json['agent']['firstName'] ?? ''} ${json['agent']['lastName'] ?? ''}'.trim() : null,
      );
    } catch (e, stack) {
      print('ERROR: Failed to parse DealModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class ActivityModel {
  final int id;
  final String subject;
  final String type;
  final String status;
  final int? activityTypeId;
  final int? activityStatusTypeId;
  final String? priority;
  final int? leadId;
  final int? accountId;
  final int? contactId;
  final int? dealId;
  final int? caseId;
  final String? dueDate;
  final String? startDate;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final int? duration;
  final String? location;
  final String? description;
  final String? linkedEntityType;
  final int? linkedEntityId;
  final String? linkedEntityName;
  final double? latitude;
  final double? longitude;

  ActivityModel({
    required this.id,
    required this.subject,
    required this.type,
    required this.status,
    this.activityTypeId,
    this.activityStatusTypeId,
    this.priority,
    this.leadId,
    this.accountId,
    this.contactId,
    this.dealId,
    this.caseId,
    this.dueDate,
    this.startDate,
    this.startDateTime,
    this.endDateTime,
    this.duration,
    this.location,
    this.description,
    this.linkedEntityType,
    this.linkedEntityId,
    this.linkedEntityName,
    this.latitude,
    this.longitude,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      subject: json['subject'] ?? '',
      type: json['activityType'] is Map ? (json['activityType']['title'] ?? json['activityType']['name'] ?? 'Other') : (json['activityType']?.toString() ?? 'Other'),
      status: json['status'] is Map ? (json['status']['title'] ?? json['status']['name'] ?? 'Unknown') : (json['status']?.toString() ?? 'Unknown'),
      activityTypeId: json['activityTypeId'],
      activityStatusTypeId: json['activityStatusTypeId'],
      priority: json['priority'] is Map ? (json['priority']['title'] ?? json['priority']['name'] ?? 'Medium') : (json['priority']?.toString() ?? 'Medium'),
      leadId: json['leadId'],
      accountId: json['accountId'],
      contactId: json['contactId'],
      dealId: json['dealId'],
      caseId: json['caseId'],
      dueDate: json['dueDate']?.toString(),
      startDate: json['startDate']?.toString(),
      startDateTime: json['startDateTime'] != null ? DateTime.parse(json['startDateTime']) : null,
      endDateTime: json['endDateTime'] != null ? DateTime.parse(json['endDateTime']) : null,
      duration: json['duration'],
      location: json['location']?.toString(),
      description: json['description']?.toString(),
      linkedEntityType: json['linkedEntityType']?.toString(),
      linkedEntityId: json['linkedEntityId'],
      linkedEntityName: json['linkedEntityName']?.toString() ?? 
                       (json['lead']?['name'] ?? 
                        json['account']?['accountName'] ?? 
                        json['deal']?['dealName'] ?? 
                        json['contact']?['fullName'] ?? 
                        json['case_']?['subject'])?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }
}

class TaskModel {
  final int id;
  final String subject;
  final String? description;
  final String? priority;
  final String? status;
  final String? dueDate;
  final String? startDate;
  final String? completedDate;
  final int? assigneeId;
  final String? linkedEntityType;
  final int? linkedEntityId;

  TaskModel({
    required this.id,
    required this.subject,
    this.description,
    this.priority,
    this.status,
    this.dueDate,
    this.startDate,
    this.completedDate,
    this.assigneeId,
    this.linkedEntityType,
    this.linkedEntityId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      subject: json['subject'] ?? '',
      description: json['description']?.toString(),
      priority: json['priority'] is Map ? json['priority']['title'] : json['priority']?.toString(),
      status: json['status'] is Map ? json['status']['title'] : json['status']?.toString(),
      dueDate: json['dueDate']?.toString(),
      startDate: json['startDate']?.toString(),
      completedDate: json['completedDate']?.toString(),
      assigneeId: json['assigneeId'],
      linkedEntityType: json['linkedEntityType']?.toString(),
      linkedEntityId: json['linkedEntityId'],
    );
  }
}

class CaseModel {
  final int id;
  final String caseNumber;
  final String? caseOrigin;
  final String? caseReason;
  final String status;
  final String priority;
  final String? linkedEntityType;
  final int? linkedEntityId;
  final int? accountId;
  final int? contactId;
  final int? productId;
  final String? description;
  final Map<String, dynamic>? account;
  final Map<String, dynamic>? lead;
  final Map<String, dynamic>? contact;
  final Map<String, dynamic>? deal;
  final String? createdAt;
  final int? caseTypeId;
  final String? title;

  CaseModel({
    required this.id,
    required this.caseNumber,
    this.caseOrigin,
    this.caseReason,
    required this.status,
    required this.priority,
    this.linkedEntityType,
    this.linkedEntityId,
    this.accountId,
    this.contactId,
    this.productId,
    this.description,
    this.account,
    this.lead,
    this.contact,
    this.deal,
    this.createdAt,
    this.caseTypeId,
    this.title,
  });

  String get linkedEntityName {
    if (linkedEntityType == 'Lead' && lead != null) return lead!['name'] ?? 'Unknown Lead';
    if (linkedEntityType == 'Deal' && deal != null) return deal!['name'] ?? 'Unknown Deal';
    if (contactId != null && contact != null) return contact!['name'] ?? 'Unknown Contact';
    if (accountId != null && account != null) return account!['name'] ?? 'Unknown Account';
    return 'None';
  }

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'],
      caseNumber: (json['caseNumber'] ?? '').toString(),
      caseOrigin: json['caseOrigin']?.toString(),
      caseReason: json['caseReason']?.toString(),
      status: json['status'] is Map ? (json['status']['name'] ?? json['status']['title'] ?? 'Unknown') : (json['status']?.toString() ?? 'Unknown'),
      priority: json['priority'] is Map ? (json['priority']['name'] ?? json['priority']['title'] ?? 'Normal') : (json['priority']?.toString() ?? 'Normal'),
      linkedEntityType: json['linkedEntityType']?.toString(),
      linkedEntityId: json['linkedEntityId'],
      accountId: json['accountId'],
      contactId: json['contactId'],
      productId: json['productId'],
      description: json['description']?.toString(),
      account: json['account'],
      lead: json['lead'],
      contact: json['contact'],
      deal: json['deal'],
      createdAt: json['createdAt']?.toString(),
      caseTypeId: json['caseTypeId'],
      title: json['title']?.toString(),
    );
  }
}

class PaymentModel {
  final int id;
  final String receiptNumber;
  final double amount;
  final String paymentDate;
  final String status;
  final int? paymentMethodId;
  final int? accountId;
  final int? contactId;
  final int? dealId;
  final String? transactionReference;
  final String? notes;

  PaymentModel({
    required this.id,
    required this.receiptNumber,
    required this.amount,
    required this.paymentDate,
    required this.status,
    this.paymentMethodId,
    this.accountId,
    this.contactId,
    this.dealId,
    this.transactionReference,
    this.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      receiptNumber: json['receiptNumber'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      paymentDate: json['paymentDate'] ?? '',
      status: json['status'] ?? 'pending',
      paymentMethodId: json['paymentMethodId'],
      accountId: json['accountId'],
      contactId: json['contactId'],
      dealId: json['dealId'],
      transactionReference: json['transactionReference'],
      notes: json['notes'],
    );
  }
}

class ProductModel {
  final int id;
  final String productCode;
  final String productName;
  final String? description;
  final double? cost;
  final double? price;
  final int? productTypeId;
  final int? productCategoryId;
  final String? condition;
  final int? unitsAvailable;
  final String? sku;
  final CollectionModel? collection;

  ProductModel({
    required this.id,
    required this.productCode,
    required this.productName,
    this.description,
    this.cost,
    this.price,
    this.productTypeId,
    this.productCategoryId,
    this.condition,
    this.unitsAvailable,
    this.sku,
    this.collection,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      description: json['description'],
      cost: json['cost'] != null ? double.tryParse(json['cost'].toString()) : null,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      productTypeId: json['productTypeId'],
      productCategoryId: json['productCategoryId'],
      condition: json['condition'],
      unitsAvailable: json['unitsAvailable'],
      sku: json['sku'],
      collection: json['collection'] != null ? CollectionModel.fromJson(json['collection']) : null,
    );
  }

  double get unitPrice => price ?? 0;
  String? get productCategory => productCategoryId?.toString(); // Placeholder for now
}

class ProjectModel {
  final int id;
  final String name;
  final String? description;
  final String status;
  final String? startDate;
  final String? endDate;
  final int? dealId;
  final int? accountId;
  final int? progress;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.startDate,
    this.endDate,
    this.dealId,
    this.accountId,
    this.progress,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'planning',
      startDate: json['startDate'],
      endDate: json['endDate'],
      dealId: json['dealId'],
      accountId: json['accountId'],
      progress: json['progress'] ?? 0,
    );
  }
}

class LookupModel {
  final int id;
  final String title;

  LookupModel({required this.id, required this.title});

  factory LookupModel.fromJson(Map<String, dynamic> json) {
    return LookupModel(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? json['methodName'] ?? json['accountName'] ?? json['dealName'] ?? '',
    );
  }
}

class CollectionModel {
  final int id;
  final String title;
  final int? salesPipelineId;

  CollectionModel({
    required this.id, 
    required this.title, 
    this.salesPipelineId
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'],
      title: json['title'] ?? '',
      salesPipelineId: json['salesPipelineId'],
    );
  }
}

class AgentModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  AgentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}


class NoteModel {
  final int id;
  final String? title;
  final String content;
  final int? authorId;
  final DateTime createdAt;
  final int? leadId;
  final int? accountId;
  final int? contactId;
  final int? dealId;
  final String? linkedEntityType;
  final int? linkedEntityId;

  NoteModel({
    required this.id,
    this.title,
    required this.content,
    this.authorId,
    required this.createdAt,
    this.leadId,
    this.accountId,
    this.contactId,
    this.dealId,
    this.linkedEntityType,
    this.linkedEntityId,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      authorId: json['authorId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      leadId: json['leadId'],
      accountId: json['accountId'],
      contactId: json['contactId'],
      dealId: json['dealId'],
      linkedEntityType: json['linkedEntityType']?.toString(),
      linkedEntityId: json['linkedEntityId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'leadId': leadId,
      'accountId': accountId,
      'contactId': contactId,
      'dealId': dealId,
      'linkedEntityType': linkedEntityType,
      'linkedEntityId': linkedEntityId,
    };
  }
}

class DocumentModel {
  final int id;
  final String fileName;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final DateTime createdAt;
  final int? leadId;
  final int? accountId;
  final int? contactId;
  final int? dealId;
  final String? linkedEntityType;
  final int? linkedEntityId;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    required this.createdAt,
    this.leadId,
    this.accountId,
    this.contactId,
    this.dealId,
    this.linkedEntityType,
    this.linkedEntityId,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      leadId: json['leadId'],
      accountId: json['accountId'],
      contactId: json['contactId'],
      dealId: json['dealId'],
      linkedEntityType: json['linkedEntityType']?.toString(),
      linkedEntityId: json['linkedEntityId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'leadId': leadId,
      'accountId': accountId,
      'contactId': contactId,
      'dealId': dealId,
      'linkedEntityType': linkedEntityType,
      'linkedEntityId': linkedEntityId,
    };
  }
}
