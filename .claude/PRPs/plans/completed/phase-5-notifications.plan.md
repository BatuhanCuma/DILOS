# Plan: Phase 5 — Notifications

## Summary
Kullanıcının seçtiği saatte günlük bildirim gönderilir; bildirime tıklandığında uygulama doğrudan seans ekranına yönlendirir. `flutter_local_notifications` + `timezone` + `flutter_timezone` paketleri eklenir; Isar'da `NotificationConfig` singleton kaydedilir; Ayarlar ekranında saat seçici sunulur.

## User Story
As a burnout user, I want to receive a daily reminder notification at my chosen time, so that I open the app and start a session without having to remember it myself.

## Problem → Solution
No notification system → Daily scheduled local notification with one-tap session launch

## Metadata
- **Complexity**: Large
- **Source PRD**: `.claude/PRPs/prds/dilos-mvp.prd.md`
- **PRD Phase**: Faz 5 — Notifications
- **Estimated Files**: 16

---

## UX Design

### Before
```
┌──────────────────────────────┐
│  DILOS                       │
│  Hayatın zaten güzel.        │
│                              │
│  [Seans Başlat]              │
│  [Brain Dump]                │
│  [Journal]                   │
│                              │
│  (No way to set reminders)   │
└──────────────────────────────┘
```

### After
```
┌──────────────────────────────┐
│  DILOS                    ⚙  │  ← gear icon → settings
│  Hayatın zaten güzel.        │
│                              │
│  [Seans Başlat]              │
│  [Brain Dump]                │
│  [Journal]                   │
│                              │
│  ─── Settings Screen ───     │
│  Günlük bildirim     [ON]    │
│  Saat: 09:00         [>]     │
│  [Kaydet]                    │
│                              │
│  ─── Notification ───        │
│  "DILOS - Seans zamanı"      │
│  Tap → session launches ✓    │
└──────────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| HomeScreen | No settings access | Gear icon (top-right) | Opens `/settings` |
| Settings | Does not exist | Time picker + toggle | Saves to Isar |
| Daily notification | None | Fires at chosen time | Turkish text |
| Notification tap | N/A | Direct session launch | go_router push to `/session` |
| App terminated + notification tap | N/A | Session launches via launch details | Handled in main.dart |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/core/database/isar_provider.dart` | all | Pattern to add new schema + provider |
| P0 | `lib/features/session/data/models/session_entry.dart` | all | Isar `@collection` model pattern |
| P0 | `lib/features/session/data/repositories/session_repository_impl.dart` | all | Isar writeTxn + put pattern |
| P0 | `lib/features/session/domain/repositories/session_repository.dart` | all | `abstract interface class` pattern |
| P0 | `lib/features/brain_dump/presentation/providers/brain_dump_provider.dart` | all | StateNotifier + autoDispose pattern |
| P1 | `lib/main.dart` | all | Startup — switching to UncontrolledProviderScope |
| P1 | `lib/features/home/presentation/screens/home_screen.dart` | all | Where to add gear icon + ref.listen pattern |
| P1 | `lib/core/router/app_routes.dart` | all | Route constants pattern |
| P1 | `lib/core/router/app_router.dart` | all | GoRoute registration pattern |
| P2 | `lib/core/ai/ai_provider.dart` | all | Service + Provider file pattern |
| P2 | `test/features/brain_dump/providers/brain_dump_provider_test.dart` | all | FakeRepo + ProviderContainer test pattern |

## External Documentation

| Topic | Source | Key Takeaway |
|---|---|---|
| flutter_local_notifications | pub.dev/packages/flutter_local_notifications | Use `zonedSchedule` + `matchDateTimeComponents: DateTimeComponents.time` for daily repeat |
| timezone | pub.dev/packages/timezone | Must call `tz.initializeTimeZones()` before any `TZDateTime` usage |
| flutter_timezone | pub.dev/packages/flutter_timezone | `FlutterTimezone.getLocalTimezone()` returns IANA name; pass to `tz.setLocalLocation` |
| Android permissions | developer.android.com | `RECEIVE_BOOT_COMPLETED` for boot persistence; `POST_NOTIFICATIONS` for Android 13+ |

---

## Patterns to Mirror

