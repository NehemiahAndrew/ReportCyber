import 'package:equatable/equatable.dart';

/// Verification result entity representing the outcome of evidence verification
class VerificationResultEntity extends Equatable {
  final String verificationId;
  final DateTime timestamp;
  final String authenticityLevel;
  final String authenticityDescription;
  final int trustScore;
  final bool metadataVerified;
  final String editHistory;
  final bool signatureValid;
  final int manipulationScore;
  final String fileHash;
  final int fileSize;
  final String fileType;
  final String mediaType;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;
  final String? reportId;

  const VerificationResultEntity({
    required this.verificationId,
    required this.timestamp,
    required this.authenticityLevel,
    required this.authenticityDescription,
    required this.trustScore,
    required this.metadataVerified,
    required this.editHistory,
    required this.signatureValid,
    required this.manipulationScore,
    required this.fileHash,
    required this.fileSize,
    required this.fileType,
    required this.mediaType,
    required this.recommendations,
    this.metadata,
    this.reportId,
  });

  bool get isAuthentic => authenticityLevel == 'High' && trustScore >= 70;
  bool get hasWarnings => authenticityLevel == 'Medium' || !metadataVerified;
  bool get isUnreliable => authenticityLevel == 'Low' || trustScore < 40;

  @override
  List<Object?> get props => [
        verificationId,
        timestamp,
        authenticityLevel,
        trustScore,
        fileHash,
      ];
}

/// Verification history item
class VerificationHistoryItem extends Equatable {
  final String verificationId;
  final DateTime timestamp;
  final String fileName;
  final String authenticityLevel;
  final int trustScore;
  final String? reportId;

  const VerificationHistoryItem({
    required this.verificationId,
    required this.timestamp,
    required this.fileName,
    required this.authenticityLevel,
    required this.trustScore,
    this.reportId,
  });

  @override
  List<Object?> get props => [
        verificationId,
        timestamp,
        fileName,
        trustScore,
        reportId,
      ];
}

/// Comparison result when checking file hash against database
class ComparisonResult extends Equatable {
  final bool found;
  final int totalMatches;
  final List<MatchedReport> matchedReports;
  final String message;

  const ComparisonResult({
    required this.found,
    required this.totalMatches,
    required this.matchedReports,
    required this.message,
  });

  @override
  List<Object?> get props => [found, totalMatches, matchedReports, message];
}

/// Matched report when file hash is found in database
class MatchedReport extends Equatable {
  final String reportId;
  final String verificationId;
  final DateTime verifiedAt;
  final String authenticityLevel;
  final int trustScore;

  const MatchedReport({
    required this.reportId,
    required this.verificationId,
    required this.verifiedAt,
    required this.authenticityLevel,
    required this.trustScore,
  });

  @override
  List<Object?> get props => [
        reportId,
        verificationId,
        verifiedAt,
        authenticityLevel,
        trustScore,
      ];
}
