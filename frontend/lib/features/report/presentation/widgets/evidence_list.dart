import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/report.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';

class EvidenceList extends StatelessWidget {
  final List<Evidence> evidence;
  final String reportId;
  final bool canDelete;

  const EvidenceList({
    super.key,
    required this.evidence,
    required this.reportId,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: evidence.length,
      itemBuilder: (context, index) {
        final item = evidence[index];
        return _buildEvidenceItem(context, item);
      },
    );
  }

  Widget _buildEvidenceItem(BuildContext context, Evidence item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _buildThumbnail(item),
      title: Text(item.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Text(
            _formatFileSize(item.fileSize),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(width: 8),
          if (item.isEncrypted)
            Row(
              children: [
                Icon(Icons.lock, size: 12, color: AppColors.success),
                const SizedBox(width: 2),
                Text(
                  'Encrypted',
                  style: TextStyle(color: AppColors.success, fontSize: 12),
                ),
              ],
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download evidence
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Downloading...')));
            },
          ),
          if (canDelete)
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                _showDeleteConfirmation(context, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(Evidence item) {
    IconData icon;
    Color color;

    if (item.fileType.startsWith('image/')) {
      icon = Icons.image;
      color = Colors.blue;
    } else if (item.fileType.startsWith('video/')) {
      icon = Icons.videocam;
      color = Colors.purple;
    } else if (item.fileType.contains('pdf')) {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (item.fileType.contains('word') ||
        item.fileType.contains('document')) {
      icon = Icons.description;
      color = Colors.blue.shade700;
    } else if (item.fileType.contains('sheet') ||
        item.fileType.contains('excel')) {
      icon = Icons.table_chart;
      color = Colors.green;
    } else if (item.fileType.contains('text')) {
      icon = Icons.text_snippet;
      color = Colors.grey;
    } else {
      icon = Icons.attach_file;
      color = Colors.grey;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Evidence item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Evidence?'),
        content: Text('Are you sure you want to delete "${item.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ReportBloc>().add(
                DeleteEvidence(reportId: reportId, evidenceId: item.id),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