### ISAR_COLLECTION_MODEL
```dart
// SOURCE: lib/features/session/data/models/session_entry.dart:1-25
import 'package:isar/isar.dart';
part 'session_entry.g.dart';

@collection
class SessionEntry {
  Id id = Isar.autoIncrement;
  late DateTime createdAt;
  late String status;
}
```
**For NotificationConfig**: use `Id id = 1` (singleton — always id=1, upserted on save)

### ISAR_WRITE_TXN
```dart
// SOURCE: lib/features/session/data/repositories/session_repository_impl.dart:22-25
await _isar.writeTxn(() async {
  await _isar.sessionEntrys.put(entry);
});
```
**Collection accessor naming**: Isar lowercases class name + adds "s". `NotificationConfig` → `notificationConfigs`.

### ISAR_PROVIDER
```dart
// SOURCE: lib/core/database/isar_provider.dart:22-29
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => IsarSessionRepository(isar),
    loading: () => throw StateError('Isar henüz hazır değil'),
    error: (e, _) => throw StateError('Isar hatası: $e'),
  );
});
```

### ABSTRACT_INTERFACE_REPOSITORY
```dart
// SOURCE: lib/features/session/domain/repositories/session_repository.dart:1-11
abstract interface class SessionRepository {
  Future<List<SessionQuestion>> getQuestions();
  Future<void> saveSession(SessionEntry entry);
}
```

### STATE_NOTIFIER_PATTERN
```dart
// SOURCE: lib/features/brain_dump/presentation/providers/brain_dump_provider.dart:36-85
enum BrainDumpStatus { idle, saving, saved, error }

class BrainDumpState {
  const BrainDumpState({required this.status, required this.recentEntries, this.errorMessage});
  const BrainDumpState.initial() : status = BrainDumpStatus.idle, recentEntries = const [], errorMessage = null;
  BrainDumpState copyWith({...}) => BrainDumpState(...);
}

class BrainDumpNotifier extends StateNotifier<BrainDumpState> {
  BrainDumpNotifier(this._repository) : super(const BrainDumpState.initial()) { _loadRecent(); }
  final BrainDumpRepository _repository;
}

final brainDumpProvider = StateNotifierProvider.autoDispose<BrainDumpNotifier, BrainDumpState>((ref) {
  final repo = ref.watch(brainDumpRepositoryProvider);
  return BrainDumpNotifier(repo);
});
```

### ERROR_HANDLING
```dart
// SOURCE: lib/features/brain_dump/presentation/providers/brain_dump_provider.dart:47-52
} on Exception catch (e) {
  state = state.copyWith(
    status: BrainDumpStatus.error,
    errorMessage: e.toString(),
  );
}
```

### SERVICE_PROVIDER_PATTERN
```dart
// SOURCE: lib/core/ai/ai_provider.dart (full file)
const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
final aiTaggingServiceProvider = Provider<AiTaggingService>((ref) =>
  AiTaggingService(apiKey: _geminiApiKey));
```

### TEST_STRUCTURE
```dart
// SOURCE: test/features/brain_dump/providers/brain_dump_provider_test.dart:8-70
class FakeBrainDumpRepository implements BrainDumpRepository {
  final List<BrainDumpEntry> entries = [];
  @override Future<void> saveEntry(BrainDumpEntry entry) async => entries.add(entry);
}

void main() {
  group('BrainDumpNotifier', () {
    late ProviderContainer container;
    late FakeBrainDumpRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeBrainDumpRepository();
      container = ProviderContainer(overrides: [
        brainDumpRepositoryProvider.overrideWithValue(fakeRepo),
      ]);
    });

    tearDown(() => container.dispose());

    test('başlangıç durumu idle ve boş liste', () { ... });
  });
}
```

### CONSUMER_WIDGET_SCREEN
```dart
// SOURCE: lib/features/home/presentation/screens/home_screen.dart:8-104
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(...),
        ),
      ),
    );
  }
}
```

### CONSUMER_STATEFUL_WIDGET
```dart
// SOURCE: lib/features/brain_dump/presentation/screens/brain_dump_screen.dart:8-154
class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});
  @override
  ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
}
class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> {
  @override
  void initState() { super.initState(); ... }
  @override
  void dispose() { ...; super.dispose(); }
}
```

