import '../entities/dashboard_metrics.dart';

class NarrativeService {
  NarrativeService._();

  static String getNarrative(DashboardMetrics metrics) {
    final now = DateTime.now();

    if (metrics.lastActivityDate == null ||
        now.difference(metrics.lastActivityDate!).inDays > 7) {
      return 'Bir süredir ortalıkta yoksun, nasılsın?';
    }

    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      metrics.lastActivityDate!.year,
      metrics.lastActivityDate!.month,
      metrics.lastActivityDate!.day,
    );
    if (lastDay == today) {
      return 'Bugün de kendinle vakit geçirdin.';
    }

    if (metrics.stabilityScore > 0.6) {
      return 'Düzenli bir ritim yakalamışsın.';
    }

    if (metrics.clarityScore > 0.7) {
      return 'Zihnin son zamanlarda oldukça aktif.';
    }

    if (metrics.totalSessions < 3) {
      return 'Henüz başlangıçtasın, devam et.';
    }

    return 'Hayatın zaten güzel.';
  }
}
