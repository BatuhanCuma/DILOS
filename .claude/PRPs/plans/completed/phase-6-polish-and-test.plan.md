# Plan: Phase 6 — Polish & Test

## Summary
İlk kez açan kullanıcıya 3 sayfalık onboarding akışı gösterilir (SharedPreferences ile tamamlanma durumu saklanır). Brain Dump ve Journal ekranlarına boş durum mesajları eklenir. AppTextTheme eksik stil tanımlarıyla tamamlanır. Stale yorum temizlenir.

## User Story
As a first-time user, I want to see an onboarding flow that explains DILOS, so that I understand the app and start my first session with confidence.

## Problem → Solution
App ilk açılışta direkt HomeScreen → Onboarding → Home yönlendirmesi + empty states + AppTextTheme tamamlanması

## Metadata
- **Complexity**: Medium
- **Source PRD**: `.claude/PRPs/prds/dilos-mvp.prd.md`
- **PRD Phase**: Faz 6 — Polish & Test
- **Estimated Files**: 12

---

## UX Design

### Before
```
┌────────────────────────────┐
│  DILOS        (settings)   │
│  Hayatın zaten güzel.      │
│                            │
│  [Seans Başlat]            │
│  [Brain Dump]              │
│  [Journal]                 │
│                            │
│  (No onboarding, no empty  │
│   states, stale comment)   │
└────────────────────────────┘
```

### After
```
┌──────── First Launch ──────┐   ┌──────── After Onboarding ──┐
│  • • ○  [geç]              │   │  DILOS        (settings)   │
│                            │   │  Hayatın zaten güzel.      │
│  🌙                        │   │                            │
│  DILOS Nedir?              │   │  [Seans Başlat]            │
│                            │   │  [Brain Dump]              │
│  Kısa seanslarda kendini   │   │  [Journal]                 │
│  yeniden keşfet.           │   └────────────────────────────┘
│                            │
│         [Sonraki]          │   ┌──── Brain Dump (empty) ────┐
└────────────────────────────┘   │  Kafanda ne var? Yaz...    │
                                 │  [text area]               │
                                 │  [Kaydet]                  │
                                 │                            │
                                 │  Henüz bir şey yazmadın.   │
                                 │  İlk düşünceni döküver.    │
                                 └────────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| First launch | Goes to HomeScreen | Goes to OnboardingScreen | Redirect via initialLocation |
| Onboarding complete | N/A | context.go(AppRoutes.home) + prefs.setBool | Flag stored in SharedPreferences |
| Subsequent launches | HomeScreen | HomeScreen (onboarding skipped) | Flag checked in main.dart |
| Brain Dump (empty) | Blank area | "Henüz bir şey yazmadın" message | Shows only when recentEntries is empty |
| Journal (empty) | Blank area | "Henüz bir giriş yok" message | Shows only when recentEntries is empty |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/main.dart` | all | Startup pattern — add SharedPreferences init before runApp |
| P0 | `lib/core/router/app_router.dart` | all | Where to add onboarding route + initialLocation logic |
| P0 | `lib/core/notifications/notification_provider.dart` | all | StateProvider pattern to mirror for onboardingCompletedProvider |
| P0 | `lib/core/notifications/notification_service.dart` | all | Service class pattern to mirror for OnboardingService |
| P1 | `lib/features/brain_dump/presentation/screens/brain_dump_screen.dart` | 108-147 | Where to inject empty state (inside `if (state.recentEntries.isNotEmpty)`) |
| P1 | `lib/features/journal/presentation/screens/journal_screen.dart` | 103-149 | Same pattern — empty state for recentEntries |
| P1 | `lib/features/session/presentation/screens/session_complete_screen.dart` | all | UI style reference: icon + title + body + button |
| P1 | `lib/core/theme/app_text_theme.dart` | all | Add titleMedium + bodySmall to the existing TextTheme |
| P2 | `lib/features/settings/presentation/screens/settings_screen.dart` | all | ConsumerStatefulWidget with multi-page-like state — mirror for onboarding |

## External Documentation

| Topic | Source | Key Takeaway |
|---|---|---|
| shared_preferences | pub.dev/packages/shared_preferences | `SharedPreferences.getInstance()` is async; `setBool/getBool` are sync after init |
| shared_preferences testing | pub.dev docs | Use `SharedPreferences.setMockInitialValues({})` before `getInstance()` in tests |

