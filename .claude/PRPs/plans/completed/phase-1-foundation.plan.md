# Plan: Phase 1 — Foundation

## Summary
DILOS Flutter uygulamasının temel iskeletini kurar: feature-first clean architecture klasör yapısı, go_router navigasyon, Isar local veritabanı, Riverpod state management ve design system. Bu faz tamamlanmadan diğer hiçbir faz başlayamaz.

## User Story
As a developer,
I want a clean, consistent project foundation,
So that every subsequent feature can be built without architectural rework.

## Problem → Solution
Boş Flutter projesi → Feature-first clean architecture, çalışan DB, routing ve design system ile tam iskelet uygulama.

## Metadata
- **Complexity**: Large
- **Source PRD**: `.claude/PRPs/prds/dilos-mvp.prd.md`
- **PRD Phase**: Faz 1 — Foundation
- **Estimated Files**: 25–35

---

## UX Design

### Before
```
┌─────────────────────┐
│  Boş ekran / yok    │
└─────────────────────┘
```

### After
```
┌─────────────────────────────────┐
│  DILOS                          │
│                                 │
│  [Design system renkleriyle     │
│   minimal splash/home ekranı]   │
│                                 │
│  DB okuma/yazma çalışıyor ✓     │
│  Routing çalışıyor ✓            │
└─────────────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notlar |
|---|---|---|---|
| App açılışı | Hata / boş | Splash → Home | go_router ile |
| DB | Yok | Isar init + test kaydı | Offline-first |

---

## Mandatory Reading

| Öncelik | Kaynak | Neden |
|---|---|---|
| P0 | `pubspec.yaml` (oluşturulacak) | Tüm bağımlılıklar burada |
| P0 | `lib/main.dart` (oluşturulacak) | App entry point, provider scope |
| P1 | `lib/core/theme/app_theme.dart` (oluşturulacak) | Design system referansı |
| P1 | `lib/core/router/app_router.dart` (oluşturulacak) | Tüm route tanımları |

## External Documentation

| Konu | Kaynak | Önemli Not |
|---|---|---|
| go_router | pub.dev/packages/go_router | `GoRouter` + `GoRoute` kullan, `Navigator.push` YOK |
| Isar | isar.dev/docs | `@collection` annotation, `IsarLinks` için dikkat |
| Riverpod | riverpod.dev | `@riverpod` code-gen kullan (riverpod_generator) |
| flutter_local_notifications | pub.dev | Android için `AndroidInitializationSettings` gerekli |

---

## Patterns to Mirror

Yeni proje olduğu için pattern'lar bu planda tanımlanıyor. Tüm sonraki fazlar bunları referans alacak.

### NAMING_CONVENTION
```dart
// Dosyalar: snake_case
// lib/features/session/presentation/screens/session_screen.dart

// Sınıflar: PascalCase
class SessionScreen extends ConsumerWidget {}

// Provider'lar: camelCase + Provider suffix
final sessionRepositoryProvider = Provider<SessionRepository>(...);

// Isar collection: PascalCase
@collection
class SessionEntry { ... }

// Constants: UPPER_SNAKE_CASE
const kPrimaryColor = Color(0xFF1A1A2E);
```

### FEATURE_STRUCTURE
```
lib/features/{feature_name}/
  ├── data/
  │   ├── models/          # Isar modelleri (@collection)
  │   └── repositories/    # Repository implementasyonları
  ├── domain/
  │   ├── entities/        # Pure Dart sınıflar
  │   └── repositories/    # Abstract repository interface
  └── presentation/
      ├── screens/         # Tam ekran widget'lar
      ├── widgets/         # Feature-specific widget'lar
      └── providers/       # Riverpod providers
```

### ERROR_HANDLING
```dart
// Result pattern kullan — exception fırlatma
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

// Repository'de:
Future<Result<List<SessionEntry>>> getSessions() async {
  try {
    final sessions = await isar.sessionEntrys.where().findAll();
    return Success(sessions);
  } catch (e) {
    return Failure('Seanslar yüklenemedi: $e');
  }
}
```

### RIVERPOD_PROVIDER
```dart
// riverpod_generator ile — @riverpod annotation
@riverpod
SessionRepository sessionRepository(SessionRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return IsarSessionRepository(isar);
}