### GESTURE_BUTTON
```dart
// SOURCE: lib/features/home/presentation/screens/home_screen.dart:32-50
GestureDetector(
  onTap: () => context.go(AppRoutes.session),
  child: Container(
    width: double.infinity, height: 56,
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: Text('Seans Başlat', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16)),
  ),
),
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `pubspec.yaml` | UPDATE | Add flutter_local_notifications, timezone, flutter_timezone |
| `lib/core/notifications/notification_service.dart` | CREATE | Notification scheduling + permission service |
| `lib/core/notifications/notification_provider.dart` | CREATE | notificationServiceProvider + notificationTappedProvider |
| `lib/features/settings/data/models/notification_config.dart` | CREATE | Isar singleton model for notification prefs |
| `lib/features/settings/data/models/notification_config.g.dart` | AUTO-GEN | build_runner output |
| `lib/features/settings/domain/repositories/settings_repository.dart` | CREATE | Abstract interface |
| `lib/features/settings/data/repositories/settings_repository_impl.dart` | CREATE | Isar implementation |
| `lib/features/settings/presentation/providers/settings_provider.dart` | CREATE | StateNotifier for settings state |
| `lib/features/settings/presentation/screens/settings_screen.dart` | CREATE | Settings UI with time picker |
| `lib/core/database/isar_provider.dart` | UPDATE | Add NotificationConfigSchema + settingsRepositoryProvider |
| `lib/core/router/app_routes.dart` | UPDATE | Add `settings = '/settings'` constant |
| `lib/core/router/app_router.dart` | UPDATE | Register settings route |
| `lib/features/home/presentation/screens/home_screen.dart` | UPDATE | Gear icon + ref.listen for notification tap |
| `lib/main.dart` | UPDATE | ProviderContainer + notification init + UncontrolledProviderScope |
| `android/app/src/main/AndroidManifest.xml` | UPDATE | POST_NOTIFICATIONS + RECEIVE_BOOT_COMPLETED permissions |
| `test/features/settings/providers/settings_provider_test.dart` | CREATE | SettingsNotifier unit tests |

## NOT Building
- Widget/app shortcut on home screen (Android) — PRD says "could", too complex for MVP
- iOS background notification actions with custom buttons
- Notification analytics or tracking
- Multiple notification schedules (one daily reminder is sufficient for MVP hypothesis)
- `SCHEDULE_EXACT_ALARM` permission — using `inexactAllowWhileIdle` for MVP (avoids permission dialog)

---

## Step-by-Step Tasks

### Task 1: pubspec.yaml — Add notification packages
- **ACTION**: Add 3 packages to `dependencies`
- **IMPLEMENT**:
  ```yaml
  # Notifications
  flutter_local_notifications: ^17.2.0
  timezone: ^0.9.4
  flutter_timezone: ^1.0.4
  ```
- **MIRROR**: ISAR_COLLECTION_MODEL (package addition style — under `# AI` comment, add `# Notifications` group)
- **IMPORTS**: N/A
- **GOTCHA**: `flutter_local_notifications` requires `timezone` for `zonedSchedule`. Both must be added together.
- **VALIDATE**: `flutter pub get` succeeds with no conflicts

### Task 2: NotificationConfig Isar model
- **ACTION**: Create `lib/features/settings/data/models/notification_config.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:isar/isar.dart';
  part 'notification_config.g.dart';

  @collection
  class NotificationConfig {
    Id id = 1; // Singleton — always upsert with id=1
    int hour = 9;
    int minute = 0;
    bool isEnabled = false;
  }
  ```