---

## Patterns to Mirror

### SERVICE_CLASS_PATTERN
```dart
// SOURCE: lib/core/notifications/notification_service.dart:1-15
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize({void Function()? onTap}) async { ... }
  Future<bool> wasLaunchedFromNotification() async { ... }
}
```
Follow the same concrete-class-no-abstract pattern for `OnboardingService`.

### STATE_PROVIDER_PATTERN
```dart
// SOURCE: lib/core/notifications/notification_provider.dart:1-9
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationTappedProvider = StateProvider<bool>((ref) => false);
```
`onboardingCompletedProvider` is a `StateProvider<bool>` set in main.dart before runApp — identical pattern to `notificationTappedProvider`.

### MAIN_DART_INIT_PATTERN
```dart
// SOURCE: lib/main.dart:1-31
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.initialize(onTap: () { ... });
  runApp(UncontrolledProviderScope(container: container, child: const DilosApp()));
}
```
Add SharedPreferences read and `container.read(onboardingCompletedProvider.notifier).state = ...` between existing notification init and runApp.

### ROUTER_PROVIDER_PATTERN
```dart
// SOURCE: lib/core/router/app_router.dart:11-41
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [ ... ],
  );
});
```
Change `initialLocation` to `ref.read(onboardingCompletedProvider) ? AppRoutes.home : AppRoutes.onboarding`.

### SCREEN_UI_PATTERN (session_complete reference)
```dart
// SOURCE: lib/features/session/presentation/screens/session_complete_screen.dart:14-59
Scaffold(
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 64),
          const SizedBox(height: AppSpacing.lg),
          Text('Seans tamamlandı', style: theme.textTheme.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          Text('...', style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceDim)),
          const Spacer(),
          GestureDetector(onTap: ..., child: Container(...)) // primary button
        ],
      ),
    ),
  ),
)
```

### GESTURE_BUTTON_PATTERN
```dart
// SOURCE: lib/features/home/presentation/screens/home_screen.dart:52-71
GestureDetector(
  onTap: () => context.go(AppRoutes.session),
  child: Container(
    width: double.infinity, height: 56,
    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
    alignment: Alignment.center,
    child: Text('Seans Başlat', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16)),
  ),
),
```

### EMPTY_STATE_PATTERN (brain_dump reference)
```dart
// SOURCE: lib/features/brain_dump/presentation/screens/brain_dump_screen.dart:108-147
if (state.recentEntries.isNotEmpty) ...[
  Text('Geçmiş', style: theme.textTheme.titleMedium),
  ...
]
```
Add `else` branch with centered empty state text.

