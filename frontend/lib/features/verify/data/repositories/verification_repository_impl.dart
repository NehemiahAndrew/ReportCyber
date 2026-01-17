import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/verification_result.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;

  VerificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VerificationResultEntity>> verifyEvidence({
    required Uint8List fileBytes,
    required String fileName,
    String? reportId,
  }) async {
    try {
      final verificationData = await remoteDataSource.verifyEvidence(
        fileBytes: fileBytes,
        fileName: fileName,
        reportId: reportId,
      );

      final results = verificationData['results'];
      final summary = verificationData['summary'];

      final entity = VerificationResultEntity(
        verificationId: verificationData['verificationId'],
        timestamp: DateTime.parse(verificationData['timestamp']),
        authenticityLevel: results['authenticityLevel'] ?? 'Medium',
        authenticityDescription:
            results['authenticityDescription'] ?? 'File analyzed',
        trustScore: summary['trustScore'] ?? 50,
        metadataVerified: results['metadataVerified'] ?? false,
        editHistory: results['editHistory'] ?? 'Unknown',
        signatureValid: results['signatureValid'] ?? false,
        manipulationScore: results['manipulationScore'] ?? 0,
        fileHash: results['fileHash'] ?? '',
        fileSize: results['fileSize'] ?? 0,
        fileType: results['fileType'] ?? '',
        mediaType: results['mediaType'] ?? 'file',
        recommendations: List<String>.from(summary['recommendations'] ?? []),
        metadata: results['metadata'],
        reportId: reportId,
      );

      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VerificationHistoryItem>>>
      getVerificationHistory({
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final historyData = await remoteDataSource.getVerificationHistory(
        limit: limit,
        page: page,
      );

      final items = historyData.map((data) {
        return VerificationHistoryItem(
          verificationId: data['verificationId'],
          timestamp: DateTime.parse(data['createdAt'] ?? data['timestamp']),
          fileName: data['fileName'],
          authenticityLevel: data['results']['authenticityLevel'],
          trustScore: data['summary']['trustScore'],
          reportId: data['reportId']?['reportId'],
        );
      }).toList();

      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ComparisonResult>> compareEvidence(
      String fileHash) async {
    try {
      final comparisonData = await remoteDataSource.compareEvidence(fileHash);

      final matchedReportsList =
          comparisonData['matchedReports'] as List? ?? [];
      final matchedReports = matchedReportsList.map((report) {
        return MatchedReport(
          reportId: report['reportId'],
          verificationId: report['verificationId'],
          verifiedAt: DateTime.parse(report['verifiedAt']),
          authenticityLevel: report['authenticityLevel'],
          trustScore: report['trustScore'],
        );
      }).toList();

      final result = ComparisonResult(
        found: comparisonData['found'] ?? false,
        totalMatches: comparisonData['totalMatches'] ?? 0,
        matchedReports: matchedReports,
        message: comparisonData['message'] ?? '',
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
