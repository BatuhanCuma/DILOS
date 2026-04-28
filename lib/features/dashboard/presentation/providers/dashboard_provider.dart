import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dilos/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dilos/features/dashboard/domain/services/narrative_service.dart';
import 'package:dilos/core/database/isar_provider.dart';

final dashboardMetricsProvider =
    FutureProvider.autoDispose<DashboardMetrics>((ref) async {
  final repo = await ref.watch(dashboardRepositoryProvider.future);
  return repo.getMetrics();
});

final narrativeProvider = Provider.autoDispose<String>((ref) {
  final metricsAsync = ref.watch(dashboardMetricsProvider);
  return metricsAsync.when(
    data: NarrativeService.getNarrative,
    loading: () => '',
    error: (_, __) => 'Hayatın zaten güzel.',
  );
});