### ERROR_HANDLING
```dart
// SOURCE: lib/features/brain_dump/presentation/providers/brain_dump_provider.dart:47-52
} on Exception catch (e) {
  state = state.copyWith(status: BrainDumpStatus.error, errorMessage: e.toString());
}
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `pubspec.yaml` | UPDATE | Add shared_preferences ^2.3.2 |
| `lib/core/onboarding/onboarding_service.dart` | CREATE | SharedPreferences wrapper for onboarding flag |
| `lib/core/onboarding/onboarding_provider.dart` | CREATE | onboardingCompletedProvider (StateProvider) + onboardingServiceProvider |
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | CREATE | 3-page PageView onboarding |
| `lib/core/router/app_routes.dart` | UPDATE | Add onboarding = '/onboarding' |
| `lib/core/router/app_router.dart` | UPDATE | initialLocation + onboarding route |
| `lib/main.dart` | UPDATE | SharedPreferences init + set onboardingCompletedProvider |
| `lib/features/brain_dump/presentation/screens/brain_dump_screen.dart` | UPDATE | Empty state when no entries |
| `lib/features/journal/presentation/screens/journal_screen.dart` | UPDATE | Empty state when no entries |
| `lib/features/home/presentation/screens/home_screen.dart` | UPDATE | Remove stale comment |
| `lib/core/theme/app_text_theme.dart` | UPDATE | Add titleMedium + bodySmall |
| `test/core/onboarding/onboarding_service_test.dart` | CREATE | OnboardingService unit tests |

## NOT Building
- Multi-language / localization — Turkish hardcoded is sufficient for MVP
- Analytics / event tracking — PRD explicitly deferred
- Social sharing — PRD explicitly excluded
- Complex onboarding with user profile inputs — 3 info pages + "Başla" is sufficient
- `flutter_lottie` animations — plain Flutter widgets only

---

## Step-by-Step Tasks

### Task 1: pubspec.yaml — add shared_preferences
- **ACTION**: Add `shared_preferences: ^2.3.2` under dependencies
- **IMPLEMENT**:
  ```yaml
  # after flutter_timezone line:
  shared_preferences: ^2.3.2
  ```
- **MIRROR**: N/A
- **GOTCHA**: No code generation needed — `shared_preferences` is pure Dart
- **VALIDATE**: `flutter pub get` succeeds

### Task 2: AppTextTheme — add missing styles
- **ACTION**: Update `lib/core/theme/app_text_theme.dart` — add `titleMedium` and `bodySmall`
- **IMPLEMENT**:
  ```dart
  titleMedium: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    color: AppColors.onSurfaceDim,
  ),
  ```
  Add inside the `const TextTheme(...)` constructor after `labelLarge`.
- **MIRROR**: Existing styles in file — same pattern, same `AppColors` references
- **IMPORTS**: None (already imported)
- **GOTCHA**: `TextTheme` constructor fields are named — place them in any order inside the constructor, consistent indentation
- **VALIDATE**: `flutter analyze` passes

### Task 3: OnboardingService
- **ACTION**: Create `lib/core/onboarding/onboarding_service.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:shared_preferences/shared_preferences.dart';

  class OnboardingService {
    OnboardingService(this._prefs);
    final SharedPreferences _prefs;

    static const _key = 'onboarding_completed';

    bool isCompleted() => _prefs.getBool(_key) ?? false;

    Future<void> complete() => _prefs.setBool(_key, true);
  }
  ```
- **MIRROR**: SERVICE_CLASS_PATTERN
- **IMPORTS**: `package:shared_preferences/shared_preferences.dart`
- **GOTCHA**: `isCompleted()` is synchronous (SharedPreferences values are cached in memory after `getInstance()`). `complete()` returns `Future<bool>` from `setBool` — mark the method `Future<void>` and discard the bool return.
- **VALIDATE**: `flutter analyze` passes

### Task 4: OnboardingProvider
- **ACTION**: Create `lib/core/onboarding/onboarding_provider.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'onboarding_service.dart';

  final onboardingServiceProvider = Provider<OnboardingService>((ref) {
    throw UnimplementedError('onboardingServiceProvider must be overridden in main');
  });

  /// Initialized in main.dart before runApp
  final onboardingCompletedProvider = StateProvider<bool>((ref) => false);
  ```
- **MIRROR**: STATE_PROVIDER_PATTERN
- **IMPORTS**: `flutter_riverpod`, `shared_preferences`, `onboarding_service.dart`
- **GOTCHA**: `onboardingServiceProvider` throws by default — it MUST be overridden by `ProviderContainer` with a real instance (initialized in `main.dart`). This is intentional: it prevents accidental use without initialization. `onboardingCompletedProvider` is set in `main.dart` after `SharedPreferences.getInstance()`.
- **VALIDATE**: `flutter analyze` passes

### Task 5: Update main.dart — SharedPreferences init + onboarding check
- **ACTION**: Update `lib/main.dart` to read onboarding completion and set provider
- **IMPLEMENT**: Add imports + SharedPreferences init between notification init and runApp:
  ```dart
  import 'package:shared_preferences/shared_preferences.dart';
  import 'core/onboarding/onboarding_provider.dart';
  import 'core/onboarding/onboarding_service.dart';

  // After notification init, before runApp:
  final prefs = await SharedPreferences.getInstance();
  final onboardingService = OnboardingService(prefs);
  container.read(onboardingCompletedProvider.notifier).state =
      onboardingService.isCompleted();
  ```
  Also override `onboardingServiceProvider`:
  ```dart
  // Replace ProviderContainer() with:
  final container = ProviderContainer(
    overrides: [
      onboardingServiceProvider.overrideWithValue(OnboardingService(prefs)),
    ],
  );
  // But prefs isn't available yet — initialize prefs first, then create container:
  ```
  
  **Full updated main.dart**:
  ```dart
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'app.dart';
  import 'core/notifications/notification_provider.dart';
  import 'core/onboarding/onboarding_provider.dart';
  import 'core/onboarding/onboarding_service.dart';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final onboardingService = OnboardingService(prefs);

    final container = ProviderContainer(
      overrides: [
        onboardingServiceProvider.overrideWithValue(onboardingService),
      ],
    );

    container.read(onboardingCompletedProvider.notifier).state =
        onboardingService.isCompleted();

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
- **MIRROR**: MAIN_DART_INIT_PATTERN
- **GOTCHA**: `SharedPreferences.getInstance()` must be called BEFORE `ProviderContainer()` so `prefs` is available for the override. This is why `prefs` init comes before container creation.
- **VALIDATE**: `flutter analyze` passes

