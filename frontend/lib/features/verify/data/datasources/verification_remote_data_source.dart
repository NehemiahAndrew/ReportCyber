import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

abstract class VerificationRemoteDataSource {
  Future<Map<String, dynamic>> verifyEvidence({
    required Uint8List fileBytes,
    required String fileName,
    String? reportId,
  });
  Future<List<Map<String, dynamic>>> getVerificationHistory(
      {int limit = 20, int page = 1});
  Future<Map<String, dynamic>> compareEvidence(String fileHash);
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final ApiClient apiClient;

  VerificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> verifyEvidence({
    required Uint8List fileBytes,
    required String fileName,
    String? reportId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
        if (reportId != null) 'reportId': reportId,
      });

      final response = await apiClient.dio.post(
        '/verify/evidence',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data']['verification'];
      } else {
        throw Exception('Verification failed: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Verification error: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to verify evidence: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getVerificationHistory({
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/verify/history',
        queryParameters: {
          'limit': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final verifications = response.data['data']['verifications'] as List;
        return verifications.map((v) => v as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get history: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'History error: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get verification history: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> compareEvidence(String fileHash) async {
    try {
      final response = await apiClient.dio.post(
        '/verify/compare',
        data: {'fileHash': fileHash},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'];
      } else {
        throw Exception('Comparison failed: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Comparison error: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to compare evidence: $e');
    }
  }
}
