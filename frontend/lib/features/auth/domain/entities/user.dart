import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? bio;
  final String? phone;
  final String role;
  final Reputation reputation;
  final bool isEmailVerified;
  final bool twoFactorEnabled;
  final NotificationPreferences notifications;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.bio,
    this.phone,
    required this.role,
    required this.reputation,
    required this.isEmailVerified,
    required this.twoFactorEnabled,
    required this.notifications,
    this.createdAt,
    this.lastLoginAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? email.split('@')[0];
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return email[0].toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      bio: json['bio'],
      phone: json['phone'],
      role: json['role'] ?? 'user',
      reputation: Reputation.fromJson(json['reputation'] ?? {}),
      isEmailVerified: json['isEmailVerified'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      notifications: NotificationPreferences.fromJson(
        json['notifications'] ?? {},
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'bio': bio,
      'phone': phone,
      'role': role,
      'reputation': reputation.toJson(),
      'isEmailVerified': isEmailVerified,
      'twoFactorEnabled': twoFactorEnabled,
      'notifications': notifications.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    String? bio,
    String? phone,
    String? role,
    Reputation? reputation,
    bool? isEmailVerified,
    bool? twoFactorEnabled,
    NotificationPreferences? notifications,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      reputation: reputation ?? this.reputation,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      notifications: notifications ?? this.notifications,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    avatar,
    bio,
    phone,
    role,
    reputation,
    isEmailVerified,
    twoFactorEnabled,
    notifications,
    createdAt,
    lastLoginAt,
  ];
}

class Reputation extends Equatable {
  final int score;
  final int totalReports;
  final int verifiedReports;
  final int rejectedReports;
  final String level;

  const Reputation({
    required this.score,
    required this.totalReports,
    required this.verifiedReports,
    required this.rejectedReports,
    required this.level,
  });

  factory Reputation.fromJson(Map<String, dynamic> json) {
    return Reputation(
      score: json['score'] ?? 0,
      totalReports: json['totalReports'] ?? 0,
      verifiedReports: json['verifiedReports'] ?? 0,
      rejectedReports: json['rejectedReports'] ?? 0,
      level: json['level'] ?? 'newcomer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'totalReports': totalReports,
      'verifiedReports': verifiedReports,
      'rejectedReports': rejectedReports,
      'level': level,
    };
  }

  @override
  List<Object?> get props => [
    score,
    totalReports,
    verifiedReports,
    rejectedReports,
    level,
  ];
}

class NotificationPreferences extends Equatable {
  final EmailNotifications email;
  final SmsNotifications sms;
  final InAppNotifications inApp;

  const NotificationPreferences({
    required this.email,
    required this.sms,
    required this.inApp,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      email: EmailNotifications.fromJson(json['email'] ?? {}),
      sms: SmsNotifications.fromJson(json['sms'] ?? {}),
      inApp: InAppNotifications.fromJson(json['inApp'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email.toJson(),
      'sms': sms.toJson(),
      'inApp': inApp.toJson(),
    };
  }

  @override
  List<Object?> get props => [email, sms, inApp];
}

class EmailNotifications extends Equatable {
  final bool reportUpdates;
  final bool securityAlerts;
  final bool newsletter;
  final bool marketing;

  const EmailNotifications({
    required this.reportUpdates,
    required this.securityAlerts,
    required this.newsletter,
    required this.marketing,
  });

  factory EmailNotifications.fromJson(Map<String, dynamic> json) {
    return EmailNotifications(
      reportUpdates: json['reportUpdates'] ?? true,
      securityAlerts: json['securityAlerts'] ?? true,
      newsletter: json['newsletter'] ?? false,
      marketing: json['marketing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportUpdates': reportUpdates,
      'securityAlerts': securityAlerts,
      'newsletter': newsletter,
      'marketing': marketing,
    };
  }

  @override
  List<Object?> get props => [
    reportUpdates,
    securityAlerts,
    newsletter,
    marketing,
  ];
}

class SmsNotifications extends Equatable {
  final bool enabled;
  final bool reportUpdates;
  final bool securityAlerts;

  const SmsNotifications({
    required this.enabled,
    required this.reportUpdates,
    required this.securityAlerts,
  });

  factory SmsNotifications.fromJson(Map<String, dynamic> json) {
    return SmsNotifications(
      enabled: json['enabled'] ?? false,
      reportUpdates: json['reportUpdates'] ?? false,
      securityAlerts: json['securityAlerts'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'reportUpdates': reportUpdates,
      'securityAlerts': securityAlerts,
    };
  }

  @override
  List<Object?> get props => [enabled, reportUpdates, securityAlerts];
}

class InAppNotifications extends Equatable {
  final bool reportUpdates;
  final bool securityAlerts;
  final bool communityUpdates;

  const InAppNotifications({
    required this.reportUpdates,
    required this.securityAlerts,
    required this.communityUpdates,
  });

  factory InAppNotifications.fromJson(Map<String, dynamic> json) {
    return InAppNotifications(
      reportUpdates: json['reportUpdates'] ?? true,
      securityAlerts: json['securityAlerts'] ?? true,
      communityUpdates: json['communityUpdates'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportUpdates': reportUpdates,
      'securityAlerts': securityAlerts,
      'communityUpdates': communityUpdates,
    };
  }

  @override
  List<Object?> get props => [reportUpdates, securityAlerts, communityUpdates];
}
