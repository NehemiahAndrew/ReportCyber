import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalReports;
  final int pendingReports;
  final int resolvedReports;
  final int inProgressReports;
  final int criticalReports;
  final int highReports;
  final int mediumReports;
  final int lowReports;
  final List<ReportTrend> recentTrends;
  final List<CategoryDistribution> categoryDistribution;

  const DashboardStats({
    required this.totalReports,
    required this.pendingReports,
    required this.resolvedReports,
    required this.inProgressReports,
    required this.criticalReports,
    required this.highReports,
    required this.mediumReports,
    required this.lowReports,
    required this.recentTrends,
    required this.categoryDistribution,
  });

  @override
  List<Object?> get props => [
    totalReports,
    pendingReports,
    resolvedReports,
    inProgressReports,
    criticalReports,
    highReports,
    mediumReports,
    lowReports,
    recentTrends,
    categoryDistribution,
  ];
}

class ReportTrend extends Equatable {
  final DateTime date;
  final int count;

  const ReportTrend({required this.date, required this.count});

  @override
  List<Object?> get props => [date, count];
}

class CategoryDistribution extends Equatable {
  final String category;
  final int count;
  final double percentage;

  const CategoryDistribution({
    required this.category,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, count, percentage];
}
