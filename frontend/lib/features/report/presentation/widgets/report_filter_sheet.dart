import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';

class ReportFilterSheet extends StatefulWidget {
  final ReportType? selectedType;
  final ReportStatus? selectedStatus;
  final SeverityLevel? selectedSeverity;
  final void Function(ReportType?, ReportStatus?, SeverityLevel?) onApply;
  final VoidCallback onClear;

  const ReportFilterSheet({
    super.key,
    this.selectedType,
    this.selectedStatus,
    this.selectedSeverity,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends State<ReportFilterSheet> {
  ReportType? _type;
  ReportStatus? _status;
  SeverityLevel? _severity;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _status = widget.selectedStatus;
    _severity = widget.selectedSeverity;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Reports',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: widget.onClear,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filters
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Report Type
                    Text(
                      'Incident Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ReportType.values.map((type) {
                        final isSelected = _type == type;
                        return FilterChip(
                          label: Text(_getTypeLabel(type)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _type = selected ? type : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Status
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ReportStatus.values.map((status) {
                        final isSelected = _status == status;
                        return FilterChip(
                          label: Text(_getStatusLabel(status)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _status = selected ? status : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Severity
                    Text(
                      'Severity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SeverityLevel.values.map((severity) {
                        final isSelected = _severity == severity;
                        return FilterChip(
                          label: Text(_getSeverityLabel(severity)),
                          selected: isSelected,
                          selectedColor: _getSeverityColor(
                            severity,
                          ).withOpacity(0.2),
                          onSelected: (selected) {
                            setState(() {
                              _severity = selected ? severity : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Apply Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_type, _status, _severity);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
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

  Color _getSeverityColor(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.low:
        return Colors.green;
      case SeverityLevel.medium:
        return Colors.orange;
      case SeverityLevel.high:
        return Colors.deepOrange;
      case SeverityLevel.critical:
        return Colors.red;
    }
  }
}