### Task 6: AppRoutes — add onboarding
- **ACTION**: Update `lib/core/router/app_routes.dart` — add `onboarding` constant
- **IMPLEMENT**:
  ```dart
  static const onboarding = '/onboarding';
  ```
  Add as the first route constant (before `home`).
- **MIRROR**: Existing route constants pattern
- **GOTCHA**: Keep `AppRoutes._()` private constructor
- **VALIDATE**: `flutter analyze` passes

### Task 7: AppRouter — initialLocation + onboarding route
- **ACTION**: Update `lib/core/router/app_router.dart`
- **IMPLEMENT**:
  - Add import for `OnboardingScreen` and `onboardingCompletedProvider`
  - Change `initialLocation` to dynamic
  - Add onboarding route

  ```dart
  import '../../core/onboarding/onboarding_provider.dart';
  import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

  final routerProvider = Provider<GoRouter>((ref) {
    final onboardingCompleted = ref.read(onboardingCompletedProvider);
    return GoRouter(
      initialLocation:
          onboardingCompleted ? AppRoutes.home : AppRoutes.onboarding,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        // ... existing routes ...
      ],
    );
  });
  ```
  Add the onboarding route FIRST in the routes list.
- **MIRROR**: ROUTER_PROVIDER_PATTERN
- **GOTCHA**: `ref.read` (not `ref.watch`) — the router is created once; `initialLocation` is evaluated at creation. The onboarding state was set in main.dart before the router is first read, so this is correct. Do NOT use `ref.watch` here — that would cause the GoRouter to be recreated on every state change.
- **VALIDATE**: `flutter analyze` passes

### Task 8: OnboardingScreen
- **ACTION**: Create `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import '../../../../../core/onboarding/onboarding_provider.dart';
  import '../../../../../core/router/app_routes.dart';
  import '../../../../../core/theme/app_colors.dart';
  import '../../../../../core/theme/app_spacing.dart';

  class OnboardingScreen extends ConsumerStatefulWidget {
    const OnboardingScreen({super.key});

    @override
    ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
  }

  class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
    final _controller = PageController();
    int _page = 0;

    static const _pages = [
      _OnboardingPage(
        icon: Icons.nights_stay_outlined,
        title: 'DILOS Nedir?',
        body: 'Kısa seanslarda kendini yeniden keşfet. '
            'Burnout ve yalnızlıkla başa çıkmak için '
            'tasarlanmış bir zihin alanı.',
      ),
      _OnboardingPage(
        icon: Icons.bubble_chart_outlined,
        title: 'Nasıl Çalışır?',
        body: 'Her gün 2–5 dakika. Uygulama sana sorular sorar, '
            'sen sadece cevaplarsın. AI arka planda çalışır, '
            'sen sadece akışa girersin.',
      ),
      _OnboardingPage(
        icon: Icons.notifications_none_outlined,
        title: 'Hazır Mısın?',
        body: 'Bildirim ayarlayarak günlük hatırlatıcı ekleyebilirsin. '
            'Ya da direkt başlayabilirsin — seçim senindir.',
      ),
    ];

    Future<void> _complete() async {
      final service = ref.read(onboardingServiceProvider);
      await service.complete();
      ref.read(onboardingCompletedProvider.notifier).state = true;
      if (mounted) context.go(AppRoutes.home);
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      final isLast = _page == _pages.length - 1;

      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _complete,
                  child: Text(
                    'Geç',
                    style: TextStyle(color: AppColors.onSurfaceDim),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _OnboardingPageWidget(page: _pages[i]),
                ),
              ),
              // Dot indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i
                          ? AppColors.primary
                          : AppColors.onSurfaceDim.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GestureDetector(
                  onTap: isLast
                      ? _complete
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isLast ? 'Başla' : 'Sonraki',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      );
    }
  }

  class _OnboardingPage {
    const _OnboardingPage({
      required this.icon,
      required this.title,
      required this.body,
    });
    final IconData icon;
    final String title;
    final String body;
  }

  class _OnboardingPageWidget extends StatelessWidget {
    const _OnboardingPageWidget({required this.page});
    final _OnboardingPage page;

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(page.icon, size: 80, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xl),
            Text(
              page.title,
              style: theme.textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              page.body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceDim,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
  ```
