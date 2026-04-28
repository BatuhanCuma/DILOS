import 'package:flutter_test/flutter_test.dart';
import 'package:dilos/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dilos/features/dashboard/domain/services/narrative_service.dart';

DashboardMetrics _metrics({
  double clarity = 0.5,
  double stability = 0.5,
  int sessions = 5,
  DateTime? lastActivity,
}) =>
    DashboardMetrics(
      clarityScore: clarity,
      stabilityScore: stability,
      explorationScore: 0,
      totalSessions: sessions,
      totalJournals: 0,
      totalBrainDumps: 0,
      lastActivityDate: lastActivity,
    );

void main() {
  group('NarrativeService', () {
    test('lastActivityDate null → "Bir süredir ortalıkta yoksun"', () {
      final result = NarrativeService.getNarrative(
        _metrics(lastActivity: null),
      );
      expect(result, 'Bir süredir ortalıkta yoksun, nasılsın?');
    });

    test('7 günden eski aktivite → "Bir süredir ortalıkta yoksun"', () {
      final old = DateTime.now().subtract(const Duration(days: 8));
      final result = NarrativeService.getNarrative(
        _metrics(lastActivity: old),
      );
      expect(result, 'Bir süredir ortalıkta yoksun, nasılsın?');
    });

    test('bugün aktivite var → "Bugün de kendinle vakit geçirdin"', () {
      final result = NarrativeService.getNarrative(
        _metrics(lastActivity: DateTime.now()),
      );
      expect(result, 'Bugün de kendinle vakit geçirdin.');
    });

    test('stability > 0.6 → "Düzenli bir ritim yakalamışsın"', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = NarrativeService.getNarrative(
        _metrics(stability: 0.65, lastActivity: yesterday),
      );
      expect(result, 'Düzenli bir ritim yakalamışsın.');
    });

    test('clarity > 0.7 → "Zihnin son zamanlarda oldukça aktif"', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = NarrativeService.getNarrative(
        _metrics(clarity: 0.75, stability: 0.3, lastActivity: yesterday),
      );
      expect(result, 'Zihnin son zamanlarda oldukça aktif.');
    });

    test('totalSessions < 3 → "Henüz başlangıçtasın"', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = NarrativeService.getNarrative(
        _metrics(
          sessions: 2,
          clarity: 0.1,
          stability: 0.1,
          lastActivity: yesterday,
        ),
      );
      expect(result, 'Henüz başlangıçtasın, devam et.');
    });

    test('hiçbir koşul yok → default cümle', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = NarrativeService.getNarrative(
        _metrics(
          clarity: 0.4,
          stability: 0.3,
          sessions: 5,
          lastActivity: yesterday,
        ),
      );
      expect(result, 'Hayatın zaten güzel.');
    });
  });
}
