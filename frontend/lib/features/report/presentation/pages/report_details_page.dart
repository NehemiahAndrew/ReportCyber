import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/report.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/evidence_list.dart';
import '../widgets/report_status_badge.dart';
import '../widgets/severity_badge.dart';

class ReportDetailsPage extends StatefulWidget {
  final String reportId;

  const ReportDetailsPage({super.key, required this.reportId});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(
      LoadReportDetails(reportId: widget.reportId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state.selectedReport?.status == ReportStatus.draft) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.push('/reports/${widget.reportId}/edit');
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              } else if (value == 'share') {
                // Share functionality
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.status == ReportStateStatus.deleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report deleted'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/reports');
          } else if (state.status == ReportStateStatus.submitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Report submitted!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state.status == ReportStateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ReportStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final report = state.selectedReport;
          if (report == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text('Report not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/reports'),
                    child: const Text('Back to Reports'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.title,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SeverityBadge(severity: report.severity),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ReportStatusBadge(status: report.status),
                            const SizedBox(width: 12),
                            Text(
                              '#${report.reportId}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.category,
                              label: report.typeDisplayName,
                            ),
                            const SizedBox(width: 8),
                            if (report.incidentDate != null)
                              _buildInfoChip(
                                icon: Icons.calendar_today,
                                label:
                                    '${report.incidentDate!.day}/${report.incidentDate!.month}/${report.incidentDate!.year}',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                _buildSection(
                  title: 'Description',
                  child: Text(report.description),
                ),
                const SizedBox(height: 16),

                // Affected Systems
                if (report.affectedSystems.isNotEmpty)
                  _buildSection(
                    title: 'Affected Systems',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: report.affectedSystems
                          .map((system) => Chip(label: Text(system)))
                          .toList(),
                    ),
                  ),
                if (report.affectedSystems.isNotEmpty)
                  const SizedBox(height: 16),

                // Threat Information
                if (report.attackerInfo != null ||
                    report.suspiciousUrls.isNotEmpty ||
                    report.suspiciousEmails.isNotEmpty ||
                    report.suspiciousIps.isNotEmpty)
                  _buildSection(
                    title: 'Threat Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (report.attackerInfo != null) ...[
                          Text(
                            'Attacker Info:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(report.attackerInfo!),
                          const SizedBox(height: 12),
                        ],
                        if (report.suspiciousUrls.isNotEmpty) ...[
                          Text(
                            'Suspicious URLs:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          ...report.suspiciousUrls.map(
                            (url) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      url,
                                      style: TextStyle(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (report.suspiciousEmails.isNotEmpty) ...[
                          Text(
                            'Suspicious Emails:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          ...report.suspiciousEmails.map(
                            (email) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(email),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (report.suspiciousIps.isNotEmpty) ...[
                          Text(
                            'Suspicious IP Addresses:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          ...report.suspiciousIps.map(
                            (ip) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.computer,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(ip),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Financial Loss
                if (report.financialLoss != null && report.financialLoss! > 0)
                  _buildSection(
                    title: 'Financial Impact',
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          '${report.currency ?? 'USD'} ${report.financialLoss!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (report.financialLoss != null && report.financialLoss! > 0)
                  const SizedBox(height: 16),

                // Evidence
                if (report.evidence.isNotEmpty)
                  _buildSection(
                    title: 'Evidence',
                    child: EvidenceList(
                      evidence: report.evidence,
                      reportId: report.id,
                      canDelete: report.status == ReportStatus.draft,
                    ),
                  ),
                const SizedBox(height: 16),

                // Voting
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildVoteButton(
                          icon: Icons.thumb_up,
                          count: report.upvotes,
                          isActive: report.hasUpvoted,
                          onPressed: () {
                            context.read<ReportBloc>().add(
                              UpvoteReport(reportId: report.id),
                            );
                          },
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        _buildVoteButton(
                          icon: Icons.thumb_down,
                          count: report.downvotes,
                          isActive: report.hasDownvoted,
                          onPressed: () {
                            context.read<ReportBloc>().add(
                              DownvoteReport(reportId: report.id),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button for Drafts
                if (report.status == ReportStatus.draft)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.status == ReportStateStatus.submitting
                          ? null
                          : () {
                              context.read<ReportBloc>().add(
                                SubmitReport(reportId: report.id),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state.status == ReportStateStatus.submitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit Report'),
                    ),
                  ),

                // Timestamps
                const SizedBox(height: 24),
                Text(
                  'Created: ${_formatDate(report.createdAt)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Updated: ${_formatDate(report.updatedAt)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }

  Widget _buildVoteButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report?'),
        content: const Text(
          'Are you sure you want to delete this report? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<ReportBloc>().add(
                DeleteReport(reportId: widget.reportId),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
