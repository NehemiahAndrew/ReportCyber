import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardStats extends DashboardEvent {}

class RefreshDashboardStats extends DashboardEvent {}

class LoadReportTrends extends DashboardEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadReportTrends({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
