import 'crm_models.dart';

class LeadModel {
  final int id;
  final String? salutation;
  final String firstName;
  final String lastName;
  final String company;
  final String email;
  final String? phone;
  final String? mobile;
  final String? fax;
  final String? website;
  final int? leadSourceId;
  final String? industry;
  final int? numberOfEmployees;
  final double? annualRevenue;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String status;
  final int? interestLevelId;
  final int? leadScore;
  final bool isConverted;
  final DateTime? convertedDate;
  final int? convertedAccountId;
  final int? convertedContactId;
  final int? convertedDealId;
  final int? agentId;
  final int? supervisorId;
  final int? assignedById;
  final DateTime? assignedAt;
  final int? productId;
  final double? dealAmount;
  final int? leadStatusTypeId;
  final int? accountId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ActivityModel> activities;
  final List<NoteModel> notes;
  final List<DocumentModel> documents;
  
  // UI helper for full name — trims to avoid leading/trailing spaces from empty parts
  String get name {
    final parts = [firstName.trim(), lastName.trim()].where((e) => e.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : 'Unknown Lead';
  }

  LeadModel({
    required this.id,
    this.salutation,
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.email,
    this.phone,
    this.mobile,
    this.fax,
    this.website,
    this.leadSourceId,
    this.industry,
    this.numberOfEmployees,
    this.annualRevenue,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    required this.status,
    this.interestLevelId,
    this.leadScore,
    required this.isConverted,
    this.convertedDate,
    this.convertedAccountId,
    this.convertedContactId,
    this.convertedDealId,
    this.agentId,
    this.supervisorId,
    this.assignedById,
    this.assignedAt,
    this.productId,
    this.dealAmount,
    this.leadStatusTypeId,
    this.accountId,
    this.createdAt,
    this.updatedAt,
    this.activities = const [],
    this.notes = const [],
    this.documents = const [],
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'],
      salutation: json['salutation'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      company: json['company'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      mobile: json['mobile'],
      fax: json['fax'],
      website: json['website'],
      leadSourceId: json['leadSourceId'],
      industry: json['industry'],
      numberOfEmployees: json['numberOfEmployees'],
      annualRevenue: json['annualRevenue'] != null ? double.tryParse(json['annualRevenue'].toString()) : null,
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      status: json['status'] ?? 'new',
      interestLevelId: json['interestLevelId'],
      leadScore: json['leadScore'],
      isConverted: json['isConverted'] ?? false,
      convertedDate: json['convertedDate'] != null ? DateTime.parse(json['convertedDate']) : null,
      convertedAccountId: json['convertedAccountId'],
      convertedContactId: json['convertedContactId'],
      convertedDealId: json['convertedDealId'],
      agentId: json['agentId'],
      supervisorId: json['supervisorId'],
      assignedById: json['assignedById'],
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      productId: json['productId'],
      dealAmount: json['dealAmount'] != null ? double.tryParse(json['dealAmount'].toString()) : null,
      leadStatusTypeId: json['leadStatusTypeId'],
      accountId: json['accountId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'company': company,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'fax': fax,
      'website': website,
      'leadSourceId': leadSourceId,
      'industry': industry,
      'numberOfEmployees': numberOfEmployees,
      'annualRevenue': annualRevenue,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'status': status,
      'interestLevelId': interestLevelId,
      'leadScore': leadScore,
      'isConverted': isConverted,
      'convertedDate': convertedDate?.toIso8601String(),
      'convertedAccountId': convertedAccountId,
      'convertedContactId': convertedContactId,
      'convertedDealId': convertedDealId,
      'agentId': agentId,
      'supervisorId': supervisorId,
      'assignedById': assignedById,
      'assignedAt': assignedAt?.toIso8601String(),
      'productId': productId,
      'dealAmount': dealAmount,
      'leadStatusTypeId': leadStatusTypeId,
      'accountId': accountId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
