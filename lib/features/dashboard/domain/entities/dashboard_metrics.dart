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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardMetrics &&
          clarityScore == other.clarityScore &&
          stabilityScore == other.stabilityScore &&
          explorationScore == other.explorationScore &&
          totalSessions == other.totalSessions &&
          totalJournals == other.totalJournals &&
          totalBrainDumps == other.totalBrainDumps &&
          lastActivityDate == other.lastActivityDate;

  @override
  int get hashCode => Object.hash(
        clarityScore,
        stabilityScore,
        explorationScore,
        totalSessions,
        totalJournals,
        totalBrainDumps,
        lastActivityDate,
      );
}
