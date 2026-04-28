import 'package:isar/isar.dart';

import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/services/dashboard_calculator.dart';
import '../../../brain_dump/data/models/brain_dump_entry.dart';
import '../../../journal/data/models/journal_entry.dart';
import '../../../session/data/models/session_entry.dart';

class IsarDashboardRepository implements DashboardRepository {
  const IsarDashboardRepository(this._isar);
  final Isar _isar;

  @override
  Future<DashboardMetrics> getMetrics() async {
    final sessions =
        await _isar.sessionEntrys.filter().statusEqualTo('completed').findAll();

    final journals = await _isar.journalEntrys.where().findAll();
    final brainDumps = await _isar.brainDumpEntrys.where().findAll();

    return DashboardCalculator.calculate(
      sessionDates: sessions.map((e) => e.createdAt).toList(),
      journalDates: journals.map((e) => e.createdAt).toList(),
      brainDumpDates: brainDumps.map((e) => e.createdAt).toList(),
    );
  }
}
