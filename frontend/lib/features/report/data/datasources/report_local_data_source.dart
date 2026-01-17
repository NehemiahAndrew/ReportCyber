import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/report.dart';

abstract class ReportLocalDataSource {
  Future<void> cacheDraft(Report report);
  Future<Report?> getCachedDraft();
  Future<void> clearDraft();
  Future<void> cacheReports(List<Report> reports);
  Future<List<Report>> getCachedReports();
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  static const String _draftBoxName = 'report_draft';
  static const String _reportsBoxName = 'cached_reports';
  static const String _draftKey = 'current_draft';
  static const String _reportsKey = 'reports';

  @override
  Future<void> cacheDraft(Report report) async {
    final box = await Hive.openBox(_draftBoxName);
    await box.put(_draftKey, json.encode(report.toJson()));
  }

  @override
  Future<Report?> getCachedDraft() async {
    final box = await Hive.openBox(_draftBoxName);
    final draftJson = box.get(_draftKey);
    if (draftJson != null) {
      return Report.fromJson(json.decode(draftJson));
    }
    return null;
  }

  @override
  Future<void> clearDraft() async {
    final box = await Hive.openBox(_draftBoxName);
    await box.delete(_draftKey);
  }

  @override
  Future<void> cacheReports(List<Report> reports) async {
    final box = await Hive.openBox(_reportsBoxName);
    final reportsJson = reports.map((r) => r.toJson()).toList();
    await box.put(_reportsKey, json.encode(reportsJson));
  }

  @override
  Future<List<Report>> getCachedReports() async {
    final box = await Hive.openBox(_reportsBoxName);
    final reportsJson = box.get(_reportsKey);
    if (reportsJson != null) {
      final List<dynamic> decoded = json.decode(reportsJson);
      return decoded.map((r) => Report.fromJson(r)).toList();
    }
    return [];
  }
}
