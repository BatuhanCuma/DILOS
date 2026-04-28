import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dilos/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dilos/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dilos/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dilos/core/database/isar_provider.dart';

class FakeDashboardRepository implements DashboardRepository {
  final DashboardMetrics _metrics;
  FakeDashboardRepository(this._metrics);

  @override
  Future<DashboardMetrics> getMetrics() async => _metrics;
}

void main() {
  group('dashboardMetricsProvider', () {
    test('FakeRepository verisini yükler', () async {
      final fakeMetrics = DashboardMetrics(
        clarityScore: 0.6,
        stabilityScore: 0.4,
        explorationScore: 0,
        totalSessions: 10,
        totalJournals: 5,
        totalBrainDumps: 3,
        lastActivityDate: DateTime.now(),
      );

      final container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWithValue(
          FakeDashboardRepository(fakeMetrics),
        ),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(dashboardMetricsProvider.future);
      expect(result.totalSessions, 10);
      expect(result.clarityScore, 0.6);
    });

    test('narrativeProvider doğru cümleyi döner', () async {
      final fakeMetrics = DashboardMetrics(
        clarityScore: 0.5,
        stabilityScore: 0.5,
        explorationScore: 0,
        totalSessions: 5,
        totalJournals: 0,
        totalBrainDumps: 0,
        lastActivityDate: DateTime.now(),
      );

      final container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWithValue(
          FakeDashboardRepository(fakeMetrics),
        ),
      ]);
      addTearDown(container.dispose);

      await container.read(dashboardMetricsProvider.future);
      final narrative = container.read(narrativeProvider);
      expect(narrative, 'Bugün de kendinle vakit geçirdin.');
    });
  });
}
