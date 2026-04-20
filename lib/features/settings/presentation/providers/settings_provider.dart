import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_config.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../../core/notifications/notification_provider.dart';
import '../../../../core/notifications/notification_service.dart';

enum SettingsStatus { loading, idle, saving, saved, error }

class SettingsState {
  const SettingsState({
    required this.status,
    required this.hour,
    required this.minute,
    required this.isEnabled,
    this.errorMessage,
  });

  const SettingsState.initial()
      : status = SettingsStatus.loading,
        hour = 9,
        minute = 0,
        isEnabled = false,
        errorMessage = null;

  final SettingsStatus status;
  final int hour;
  final int minute;
  final bool isEnabled;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    int? hour,
    int? minute,
    bool? isEnabled,
    String? errorMessage,
  }) =>
      SettingsState(
        status: status ?? this.status,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        isEnabled: isEnabled ?? this.isEnabled,
        errorMessage: errorMessage,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._settingsRepo, this._notificationService)
      : super(const SettingsState.initial()) {
    _load();
  }

  final SettingsRepository _settingsRepo;
  final NotificationService _notificationService;

  Future<void> _load() async {
    try {
      final config = await _settingsRepo.getNotificationConfig();
      state = state.copyWith(
        status: SettingsStatus.idle,
        hour: config.hour,
        minute: config.minute,
        isEnabled: config.isEnabled,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        status: SettingsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> save({
    required int hour,
    required int minute,
    required bool isEnabled,
  }) async {
    state = state.copyWith(status: SettingsStatus.saving);
    try {
      final config = NotificationConfig()
        ..id = 1
        ..hour = hour
        ..minute = minute
        ..isEnabled = isEnabled;
      await _settingsRepo.saveNotificationConfig(config);

      if (isEnabled) {
        await _notificationService.requestPermission();
        await _notificationService.scheduleDailyNotification(
          hour: hour,
          minute: minute,
        );
      } else {
        await _notificationService.cancelDailyNotification();
      }

      state = state.copyWith(
        status: SettingsStatus.saved,
        hour: hour,
        minute: minute,
        isEnabled: isEnabled,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        status: SettingsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final settingsProvider =
    StateNotifierProvider.autoDispose<SettingsNotifier, SettingsState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return SettingsNotifier(repo, notificationService);
});