- **MIRROR**: SCREEN_UI_PATTERN, GESTURE_BUTTON_PATTERN
- **IMPORTS**: As shown above. Note: path to core from `features/onboarding/presentation/screens/` is `../../../../../core/...` (5 levels up)
- **GOTCHA**: `PageController` must be disposed. `_pages` is a `const List` — `_OnboardingPage` must be a const-compatible data class (all fields are const-constructible). `mounted` check after `await service.complete()` before using `context`.
- **VALIDATE**: `flutter analyze` passes

### Task 9: BrainDump empty state
- **ACTION**: Update `lib/features/brain_dump/presentation/screens/brain_dump_screen.dart` — add empty state
- **IMPLEMENT**: Change the `if (state.recentEntries.isNotEmpty)` block to also show an empty state:
  ```dart
  // Replace:
  if (state.recentEntries.isNotEmpty) ...[
    Text('Geçmiş', style: theme.textTheme.titleMedium),
    ...
  ]

  // With:
  if (state.recentEntries.isNotEmpty) ...[
    Text('Geçmiş', style: theme.textTheme.titleMedium),
    const SizedBox(height: AppSpacing.sm),
    Expanded(
      child: ListView.separated(
        // ... existing list builder ...
      ),
    ),
  ] else ...[
    const SizedBox(height: AppSpacing.lg),
    Center(
      child: Column(
        children: [
          const Icon(
            Icons.edit_note_outlined,
            size: 48,
            color: AppColors.onSurfaceDim,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Henüz bir şey yazmadın.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'İlk düşünceni döküver.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceDim.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ],
  ```