// ConsumerWidget içinde:
class SessionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sessionRepositoryProvider);
    // ...
  }
}
```

### ISAR_MODEL
```dart
@collection
class SessionEntry {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;
  late String type;        // 'auto', 'brain_dump', 'journal'
  late String status;      // 'pending', 'completed'

  @ignore
  // Computed property — DB'de saklanmaz
  bool get isCompleted => status == 'completed';
}
```

### ROUTER_PATTERN
```dart
// lib/core/router/app_router.dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

// Route sabitleri ayrı dosyada:
class AppRoutes {
  static const home = '/';
  static const session = '/session';
  static const brainDump = '/brain-dump';
}
```

### THEME_PATTERN
```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    textTheme: AppTextTheme.textTheme,
  );
}

// lib/core/theme/app_colors.dart
class AppColors {
  static const primary = Color(0xFF7C6FF7);    // mor — zihin/derinlik
  static const surface = Color(0xFF0F0F1A);    // koyu lacivert
  static const onSurface = Color(0xFFE8E8F0);  // açık gri beyaz
  static const accent = Color(0xFF52FFAD);     // mint yeşil — aksiyon
}
```

---

## Files to Change

| Dosya | İşlem | Gerekçe |
|---|---|---|
| `pubspec.yaml` | CREATE | Tüm bağımlılıklar |
| `lib/main.dart` | CREATE | Entry point, ProviderScope |
| `lib/app.dart` | CREATE | MaterialApp.router |
| `lib/core/router/app_router.dart` | CREATE | GoRouter tanımı |
| `lib/core/router/app_routes.dart` | CREATE | Route sabitleri |
| `lib/core/theme/app_theme.dart` | CREATE | ThemeData |
| `lib/core/theme/app_colors.dart` | CREATE | Renk paleti |
| `lib/core/theme/app_text_theme.dart` | CREATE | Tipografi |
| `lib/core/theme/app_spacing.dart` | CREATE | Spacing sabitleri |
| `lib/core/database/isar_provider.dart` | CREATE | Isar instance provider |
| `lib/core/database/isar_service.dart` | CREATE | Isar init, schema açma |
| `lib/features/home/presentation/screens/home_screen.dart` | CREATE | İlk ekran (placeholder) |
| `lib/features/home/presentation/widgets/dilos_app_bar.dart` | CREATE | App bar widget |
| `analysis_options.yaml` | CREATE | Linting kuralları |
| `test/core/database/isar_service_test.dart` | CREATE | DB write/read testi |

## NOT Building

- Gerçek feature ekranları (session, journal, brain dump) — Faz 2 ve 3
- AI entegrasyonu — Faz 4
- Bildirimler — Faz 5
- Onboarding — Faz 6
- Supabase sync — MVP sonrası

---

## Step-by-Step Tasks

### Task 1: pubspec.yaml oluştur
- **ACTION**: Proje bağımlılıklarını tanımla
- **IMPLEMENT**:
```yaml
name: dilos
description: Digital Intelligence Life Operating System
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.7

  # Local database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1

  # Voice input
  speech_to_text: ^6.6.2

  # Notifications
  flutter_local_notifications: ^17.2.2

  # Utilities
  uuid: ^4.4.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  isar_generator: ^3.1.0+1
  flutter_lints: ^4.0.0
  isar_inspector: ^1.0.2  # debug için
