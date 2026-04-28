import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../features/session/data/models/session_entry.dart';
import '../../features/session/data/repositories/session_repository_impl.dart';
import '../../features/session/domain/repositories/session_repository.dart';
import '../../features/brain_dump/data/models/brain_dump_entry.dart';
import '../../features/brain_dump/data/repositories/brain_dump_repository_impl.dart';
import '../../features/brain_dump/domain/repositories/brain_dump_repository.dart';
import '../../features/journal/data/models/journal_entry.dart';
import '../../features/journal/data/repositories/journal_repository_impl.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/settings/data/models/notification_config.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import 'isar_service.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  return IsarService.getInstance([
    SessionEntrySchema,
    BrainDumpEntrySchema,
    JournalEntrySchema,
    NotificationConfigSchema,
  ]);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => IsarSessionRepository(isar),
    loading: () => throw StateError('Isar henüz hazır değil'),
    error: (e, _) => throw StateError('Isar hatası: $e'),
  );
});

final brainDumpRepositoryProvider = Provider<BrainDumpRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => IsarBrainDumpRepository(isar),
    loading: () => throw StateError('Isar henüz hazır değil'),
    error: (e, _) => throw StateError('Isar hatası: $e'),
  );
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => IsarJournalRepository(isar),
    loading: () => throw StateError('Isar henüz hazır değil'),
    error: (e, _) => throw StateError('Isar hatası: $e'),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => IsarSettingsRepository(isar),
    loading: () => throw StateError('Isar henüz hazır değil'),
    error: (e, _) => throw StateError('Isar hatası: $e'),
  );
});

final dashboardRepositoryProvider =
    FutureProvider<DashboardRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return IsarDashboardRepository(isar);
});
