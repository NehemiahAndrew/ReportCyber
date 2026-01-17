import '../../../../core/network/api_client.dart';
import '../../domain/entities/dashboard_stats.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStats> getDashboardStats();
  Future<List<ReportTrend>> getReportTrends({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<List<CategoryDistribution>> getCategoryDistribution();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DashboardStats> getDashboardStats() async {
    final response = await apiClient.get('/dashboard/stats');
    return _parseDashboardStats(response.data);
  }

  @override
  Future<List<ReportTrend>> getReportTrends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await apiClient.get(
      '/dashboard/trends',
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );

    return (response.data['trends'] as List)
        .map(
          (json) => ReportTrend(
            date: DateTime.parse(json['date']),
            count: json['count'] as int,
          ),
        )
        .toList();
  }

  @override
  Future<List<CategoryDistribution>> getCategoryDistribution() async {
    final response = await apiClient.get('/dashboard/categories');

    return (response.data['categories'] as List)
        .map(
          (json) => CategoryDistribution(
            category: json['category'] as String,
            count: json['count'] as int,
            percentage: (json['percentage'] as num).toDouble(),
          ),
        )
        .toList();
  }

  DashboardStats _parseDashboardStats(Map<String, dynamic> json) {
    return DashboardStats(
      totalReports: json['totalReports'] as int? ?? 0,
      pendingReports: json['pendingReports'] as int? ?? 0,
      resolvedReports: json['resolvedReports'] as int? ?? 0,
      inProgressReports: json['inProgressReports'] as int? ?? 0,
      criticalReports: json['criticalReports'] as int? ?? 0,
      highReports: json['highReports'] as int? ?? 0,
      mediumReports: json['mediumReports'] as int? ?? 0,
      lowReports: json['lowReports'] as int? ?? 0,
      recentTrends:
          (json['recentTrends'] as List?)
              ?.map(
                (t) => ReportTrend(
                  date: DateTime.parse(t['date']),
                  count: t['count'] as int,
                ),
              )
              .toList() ??
          [],
      categoryDistribution:
          (json['categoryDistribution'] as List?)
              ?.map(
                (c) => CategoryDistribution(
                  category: c['category'] as String,
                  count: c['count'] as int,
                  percentage: (c['percentage'] as num).toDouble(),
                ),
              )
              .toList() ??
          [],
    );
  }
}