```
- **GOTCHA**: `isar_flutter_libs` platform-specific — iOS için `pod install` gerekebilir
- **VALIDATE**: `flutter pub get` hatasız tamamlanıyor

### Task 2: Design System — Renkler ve Tipografi
- **ACTION**: DILOS görsel kimliğini kodla
- **IMPLEMENT**:

`lib/core/theme/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ana palet — zihin/derinlik teması
  static const primary = Color(0xFF7C6FF7);      // mor
  static const primaryDim = Color(0xFF4A4580);   // koyu mor
  static const surface = Color(0xFF0F0F1A);      // koyu lacivert
  static const surfaceElevated = Color(0xFF1A1A2E); // biraz açık
  static const onSurface = Color(0xFFE8E8F0);    // metin
  static const onSurfaceDim = Color(0xFF9090A8); // ikincil metin
  static const accent = Color(0xFF52FFAD);        // mint — aksiyon
  static const error = Color(0xFFFF6B6B);
}
```

`lib/core/theme/app_spacing.dart`:
```dart
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
```

`lib/core/theme/app_text_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32, fontWeight: FontWeight.w700,
      color: AppColors.onSurface, height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    bodyLarge: TextStyle(
      fontSize: 16, color: AppColors.onSurface, height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14, color: AppColors.onSurfaceDim,
    ),
    labelLarge: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600,
      color: AppColors.onSurface, letterSpacing: 0.5,
    ),
  );
}
```

`lib/core/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surfaceElevated,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.onSurface,
    ),
    textTheme: AppTextTheme.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardTheme(
      color: AppColors.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
```
- **MIRROR**: THEME_PATTERN
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 3: Isar Kurulumu
- **ACTION**: Isar instance'ı başlat, provider ile sun

`lib/core/database/isar_service.dart`:
```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> getInstance(List<CollectionSchema<dynamic>> schemas) async {
    if (_instance != null && _instance!.isOpen) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      schemas,
      directory: dir.path,
      name: 'dilos_db',
    );
    return _instance!;
  }
}
```

`lib/core/database/isar_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'isar_service.dart';

// Şimdilik boş schema listesi — Faz 2'de SessionEntry eklenecek
final isarProvider = FutureProvider<Isar>((ref) async {
  return IsarService.getInstance([
    // SessionEntrySchema, — Faz 2'de uncomment
  ]);
});
```
- **GOTCHA**: `path_provider` paketini pubspec'e ekle (`path_provider: ^2.1.3`)
- **GOTCHA**: iOS'ta `getApplicationDocumentsDirectory()` sandbox içinde çalışır
- **MIRROR**: ISAR_MODEL (schema structure referansı)
- **VALIDATE**: `isar_service_test.dart` geçiyor (Task 8)

### Task 4: Router Kurulumu
- **ACTION**: go_router ile uygulama navigasyonunu kur

`lib/core/router/app_routes.dart`:
```dart
class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const session = '/session';
  static const brainDump = '/brain-dump';
  static const journal = '/journal';
  static const thoughtCatalog = '/thought-catalog';
}
```

`lib/core/router/app_router.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true, // dev'de aç, prod'da kapat
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      // Faz 2+: session, brainDump, journal route'ları eklenecek
    ],
  );
});
```
- **MIRROR**: ROUTER_PATTERN
- **GOTCHA**: `go_router` v14+ `GoRoute` içinde `builder` veya `pageBuilder` zorunlu
- **VALIDATE**: Home ekranına navigate ediliyor, `flutter run` çökmüyor

### Task 5: App Entry Point
- **ACTION**: main.dart ve app.dart oluştur

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: DilosApp(),
    ),
  );
}
```

`lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class DilosApp extends ConsumerWidget {
  const DilosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DILOS',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```
- **MIRROR**: RIVERPOD_PROVIDER, NAMING_CONVENTION
- **GOTCHA**: `WidgetsFlutterBinding.ensureInitialized()` async init için main'de şart
- **VALIDATE**: Uygulama başlıyor, home ekranı görünüyor

### Task 6: Home Screen (Placeholder)
- **ACTION**: İlk ekranı oluştur — sonraki fazlarda doldurulacak

`lib/features/home/presentation/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DILOS', style: theme.textTheme.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hayatın zaten güzel.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
              const Spacer(),
              // Faz 2'de Auto Session butonu gelecek
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Seans Başlat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
```
- **MIRROR**: NAMING_CONVENTION, THEME_PATTERN
- **VALIDATE**: Ekran render ediliyor, overflow yok, renkler doğru

### Task 7: analysis_options.yaml
- **ACTION**: Linting kurallarını kur
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    always_use_package_imports: true
    prefer_final_locals: true