- **MIRROR**: EMPTY_STATE_PATTERN
- **GOTCHA**: The `Expanded` widget is already in the `isNotEmpty` branch — the `else` branch does NOT need `Expanded` (it's just centered content, not a scrollable list). Make sure the `Expanded` stays only in the `isNotEmpty` branch.
- **VALIDATE**: `flutter analyze` passes

### Task 10: Journal empty state
- **ACTION**: Update `lib/features/journal/presentation/screens/journal_screen.dart` — add empty state after the entries list
- **IMPLEMENT**: After `if (state.recentEntries.isNotEmpty) ...[...]`, add:
  ```dart
  if (state.recentEntries.isEmpty) ...[
    const SizedBox(height: AppSpacing.lg),
    Center(
      child: Column(
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            size: 48,
            color: AppColors.onSurfaceDim,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Henüz bir giriş yok.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bugün nasıldı?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceDim.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ],
  ```
- **MIRROR**: EMPTY_STATE_PATTERN
- **GOTCHA**: The journal screen uses `SingleChildScrollView` — the empty state sits inside the `Column` after the form fields. No `Expanded` needed. Use `.isEmpty` (not `!isNotEmpty` — identical but more readable)
- **VALIDATE**: `flutter analyze` passes

### Task 11: HomeScreen — remove stale comment
- **ACTION**: Update `lib/features/home/presentation/screens/home_screen.dart` — remove the stale inline comment
- **IMPLEMENT**: Remove the line `// Faz 2'de Auto Session engine buraya gelecek` from the `GestureDetector` that wraps "Seans Başlat"
- **MIRROR**: N/A (comment removal)
- **GOTCHA**: One line removal only — do not touch surrounding code
- **VALIDATE**: `flutter analyze` passes

### Task 12: Tests for OnboardingService
- **ACTION**: Create `test/core/onboarding/onboarding_service_test.dart`
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:dilos/core/onboarding/onboarding_service.dart';

  void main() {
    group('OnboardingService', () {
      late OnboardingService service;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        service = OnboardingService(prefs);
      });

      test('başlangıçta tamamlanmamış döner', () {
        expect(service.isCompleted(), false);
      });

      test('complete sonrası tamamlanmış döner', () async {
        await service.complete();
        expect(service.isCompleted(), true);
      });

      test('complete kalıcı: aynı prefs örneği ile doğrulanır', () async {
        await service.complete();
        final prefs2 = await SharedPreferences.getInstance();
        final service2 = OnboardingService(prefs2);
        expect(service2.isCompleted(), true);
      });
    });
  }
  ```
- **MIRROR**: TEST_STRUCTURE (from brain_dump_provider_test.dart pattern)
- **IMPORTS**: `shared_preferences`, `onboarding_service.dart`
- **GOTCHA**: `SharedPreferences.setMockInitialValues({})` must be called BEFORE `SharedPreferences.getInstance()` in setUp. In tests, `SharedPreferences` uses an in-memory store — each `setMockInitialValues` call resets it. Since setUp calls it each time, tests are isolated.
- **VALIDATE**: `flutter test test/core/onboarding/onboarding_service_test.dart` — all pass

---

## Testing Strategy

### Unit Tests

| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| isCompleted başlangıçta | fresh prefs | false | No |
| complete + isCompleted | call complete() | true | No |
| complete kalıcı | same prefs instance | true after complete | No |

### Edge Cases Checklist
- [x] First launch (no pref key) → `isCompleted()` returns false (handled by `?? false`)
- [x] Complete called multiple times — idempotent (setBool overwrites same key)
- [x] App killed during onboarding — incomplete, flag not set, shown again on next launch

---

## Validation Commands

### Static Analysis
```bash
flutter analyze
```
EXPECT: Zero issues

### Unit Tests
```bash
flutter test test/core/onboarding/onboarding_service_test.dart
```
EXPECT: 3 tests pass

### Full Test Suite
```bash
flutter test
```
EXPECT: 39/39 pass (36 existing + 3 new)

### Manual Validation
- [ ] Fresh install (or clear app data): onboarding shows on launch
- [ ] Tap "Geç" → goes directly to home, flag saved
- [ ] Tap through all 3 pages → "Başla" → goes to home, flag saved
- [ ] Restart app → home screen (onboarding skipped)
- [ ] Brain Dump screen with no entries → empty state message visible
- [ ] Journal screen with no entries → empty state message visible
- [ ] After saving a Brain Dump entry → empty state replaced by entry list

---

## Acceptance Criteria
- [ ] All 12 tasks completed
- [ ] `flutter analyze` passes (zero issues)
- [ ] `flutter test` passes (39/39)
- [ ] Onboarding shown on first launch, skipped on subsequent launches
- [ ] Empty states visible in Brain Dump and Journal
- [ ] No regressions in existing features

## Completion Checklist
- [ ] SharedPreferences properly initialized in main.dart before ProviderContainer
- [ ] `onboardingServiceProvider` overridden in container
- [ ] `ref.read` (not `ref.watch`) in routerProvider for onboarding flag
- [ ] `mounted` check after async operation in OnboardingScreen
- [ ] PageController disposed in OnboardingScreen
- [ ] Stale comment removed from HomeScreen
- [ ] titleMedium + bodySmall added to AppTextTheme
- [ ] Tests use `SharedPreferences.setMockInitialValues({})`

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Router created before prefs init | Low | Onboarding always shows | main.dart: prefs init → container create → provider set → runApp order |
| Empty state breaks existing layout | Low | Scrollable overflow | `else` branch has no `Expanded`; journal uses ScrollView |
| OnboardingScreen imports wrong core path | Medium | Build error | Path: `../../../../../core/...` from `features/onboarding/presentation/screens/` |

## Notes
- `onboardingServiceProvider` throws by default in the provider definition — this is intentional. It forces initialization via `overrideWithValue` in main.dart and makes the dependency explicit.
- `_pages` list uses const `_OnboardingPage` objects — this requires all fields (icon, title, body) to be compile-time constants. `IconData` is const-compatible.
- The `isNotEmpty` branch in BrainDump already has `Expanded` wrapping the `ListView` — the `else` branch must NOT have `Expanded` or it will error (nothing to expand to when the Column doesn't fill height).
