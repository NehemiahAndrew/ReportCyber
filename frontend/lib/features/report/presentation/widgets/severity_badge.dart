import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';

class SeverityBadge extends StatelessWidget {
  final SeverityLevel severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getLabel(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLabel() {
    switch (severity) {
      case SeverityLevel.low:
        return 'LOW';
      case SeverityLevel.medium:
        return 'MEDIUM';
      case SeverityLevel.high:
        return 'HIGH';
      case SeverityLevel.critical:
        return 'CRITICAL';
    }
  }

  Color _getColor() {
    switch (severity) {
      case SeverityLevel.low:
        return Colors.green;
      case SeverityLevel.medium:
        return Colors.orange;
      case SeverityLevel.high:
        return Colors.deepOrange;
      case SeverityLevel.critical:
        return Colors.red.shade900;
    }
  }
}
