import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dilos/features/settings/data/models/notification_config.dart';
import 'package:dilos/features/settings/domain/repositories/settings_repository.dart';
import 'package:dilos/features/settings/presentation/providers/settings_provider.dart';
import 'package:dilos/core/database/isar_provider.dart';
import 'package:dilos/core/notifications/notification_provider.dart';
import 'package:dilos/core/notifications/notification_service.dart';

class FakeSettingsRepository implements SettingsRepository {
  NotificationConfig _config = NotificationConfig();

  @override
  Future<NotificationConfig> getNotificationConfig() async => _config;

  @override
  Future<void> saveNotificationConfig(NotificationConfig config) async {
    _config = config;
  }
}

class FakeNotificationService extends NotificationService {
  bool scheduleCalled = false;
  bool cancelCalled = false;
  int? scheduledHour;
  int? scheduledMinute;
  bool requestPermissionCalled = false;

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalled = true;
    return true;
  }

  @override
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    scheduleCalled = true;
    scheduledHour = hour;
    scheduledMinute = minute;
  }

  @override
  Future<void> cancelDailyNotification() async {
    cancelCalled = true;
  }
}

/// Yükleme tamamlanana kadar bekler (session_provider_test.dart patternı)
Future<void> waitForLoaded(ProviderContainer container) async {
  if (container.read(settingsProvider).status != SettingsStatus.loading) return;
  final completer = Completer<void>();
  final sub = container.listen(settingsProvider, (_, next) {
    if (next.status != SettingsStatus.loading && !completer.isCompleted) {
      completer.complete();
    }
  });
  await completer.future.timeout(const Duration(seconds: 5));
  sub.close();
}

void main() {
  group('SettingsNotifier', () {
    late ProviderContainer container;
    late FakeSettingsRepository fakeRepo;
    late FakeNotificationService fakeNotificationService;

    setUp(() {
      fakeRepo = FakeSettingsRepository();
      fakeNotificationService = FakeNotificationService();
      container = ProviderContainer(overrides: [
        settingsRepositoryProvider.overrideWithValue(fakeRepo),
        notificationServiceProvider.overrideWithValue(fakeNotificationService),
      ]);
    });

    tearDown(() => container.dispose());

    test('başlangıçta loading durumu', () {
      expect(container.read(settingsProvider).status, SettingsStatus.loading);
    });

    test('yükleme sonrası varsayılan değerler', () async {
      await waitForLoaded(container);
      final state = container.read(settingsProvider);
      expect(state.status, SettingsStatus.idle);
      expect(state.hour, 9);
      expect(state.minute, 0);
      expect(state.isEnabled, false);
    });

    test('save ile bildirim zamanlanır', () async {
      await waitForLoaded(container);
      await container.read(settingsProvider.notifier).save(
            hour: 20,
            minute: 30,
            isEnabled: true,
          );
      expect(fakeNotificationService.scheduleCalled, true);
      expect(fakeNotificationService.scheduledHour, 20);
      expect(fakeNotificationService.scheduledMinute, 30);
    });

    test('save ile isEnabled false ise bildirim iptal edilir', () async {
      await waitForLoaded(container);
      await container.read(settingsProvider.notifier).save(
            hour: 20,
            minute: 30,
            isEnabled: false,
          );
      expect(fakeNotificationService.cancelCalled, true);
      expect(fakeNotificationService.scheduleCalled, false);
    });

    test('save sonrası state güncellenir', () async {
      await waitForLoaded(container);
      await container.read(settingsProvider.notifier).save(
            hour: 8,
            minute: 15,
            isEnabled: true,
          );
      final s = container.read(settingsProvider);
      expect(s.status, SettingsStatus.saved);
      expect(s.hour, 8);
      expect(s.minute, 15);
      expect(s.isEnabled, true);
    });

    test("save sonrası repository'e kaydedilir", () async {
      await waitForLoaded(container);
      await container.read(settingsProvider.notifier).save(
            hour: 10,
            minute: 0,
            isEnabled: true,
          );
      final config = await fakeRepo.getNotificationConfig();
      expect(config.hour, 10);
      expect(config.isEnabled, true);
    });

    test('save enabled ise requestPermission çağrılır', () async {
      await waitForLoaded(container);
      await container.read(settingsProvider.notifier).save(
            hour: 9,
            minute: 0,
            isEnabled: true,
          );
      expect(fakeNotificationService.requestPermissionCalled, true);
    });
  });
}
