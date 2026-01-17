import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/report.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/report_card.dart';
import '../widgets/report_filter_sheet.dart';

class ReportsListPage extends StatefulWidget {
  const ReportsListPage({super.key});

  @override
  State<ReportsListPage> createState() => _ReportsListPageState();
}

class _ReportsListPageState extends State<ReportsListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;
  SeverityLevel? _selectedSeverity;

  @override
  void initState() {
    super.initState();
    _loadReports();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadReports({bool refresh = false}) {
    context.read<ReportBloc>().add(
          LoadReports(
            page: refresh ? 1 : 1,
            type: _selectedType,
            status: _selectedStatus,
            severity: _selectedSeverity,
            search: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
            refresh: refresh,
          ),
        );
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ReportBloc>().state;
      if (state.hasNextPage && !state.isLoadingMore) {
        context.read<ReportBloc>().add(
              LoadReports(
                page: state.currentPage + 1,
                type: _selectedType,
                status: _selectedStatus,
                severity: _selectedSeverity,
                search: _searchController.text.isNotEmpty
                    ? _searchController.text
                    : null,
              ),
            );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReportFilterSheet(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        selectedSeverity: _selectedSeverity,
        onApply: (type, status, severity) {
          setState(() {
            _selectedType = type;
            _selectedStatus = status;
            _selectedSeverity = severity;
          });
          _loadReports(refresh: true);
          Navigator.pop(context);
        },
        onClear: () {
          setState(() {
            _selectedType = null;
            _selectedStatus = null;
            _selectedSeverity = null;
          });
          _loadReports(refresh: true);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Incident Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadReports(refresh: true);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _loadReports(refresh: true),
            ),
          ),

          // Filter Chips
          if (_selectedType != null ||
              _selectedStatus != null ||
              _selectedSeverity != null)
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedType != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_getTypeLabel(_selectedType!)),
                        onDeleted: () {
                          setState(() => _selectedType = null);
                          _loadReports(refresh: true);
                        },
                      ),
                    ),
                  if (_selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_getStatusLabel(_selectedStatus!)),
                        onDeleted: () {
                          setState(() => _selectedStatus = null);
                          _loadReports(refresh: true);
                        },
                      ),
                    ),
                  if (_selectedSeverity != null)
                    Chip(
                      label: Text(_getSeverityLabel(_selectedSeverity!)),
                      onDeleted: () {
                        setState(() => _selectedSeverity = null);
                        _loadReports(refresh: true);
                      },
                    ),
                ],
              ),
            ),

          // Reports List
          Expanded(
            child: BlocConsumer<ReportBloc, ReportState>(
              listener: (context, state) {
                if (state.status == ReportStateStatus.error &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == ReportStateStatus.loading &&
                    state.reports.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reports found',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or search terms',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadReports(refresh: true);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        state.reports.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.reports.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final report = state.reports[index];
                      return ReportCard(
                        report: report,
                        onTap: () => context.push('/reports/${report.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
      ),
    );
  }

  String _getTypeLabel(ReportType type) {
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
        return 'DDoS';
      case ReportType.cyberstalking:
        return 'Cyberstalking';
      case ReportType.hacking:
        return 'Hacking';
      case ReportType.other:
        return 'Other';
    }
  }

  String _getStatusLabel(ReportStatus status) {
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

  String _getSeverityLabel(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.low:
        return 'Low';
      case SeverityLevel.medium:
        return 'Medium';
      case SeverityLevel.high:
        return 'High';
      case SeverityLevel.critical:
        return 'Critical';
    }
  }
}