```
- **VALIDATE**: `flutter analyze` sıfır warning

### Task 8: DB Test
- **ACTION**: Isar write/read unit testi yaz

`test/core/database/isar_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  // Faz 2'de SessionEntry modeli eklenince bu test genişletilecek
  // Şimdilik Isar'ın açılabildiğini test ediyoruz

  test('Isar in-memory instance açılabilir', () async {
    await Isar.initializeIsarCore(download: false);
    final isar = await Isar.open(
      [], // Faz 2'de: [SessionEntrySchema]
      directory: '',
      name: 'test_db',
      inspector: false,
    );
    expect(isar.isOpen, true);
    await isar.close(deleteFromDisk: true);
  });
}
```
- **GOTCHA**: Test'te `Isar.initializeIsarCore(download: false)` zorunlu
- **VALIDATE**: `flutter test test/core/database/isar_service_test.dart` geçiyor

---

## Testing Strategy

### Unit Tests

| Test | Input | Beklenen Çıktı | Edge Case? |
|---|---|---|---|
| Isar açılış | Boş schema | `isar.isOpen == true` | Hayır |
| Isar çift açılış | İki kez getInstance | Aynı instance döner | Evet |
| Theme dark | - | `brightness == Brightness.dark` | Hayır |

### Edge Cases Checklist
- [ ] `path_provider` izin verilmeyince ne olur? (Android emülatör)
- [ ] Eski Isar DB versiyonu ile migration gerekli mi? (Faz 1'de yok, ilerisi için not)
- [ ] `GoRouter` debug log prod'da kapalı mı?

---

## Validation Commands

### Bağımlılık Kurulumu
```bash
flutter pub get
```
EXPECT: Sıfır hata, `pubspec.lock` oluştu

### Kod Üretimi (Riverpod + Isar)
```bash
dart run build_runner build --delete-conflicting-outputs
```
EXPECT: `.g.dart` dosyaları oluştu

### Statik Analiz
```bash
flutter analyze
```
EXPECT: Sıfır hata, sıfır warning

### Unit Testler
```bash
flutter test test/core/
```
EXPECT: Tüm testler geçiyor

### Uygulama Çalıştırma
```bash
flutter run
```
EXPECT: Home ekranı görünüyor, crash yok

### Manuel Kontrol
- [ ] Dark tema doğru renklerde mi?
- [ ] "DILOS" metni displayLarge style ile görünüyor mu?
- [ ] "Seans Başlat" butonu mor ve köşeleri yuvarlanmış mı?
- [ ] SafeArea çalışıyor mu (notch/home indicator)?

---

## Acceptance Criteria
- [ ] `flutter pub get` hatasız
- [ ] `flutter analyze` sıfır hata
- [ ] `flutter test test/core/` geçiyor
- [ ] `flutter run` home ekranını gösteriyor
- [ ] Design system (renkler, tipografi, spacing) uygulanmış
- [ ] Klasör yapısı feature-first clean architecture'a uygun
- [ ] Isar instance açılıp kapanabiliyor

## Completion Checklist
- [ ] Tüm dosyalar snake_case isimlendirme
- [ ] Sınıflar PascalCase
- [ ] Hardcoded renk/spacing yok (AppColors/AppSpacing kullanılıyor)
- [ ] `build_runner` çalıştırıldı, `.g.dart` dosyaları commit edildi
- [ ] `debugLogDiagnostics: true` SADECE debug modda

## Risks

| Risk | Olasılık | Etki | Çözüm |
|---|---|---|---|
| Isar iOS pod kurulumu sorunu | Orta | Yüksek | `cd ios && pod install` çalıştır |
| `build_runner` conflict | Düşük | Orta | `--delete-conflicting-outputs` flag |
| Riverpod v3 API farkı | Düşük | Orta | pub.dev'den güncel versiyonu doğrula |

## Notes
- Bu faz tamamlanmadan Faz 2'ye geçme — tüm sonraki fazlar bu iskelet üzerine inşa edilecek
- Renk paleti DILOS felsefesine göre seçildi: koyu lacivert (derinlik/zihin) + mor (sezgi) + mint (aksiyon/canlılık)
- `speech_to_text` ve `flutter_local_notifications` pubspec'te var ama Faz 2 ve 5'e kadar aktif kullanılmıyor