- **MIRROR**: ISAR_COLLECTION_MODEL
- **IMPORTS**: `package:isar/isar.dart`
- **GOTCHA**: `Id id = 1` (not `Isar.autoIncrement`) makes it a singleton. Every `put()` will upsert the same record. No `late` needed — fields have default values.
- **VALIDATE**: File compiles without errors (will fail until build_runner runs — that's expected)

### Task 3: Run build_runner to generate notification_config.g.dart
- **ACTION**: Run `dart run build_runner build --delete-conflicting-outputs` from project root
- **IMPLEMENT**: Shell command
- **MIRROR**: N/A (build step)
- **IMPORTS**: N/A
- **GOTCHA**: Must run from project root (where `pubspec.yaml` is). If it fails with "could not find a file", ensure `part 'notification_config.g.dart'` is in the model file.
- **VALIDATE**: `lib/features/settings/data/models/notification_config.g.dart` is created; `flutter analyze` passes

### Task 4: SettingsRepository interface
- **ACTION**: Create `lib/features/settings/domain/repositories/settings_repository.dart`
- **IMPLEMENT**:
  ```dart
  import '../../data/models/notification_config.dart';

  abstract interface class SettingsRepository {
    Future<NotificationConfig> getNotificationConfig();
    Future<void> saveNotificationConfig(NotificationConfig config);
  }
  ```
- **MIRROR**: ABSTRACT_INTERFACE_REPOSITORY
- **IMPORTS**: `../../data/models/notification_config.dart`
- **GOTCHA**: `getNotificationConfig()` returns non-nullable — the impl must return a default if none exists (create a new `NotificationConfig()` with defaults)
- **VALIDATE**: `flutter analyze` passes

### Task 5: SettingsRepository Isar implementation
- **ACTION**: Create `lib/features/settings/data/repositories/settings_repository_impl.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:isar/isar.dart';
  import '../../domain/repositories/settings_repository.dart';
  import '../models/notification_config.dart';

  class IsarSettingsRepository implements SettingsRepository {
    const IsarSettingsRepository(this._isar);
    final Isar _isar;

    @override
    Future<NotificationConfig> getNotificationConfig() async {
      return await _isar.notificationConfigs.get(1) ?? NotificationConfig();
    }

    @override
    Future<void> saveNotificationConfig(NotificationConfig config) async {
      await _isar.writeTxn(() async {
        await _isar.notificationConfigs.put(config);
      });
    }
  }
  ```
- **MIRROR**: ISAR_WRITE_TXN
- **IMPORTS**: `package:isar/isar.dart`, relative domain + model imports
- **GOTCHA**: Collection accessor is `notificationConfigs` (Isar lowercases `NotificationConfig` → `notificationConfig` + adds `s`). Verify from the generated `.g.dart` file after build_runner.
- **VALIDATE**: `flutter analyze` passes

### Task 6: Update isar_provider.dart — add NotificationConfig schema + settingsRepositoryProvider
- **ACTION**: Update `lib/core/database/isar_provider.dart`
- **IMPLEMENT**:
  - Add imports for `NotificationConfig`, `SettingsRepository`, `IsarSettingsRepository`
  - Add `NotificationConfigSchema` to the `IsarService.getInstance` schemas list
  - Add `settingsRepositoryProvider` following the exact same pattern as existing providers
  ```dart
  // Add to imports:
  import '../../features/settings/data/models/notification_config.dart';
  import '../../features/settings/data/repositories/settings_repository_impl.dart';
  import '../../features/settings/domain/repositories/settings_repository.dart';

  // Update IsarService.getInstance call:
  return IsarService.getInstance([
    SessionEntrySchema,
    BrainDumpEntrySchema,
    JournalEntrySchema,
    NotificationConfigSchema,   // ← ADD
  ]);

  // Add at end of file:
  final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
    final isarAsync = ref.watch(isarProvider);
    return isarAsync.when(
      data: (isar) => IsarSettingsRepository(isar),
      loading: () => throw StateError('Isar henüz hazır değil'),
      error: (e, _) => throw StateError('Isar hatası: $e'),
    );
  });
  ```
- **MIRROR**: ISAR_PROVIDER
- **GOTCHA**: Adding a new schema to Isar after data already exists requires either clearing the DB or using Isar migration. For development/MVP, clearing app data is acceptable. The schema list must include ALL schemas every time — Isar opens with all registered schemas.
- **VALIDATE**: `flutter analyze` passes

### Task 7: NotificationService
- **ACTION**: Create `lib/core/notifications/notification_service.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  import 'package:timezone/timezone.dart' as tz;
  import 'package:timezone/data/latest_all.dart' as tz;
  import 'package:flutter_timezone/flutter_timezone.dart';

  const int _dailyNotificationId = 0;
  const String _channelId = 'dilos_daily';
  const String _channelName = 'Günlük DILOS Hatırlatıcısı';

  class NotificationService {
    final FlutterLocalNotificationsPlugin _plugin =
        FlutterLocalNotificationsPlugin();

    Future<void> initialize({void Function()? onTap}) async {
      tz.initializeTimeZones();
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone));

      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (_) => onTap?.call(),
      );
    }

    Future<bool> wasLaunchedFromNotification() async {
      final details = await _plugin.getNotificationAppLaunchDetails();
      return details?.didNotificationLaunchApp ?? false;
    }

    Future<bool> requestPermission() async {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final androidGranted = await android?.requestNotificationsPermission() ?? true;
      final iosGranted = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;

      return androidGranted && iosGranted;
    }

    Future<void> scheduleDailyNotification({
      required int hour,
      required int minute,
    }) async {
      await _plugin.cancel(_dailyNotificationId);

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Günlük seans hatırlatıcısı',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        _dailyNotificationId,
        'DILOS — Seans zamanı',
        'Bugün nasılsın? Kısa bir seans seni bekliyor.',
        _nextInstanceOfTime(hour, minute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    Future<void> cancelDailyNotification() async {
      await _plugin.cancel(_dailyNotificationId);
    }

    tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }
  }
  ```
- **MIRROR**: SERVICE_PROVIDER_PATTERN
- **IMPORTS**: `flutter_local_notifications`, `timezone`, `flutter_timezone`
- **GOTCHA**: `tz.initializeTimeZones()` must be called before any `TZDateTime` usage. `FlutterTimezone.getLocalTimezone()` is async — must be awaited inside `initialize()`. The `@mipmap/ic_launcher` icon must exist in the Android project (it does — it's the default Flutter icon).
- **VALIDATE**: `flutter analyze` passes

### Task 8: notification_provider.dart
- **ACTION**: Create `lib/core/notifications/notification_provider.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'notification_service.dart';

  final notificationServiceProvider = Provider<NotificationService>((ref) {
    return NotificationService();
  });

  /// true = a notification was tapped and the app should navigate to session
  final notificationTappedProvider = StateProvider<bool>((ref) => false);
  ```
- **MIRROR**: SERVICE_PROVIDER_PATTERN
- **IMPORTS**: `flutter_riverpod`, `notification_service.dart`
- **GOTCHA**: `notificationTappedProvider` is a `StateProvider<bool>` (not autoDispose) — it must persist at app level to survive navigation. The consumer (HomeScreen) must reset it to `false` after consuming.
- **VALIDATE**: `flutter analyze` passes

### Task 9: SettingsProvider
- **ACTION**: Create `lib/features/settings/presentation/providers/settings_provider.dart`
- **IMPLEMENT**:
  ```dart
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

    Future<void> save({required int hour, required int minute, required bool isEnabled}) async {
      state = state.copyWith(status: SettingsStatus.saving);
      try {
        final config = NotificationConfig()
          ..hour = hour
          ..minute = minute
          ..isEnabled = isEnabled;
        await _settingsRepo.saveNotificationConfig(config);

        if (isEnabled) {
          await _notificationService.scheduleDailyNotification(hour: hour, minute: minute);
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
  ```
- **MIRROR**: STATE_NOTIFIER_PATTERN, ERROR_HANDLING
- **IMPORTS**: As shown above
- **GOTCHA**: `NotificationConfig` fields are non-final (Isar requirement). Use cascade `..` to set fields. `save()` takes all values as parameters — it does not partially update; always saves the complete state.
- **VALIDATE**: `flutter analyze` passes

### Task 10: SettingsScreen
- **ACTION**: Create `lib/features/settings/presentation/screens/settings_screen.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../providers/settings_provider.dart';
  import '../../../../core/theme/app_colors.dart';
  import '../../../../core/theme/app_spacing.dart';

  class SettingsScreen extends ConsumerStatefulWidget {
    const SettingsScreen({super.key});

    @override
    ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
  }

  class _SettingsScreenState extends ConsumerState<SettingsScreen> {
    late int _hour;
    late int _minute;
    late bool _isEnabled;
    bool _initialized = false;

    void _initFromState(SettingsState s) {
      if (_initialized) return;
      _hour = s.hour;
      _minute = s.minute;
      _isEnabled = s.isEnabled;
      _initialized = true;
    }

    Future<void> _pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _hour, minute: _minute),
      );
      if (picked != null) {
        setState(() {
          _hour = picked.hour;
          _minute = picked.minute;
        });
      }
    }

    Future<void> _save() async {
      await ref.read(settingsProvider.notifier).save(
            hour: _hour,
            minute: _minute,
            isEnabled: _isEnabled,
          );
    }

    @override
    Widget build(BuildContext context) {
      final state = ref.watch(settingsProvider);
      final theme = Theme.of(context);

      if (state.status == SettingsStatus.loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      _initFromState(state);

      final timeLabel =
          '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

      return Scaffold(
        appBar: AppBar(
          title: const Text('Bildirimler'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günlük hatırlatıcı',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Her gün belirlediğin saatte bir bildirim alırsın.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceDim,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Enable toggle row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bildirimleri aç', style: theme.textTheme.bodyLarge),
                      Switch(
                        value: _isEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isEnabled = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Time picker row
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saat', style: theme.textTheme.bodyLarge),
                        Row(
                          children: [
                            Text(
                              timeLabel,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.chevron_right,
                                color: AppColors.onSurfaceDim),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Save button
                GestureDetector(
                  onTap: state.status == SettingsStatus.saving ? null : _save,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: state.status == SettingsStatus.saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Kaydet',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                if (state.status == SettingsStatus.saved) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Center(
                    child: Text(
                      'Kaydedildi ✓',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
                if (state.status == SettingsStatus.error) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      state.errorMessage ?? 'Hata oluştu',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```
- **MIRROR**: CONSUMER_STATEFUL_WIDGET, GESTURE_BUTTON
- **IMPORTS**: As shown above
- **GOTCHA**: `_initialized` flag prevents overwriting user's in-progress edits when the provider rebuilds with `saved` status. `showTimePicker` returns `null` if user dismisses — always null-check.
- **VALIDATE**: `flutter analyze` passes

### Task 11: Update AppRoutes
- **ACTION**: Update `lib/core/router/app_routes.dart`
- **IMPLEMENT**: Add `static const settings = '/settings';` after `thoughtCatalog`
- **MIRROR**: ABSTRACT_INTERFACE_REPOSITORY (same file, route constants pattern)
- **GOTCHA**: Keep `AppRoutes._()` private constructor. Route string must start with `/`.
- **VALIDATE**: `flutter analyze` passes

### Task 12: Update AppRouter
- **ACTION**: Update `lib/core/router/app_router.dart`
- **IMPLEMENT**: Add settings route import + GoRoute entry
  ```dart
  import '../../features/settings/presentation/screens/settings_screen.dart';
  // In routes list:
  GoRoute(
    path: AppRoutes.settings,
    builder: (context, state) => const SettingsScreen(),
  ),
  ```
- **MIRROR**: ISAR_PROVIDER (same import pattern in router)
- **GOTCHA**: Order of routes doesn't matter for GoRouter path-based matching.
- **VALIDATE**: `flutter analyze` passes

### Task 13: Update HomeScreen — gear icon + notification tap listener
- **ACTION**: Update `lib/features/home/presentation/screens/home_screen.dart`
- **IMPLEMENT**:
  - Change to `ConsumerStatefulWidget` (need `ref.listen` in `didChangeDependencies` or build)
  - Actually: keep as `ConsumerWidget` — `ref.listen` works in `build()` of `ConsumerWidget`
  - Add import: `notification_provider.dart`
  - In `build()`, add `ref.listen` at the top before the return
  - Wrap body in `Scaffold` with `appBar` showing a gear icon action

  ```dart
  import '../../../../core/notifications/notification_provider.dart';
  
  // In build():
  ref.listen<bool>(notificationTappedProvider, (_, tapped) {
    if (tapped) {
      ref.read(notificationTappedProvider.notifier).state = false;
      context.go(AppRoutes.session);
    }
  });

  // In Scaffold, add appBar:
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceDim),
        onPressed: () => context.go(AppRoutes.settings),
      ),
    ],
  ),
  ```
  
  Also remove `Text('DILOS', ...)` from the body Column since it now appears to conflict with having an AppBar — keep it, but note AppBar is elevation 0 transparent so it's decorative.
- **MIRROR**: CONSUMER_WIDGET_SCREEN
- **GOTCHA**: `ref.listen` must be called in `build()` (not `initState`) for `ConsumerWidget`. It registers a listener that fires on subsequent changes. The first emission when `tapped` is already `false` won't trigger navigation. This is correct behavior.
- **VALIDATE**: `flutter analyze` passes; navigation from notification works

### Task 14: Update main.dart — ProviderContainer + notification init
- **ACTION**: Update `lib/main.dart` to use `ProviderContainer` + `UncontrolledProviderScope`
- **IMPLEMENT**:
  ```dart
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'app.dart';
  import 'core/notifications/notification_provider.dart';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    final container = ProviderContainer();

    final notificationService = container.read(notificationServiceProvider);
    await notificationService.initialize(
      onTap: () {
        container.read(notificationTappedProvider.notifier).state = true;
      },
    );

    final launchedFromNotification =
        await notificationService.wasLaunchedFromNotification();
    if (launchedFromNotification) {
      container.read(notificationTappedProvider.notifier).state = true;
    }

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const DilosApp(),
      ),
    );
  }
  ```
- **MIRROR**: N/A (startup pattern)
- **IMPORTS**: `dart:async`, `flutter_riverpod`, `app.dart`, notification providers
- **GOTCHA**: `ProviderContainer` must be created AFTER `WidgetsFlutterBinding.ensureInitialized()`. `UncontrolledProviderScope` does NOT dispose the container when unmounted — the container lives for the app's lifetime, which is correct. Do NOT add `addTearDown` here — this is not a test.
- **VALIDATE**: App boots without errors; `flutter analyze` passes

### Task 15: Update AndroidManifest.xml
- **ACTION**: Update `android/app/src/main/AndroidManifest.xml`
- **IMPLEMENT**: Add permissions before `<application>` tag:
  ```xml
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
  ```
  Add `BroadcastReceiver` entries inside `<application>` for notification persistence across reboots:
  ```xml
  <receiver
      android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
      android:exported="false"/>
  <receiver
      android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
      android:exported="true">
      <intent-filter>
          <action android:name="android.intent.action.BOOT_COMPLETED"/>
          <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
          <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
          <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
      </intent-filter>
  </receiver>
  ```
- **MIRROR**: N/A (XML config)
- **GOTCHA**: `RECEIVE_BOOT_COMPLETED` is needed for `ScheduledNotificationBootReceiver` to function — without it, scheduled notifications are lost on device restart. `POST_NOTIFICATIONS` is required for Android 13+ (API 33) but harmless on older versions. The `BroadcastReceiver` names are from `flutter_local_notifications` package internals — do NOT change them.
- **VALIDATE**: `flutter analyze` passes (analyze doesn't check XML, but the app must compile)

### Task 16: Write tests for SettingsNotifier
- **ACTION**: Create `test/features/settings/providers/settings_provider_test.dart`
- **IMPLEMENT**: Following the exact `brain_dump_provider_test.dart` pattern
  ```dart
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

    @override
    Future<void> scheduleDailyNotification({required int hour, required int minute}) async {
      scheduleCalled = true;
      scheduledHour = hour;
      scheduledMinute = minute;
    }

    @override
    Future<void> cancelDailyNotification() async {
      cancelCalled = true;
    }
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
        await Future.delayed(Duration.zero); // let async _load() complete
        expect(container.read(settingsProvider).hour, 9);
        expect(container.read(settingsProvider).minute, 0);
        expect(container.read(settingsProvider).isEnabled, false);
      });

      test('save ile bildirim zamanlanır', () async {
        await Future.delayed(Duration.zero);
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
        await Future.delayed(Duration.zero);
        await container.read(settingsProvider.notifier).save(
              hour: 20,
              minute: 30,
              isEnabled: false,
            );
        expect(fakeNotificationService.cancelCalled, true);
        expect(fakeNotificationService.scheduleCalled, false);
      });

      test('save sonrası state güncellenir', () async {
        await Future.delayed(Duration.zero);
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
        await Future.delayed(Duration.zero);
        await container.read(settingsProvider.notifier).save(
              hour: 10,
              minute: 0,
              isEnabled: true,
            );
        final config = await fakeRepo.getNotificationConfig();
        expect(config.hour, 10);
        expect(config.isEnabled, true);
      });
    });
  }
  ```
- **MIRROR**: TEST_STRUCTURE
- **IMPORTS**: As shown above
- **GOTCHA**: `FakeNotificationService extends NotificationService` (not implements) — because `NotificationService` is a concrete class. Override only the methods called by `SettingsNotifier`. `Future.delayed(Duration.zero)` pumps the microtask queue to let `_load()` complete without a Completer (unlike SessionNotifier tests which need explicit waiting, this is simpler because `_load` sets status to `idle` quickly).
- **VALIDATE**: `flutter test test/features/settings/providers/settings_provider_test.dart` all pass

---

## Testing Strategy

### Unit Tests

| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| başlangıçta loading | — | `status == loading` | No |
| yükleme sonrası varsayılan | repo returns defaults | `hour=9, minute=0, isEnabled=false` | No |
| save + enabled | `hour=20, minute=30, isEnabled=true` | `scheduleCalled=true, hour=20` | No |
| save + disabled | `isEnabled=false` | `cancelCalled=true, scheduleCalled=false` | No |
| save sonrası state | valid input | `status=saved, values match` | No |
| save repository persist | valid input | repo config updated | No |

### Edge Cases Checklist
- [x] Default config (repo returns fresh `NotificationConfig()`) — handled by `getNotificationConfig()` returning defaults
- [x] Notification service errors — wrapped in `on Exception catch` in `save()`
- [x] Time boundary (23:59) — `_nextInstanceOfTime` adds 1 day if past
- [ ] Notification permission denied — `requestPermission()` returns false; not blocking (notification scheduled anyway, OS handles it)
- [x] App launched from notification — handled in `main.dart` via `wasLaunchedFromNotification()`

---

## Validation Commands

### Static Analysis
```bash
flutter analyze
```
EXPECT: Zero errors, zero warnings

### Build Runner (after Task 3)
```bash
dart run build_runner build --delete-conflicting-outputs
```
EXPECT: `notification_config.g.dart` generated

### Unit Tests
```bash
flutter test test/features/settings/providers/settings_provider_test.dart
```
EXPECT: All tests pass

### Full Test Suite
```bash
flutter test
```
EXPECT: All tests pass, no regressions

### Manual Validation
- [ ] Run `flutter pub get` — no conflicts
- [ ] App boots without errors
- [ ] Gear icon visible on HomeScreen (top-right)
- [ ] Tapping gear → navigates to Settings screen
- [ ] Time picker opens and saves selected time
- [ ] Toggle switches notification on/off
- [ ] Save button shows loading spinner then "Kaydedildi ✓"
- [ ] On Android: tap Kaydet → system notification appears at scheduled time
- [ ] Tapping notification → navigates directly to session screen

---

## Acceptance Criteria
- [ ] All 16 tasks completed
- [ ] `flutter analyze` passes (zero errors)
- [ ] `flutter test` passes (all tests including 5+ new tests)
- [ ] `notification_config.g.dart` generated
- [ ] Settings screen accessible from HomeScreen
- [ ] Notification fires at scheduled time (manual test)
- [ ] Tapping notification launches session directly

## Completion Checklist
- [ ] Isar schema registered in `isar_provider.dart`
- [ ] `NotificationConfig` singleton pattern (id=1) used correctly
- [ ] Error handling with `on Exception catch` everywhere
- [ ] `ref.listen` in HomeScreen for notification tap
- [ ] `UncontrolledProviderScope` used in main.dart (not `ProviderScope`)
- [ ] AndroidManifest has required permissions + receivers
- [ ] Tests use `FakeSettingsRepository` + `FakeNotificationService` pattern
- [ ] No hardcoded strings except Turkish UI copy

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Isar schema migration needed (existing DB has no NotificationConfigSchema) | Medium | Build error / crash on existing installs | Clear app data during development; document for prod migration |
| `flutter_local_notifications` API changed in latest version | Medium | Compile error | Pin to `^17.2.0`; verify with `flutter pub get` |
| Android 13+ permission not granted | Medium | Notification never shows | `requestPermission()` called on first save; OS prompt appears |
| Notification not rescheduled after reboot | Low | Reminder stops after device restart | `ScheduledNotificationBootReceiver` in manifest handles this |
| `FlutterTimezone.getLocalTimezone()` fails | Low | Wrong notification time | Fallback to `UTC` if exception thrown |

## Notes
- Isar collection accessor for `NotificationConfig` is `notificationConfigs` — verify this in the generated `.g.dart` after Task 3 before writing the repository impl.
- The `ProviderContainer` → `UncontrolledProviderScope` change in `main.dart` is intentional. Existing tests use `ProviderContainer` directly and are not affected.
- `NotificationService` is a concrete class (not abstract), so `FakeNotificationService extends NotificationService` in tests overrides specific methods.
- Request permission on first `save()` — avoids asking for permission before the user has expressed intent to enable notifications.
