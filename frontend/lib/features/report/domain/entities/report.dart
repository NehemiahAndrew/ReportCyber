import 'package:equatable/equatable.dart';

enum ReportType {
  phishing,
  malware,
  identityTheft,
  onlineFraud,
  dataBreach,
  ransomware,
  socialEngineering,
  ddos,
  cyberstalking,
  hacking,
  other,
}

enum ReportStatus {
  draft,
  submitted,
  underReview,
  investigating,
  resolved,
  closed,
  rejected,
}

enum SeverityLevel { low, medium, high, critical }

class Report extends Equatable {
  final String id;
  final String reportId;
  final ReportType type;
  final String title;
  final String description;
  final ReportStatus status;
  final SeverityLevel severity;
  final String? reporterId;
  final bool isAnonymous;
  final DateTime? incidentDate;
  final ReportLocation? location;
  final List<String> affectedSystems;
  final String? attackerInfo;
  final List<String> suspiciousUrls;
  final List<String> suspiciousEmails;
  final List<String> suspiciousIps;
  final double? financialLoss;
  final String? currency;
  final List<Evidence> evidence;
  final String? assignedTo;
  final int upvotes;
  final int downvotes;
  final bool hasUpvoted;
  final bool hasDownvoted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Report({
    required this.id,
    required this.reportId,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.severity = SeverityLevel.medium,
    this.reporterId,
    this.isAnonymous = false,
    this.incidentDate,
    this.location,
    this.affectedSystems = const [],
    this.attackerInfo,
    this.suspiciousUrls = const [],
    this.suspiciousEmails = const [],
    this.suspiciousIps = const [],
    this.financialLoss,
    this.currency,
    this.evidence = const [],
    this.assignedTo,
    this.upvotes = 0,
    this.downvotes = 0,
    this.hasUpvoted = false,
    this.hasDownvoted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusDisplayName {
    switch (status) {
      case ReportStatus.draft:
        return 'Draft';
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.investigating:
        return 'Investigating';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ReportType.phishing:
        return 'Phishing';
      case ReportType.malware:
        return 'Malware';
      case ReportType.identityTheft:
        return 'Identity Theft';
      case ReportType.onlineFraud:
        return 'Online Fraud';
      case ReportType.dataBreach:
        return 'Data Breach';
      case ReportType.ransomware:
        return 'Ransomware';
      case ReportType.socialEngineering:
        return 'Social Engineering';
      case ReportType.ddos:
        return 'DDoS Attack';
      case ReportType.cyberstalking:
        return 'Cyberstalking';
      case ReportType.hacking:
        return 'Hacking';
      case ReportType.other:
        return 'Other';
    }
  }

  Report copyWith({
    String? id,
    String? reportId,
    ReportType? type,
    String? title,
    String? description,
    ReportStatus? status,
    SeverityLevel? severity,
    String? reporterId,
    bool? isAnonymous,
    DateTime? incidentDate,
    ReportLocation? location,
    List<String>? affectedSystems,
    String? attackerInfo,
    List<String>? suspiciousUrls,
    List<String>? suspiciousEmails,
    List<String>? suspiciousIps,
    double? financialLoss,
    String? currency,
    List<Evidence>? evidence,
    String? assignedTo,
    int? upvotes,
    int? downvotes,
    bool? hasUpvoted,
    bool? hasDownvoted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      reporterId: reporterId ?? this.reporterId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      incidentDate: incidentDate ?? this.incidentDate,
      location: location ?? this.location,
      affectedSystems: affectedSystems ?? this.affectedSystems,
      attackerInfo: attackerInfo ?? this.attackerInfo,
      suspiciousUrls: suspiciousUrls ?? this.suspiciousUrls,
      suspiciousEmails: suspiciousEmails ?? this.suspiciousEmails,
      suspiciousIps: suspiciousIps ?? this.suspiciousIps,
      financialLoss: financialLoss ?? this.financialLoss,
      currency: currency ?? this.currency,
      evidence: evidence ?? this.evidence,
      assignedTo: assignedTo ?? this.assignedTo,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      hasUpvoted: hasUpvoted ?? this.hasUpvoted,
      hasDownvoted: hasDownvoted ?? this.hasDownvoted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'] ?? json['id'],
      reportId: json['reportId'] ?? '',
      type: _parseReportType(json['type']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: _parseReportStatus(json['status']),
      severity: _parseSeverity(json['severity']),
      reporterId: json['reporter'],
      isAnonymous: json['isAnonymous'] ?? false,
      incidentDate: json['incidentDate'] != null
          ? DateTime.parse(json['incidentDate'])
          : null,
      location: json['location'] != null
          ? ReportLocation.fromJson(json['location'])
          : null,
      affectedSystems: json['affectedSystems'] != null
          ? List<String>.from(json['affectedSystems'])
          : [],
      attackerInfo: json['attackerInfo'],
      suspiciousUrls: json['suspiciousUrls'] != null
          ? List<String>.from(json['suspiciousUrls'])
          : [],
      suspiciousEmails: json['suspiciousEmails'] != null
          ? List<String>.from(json['suspiciousEmails'])
          : [],
      suspiciousIps: json['suspiciousIps'] != null
          ? List<String>.from(json['suspiciousIps'])
          : [],
      financialLoss: json['financialLoss']?.toDouble(),
      currency: json['currency'],
      evidence: json['evidence'] != null
          ? (json['evidence'] as List).map((e) => Evidence.fromJson(e)).toList()
          : [],
      assignedTo: json['assignedTo'],
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      hasUpvoted: json['hasUpvoted'] ?? false,
      hasDownvoted: json['hasDownvoted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reportId': reportId,
        'type': type.name,
        'title': title,
        'description': description,
        'status': status.name,
        'severity': severity.name,
        'reporter': reporterId,
        'isAnonymous': isAnonymous,
        'incidentDate': incidentDate?.toIso8601String(),
        'location': location?.toJson(),
        'affectedSystems': affectedSystems,
        'attackerInfo': attackerInfo,
        'suspiciousUrls': suspiciousUrls,
        'suspiciousEmails': suspiciousEmails,
        'suspiciousIps': suspiciousIps,
        'financialLoss': financialLoss,
        'currency': currency,
        'evidence': evidence.map((e) => e.toJson()).toList(),
        'assignedTo': assignedTo,
        'upvotes': upvotes,
        'downvotes': downvotes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static ReportType _parseReportType(String? type) {
    switch (type?.toLowerCase()) {
      case 'phishing':
        return ReportType.phishing;
      case 'malware':
        return ReportType.malware;
      case 'identity_theft':
      case 'identitytheft':
        return ReportType.identityTheft;
      case 'online_fraud':
      case 'onlinefraud':
        return ReportType.onlineFraud;
      case 'data_breach':
      case 'databreach':
        return ReportType.dataBreach;
      case 'ransomware':
        return ReportType.ransomware;
      case 'social_engineering':
      case 'socialengineering':
        return ReportType.socialEngineering;
      case 'ddos':
        return ReportType.ddos;
      default:
        return ReportType.other;
    }
  }

  static ReportStatus _parseReportStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'draft':
        return ReportStatus.draft;
      case 'submitted':
        return ReportStatus.submitted;
      case 'under_review':
      case 'underreview':
        return ReportStatus.underReview;
      case 'investigating':
        return ReportStatus.investigating;
      case 'resolved':
        return ReportStatus.resolved;
      case 'closed':
        return ReportStatus.closed;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.draft;
    }
  }

  static SeverityLevel _parseSeverity(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'low':
        return SeverityLevel.low;
      case 'medium':
        return SeverityLevel.medium;
      case 'high':
        return SeverityLevel.high;
      case 'critical':
        return SeverityLevel.critical;
      default:
        return SeverityLevel.medium;
    }
  }

  @override
  List<Object?> get props => [
        id,
        reportId,
        type,
        title,
        description,
        status,
        severity,
        reporterId,
        isAnonymous,
        incidentDate,
        location,
        affectedSystems,
        evidence,
        upvotes,
        downvotes,
        createdAt,
        updatedAt,
      ];
}

class ReportLocation extends Equatable {
  final String? country;
  final String? state;
  final String? city;
  final double? latitude;
  final double? longitude;

  const ReportLocation({
    this.country,
    this.state,
    this.city,
    this.latitude,
    this.longitude,
  });

  factory ReportLocation.fromJson(Map<String, dynamic> json) {
    return ReportLocation(
      country: json['country'],
      state: json['state'],
      city: json['city'],
      latitude: json['coordinates']?['latitude']?.toDouble(),
      longitude: json['coordinates']?['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'country': country,
        'state': state,
        'city': city,
        if (latitude != null && longitude != null)
          'coordinates': {'latitude': latitude, 'longitude': longitude},
      };

  @override
  List<Object?> get props => [country, state, city, latitude, longitude];
}

class Evidence extends Equatable {
  final String id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String url;
  final String? thumbnailUrl;
  final bool isEncrypted;
  final DateTime uploadedAt;

  const Evidence({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.url,
    this.thumbnailUrl,
    this.isEncrypted = true,
    required this.uploadedAt,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      id: json['_id'] ?? json['id'] ?? '',
      fileName: json['fileName'] ?? json['originalName'] ?? '',
      fileType: json['fileType'] ?? json['mimeType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      url: json['url'] ?? json['firebaseUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      isEncrypted: json['isEncrypted'] ?? true,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileType': fileType,
        'fileSize': fileSize,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'isEncrypted': isEncrypted,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, fileName, fileType, url, uploadedAt];
}
