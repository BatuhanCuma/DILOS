import '../entities/dashboard_metrics.dart';

class DashboardCalculator {
  DashboardCalculator._();

  static DashboardMetrics calculate({
    required List<DateTime> sessionDates,
    required List<DateTime> journalDates,
    required List<DateTime> brainDumpDates,
  }) {
    final totalSessions = sessionDates.length;
    final totalJournals = journalDates.length;
    final totalBrainDumps = brainDumpDates.length;

    final clarityRaw = totalSessions * 3 + totalJournals * 2 + totalBrainDumps;
    final clarityScore = (clarityRaw / 50).clamp(0.0, 1.0);

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentDates = [
      ...sessionDates,
      ...journalDates,
      ...brainDumpDates,
    ].where((d) => d.isAfter(thirtyDaysAgo));

    final uniqueDays = recentDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    final stabilityScore = (uniqueDays.length / 30).clamp(0.0, 1.0);

    final allDates = [...sessionDates, ...journalDates, ...brainDumpDates];
    final lastActivityDate =
        allDates.isEmpty ? null : (List.of(allDates)..sort()).last;

    return DashboardMetrics(
      clarityScore: clarityScore,
      stabilityScore: stabilityScore,
      explorationScore: 0,
      totalSessions: totalSessions,
      totalJournals: totalJournals,
      totalBrainDumps: totalBrainDumps,
      lastActivityDate: lastActivityDate,
    );
  }
}
