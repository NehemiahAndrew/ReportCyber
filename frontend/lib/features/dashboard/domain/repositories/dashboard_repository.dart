import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();
  Future<Either<Failure, List<ReportTrend>>> getReportTrends({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<Either<Failure, List<CategoryDistribution>>> getCategoryDistribution();
}
