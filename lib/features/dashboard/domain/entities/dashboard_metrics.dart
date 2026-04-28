class DashboardMetrics {
  const DashboardMetrics({
    required this.clarityScore,
    required this.stabilityScore,
    required this.explorationScore,
    required this.totalSessions,
    required this.totalJournals,
    required this.totalBrainDumps,
    required this.lastActivityDate,
  });

  final double clarityScore;
  final double stabilityScore;
  final double explorationScore;
  final int totalSessions;
  final int totalJournals;
  final int totalBrainDumps;
  final DateTime? lastActivityDate;

  static const empty = DashboardMetrics(
    clarityScore: 0,
    stabilityScore: 0,
    explorationScore: 0,
    totalSessions: 0,
    totalJournals: 0,
    totalBrainDumps: 0,
    lastActivityDate: null,
  );
}
