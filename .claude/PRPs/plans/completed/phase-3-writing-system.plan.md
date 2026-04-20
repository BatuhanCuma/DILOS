# Plan: Phase 3 — Writing System (Brain Dump + Journal)

## Summary
Brain Dump ve Journal ekranlarını hayata geçir. Brain Dump, kullanıcının zihnindeki her şeyi sıfır friction ile dökebileceği serbest metin alanı. Journal ise iki yapılandırılmış prompt (minnet + yansıma) içeren günlük yazma deneyimi. Her iki ekran Isar'a kaydeder ve kayıtları listeler.

## User Story
As a burnout yaşayan bir kullanıcı, I want zihnimde olanları hızlıca yazabilmek ve günlük bir yansıma kaydı tutabilmek, so that kendimi daha iyi tanıyabileyim ve hayatımla yeniden bağ kurayım.

## Problem → Solution
Kullanıcı zihnini boşaltmak veya günlük tutmak istediğinde yapacağı şeyi bilmiyor → Anında açılan, prompt'suz Brain Dump + 2 sorulu Journal akışı sunar.

## Metadata
- **Complexity**: Large
- **Source PRD**: `.claude/PRPs/prds/dilos-mvp.prd.md`
- **PRD Phase**: Faz 3 — Writing System
- **Estimated Files**: 17 (2 generated) + 2 test = 19

---

## UX Design

### Before
```
┌─────────────────────────────┐
│  Ana Sayfa                  │
│  [Seans Başlat] butonu var  │
│  Brain Dump / Journal yok   │
└─────────────────────────────┘
```

### After
```
┌─────────────────────────────┐
│  Ana Sayfa                  │
│  [Seans Başlat]             │
│  [Brain Dump]               │
│  [Journal]                  │
└─────────────────────────────┘
         ↓                  ↓
┌──────────────┐   ┌──────────────┐
│ Brain Dump   │   │ Journal      │
│              │   │              │
│ [text area]  │   │ Minnet: []   │
│              │   │ Yansıma: []  │
│ [Kaydet]     │   │ [Kaydet]     │
│ ─────────    │   │ ─────────    │
│ Geçmiş:      │   │ Geçmiş:      │
│ • dün 22:14  │   │ • dün 21:00  │
└──────────────┘   └──────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| HomeScreen | 1 buton (Seans) | 3 buton | Brain Dump + Journal eklenir |
| /brain-dump | Yok | Serbest metin + liste | Anında yazma |
| /journal | Yok | 2 prompt + liste | Gratitude + reflection |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/features/session/data/models/session_entry.dart` | 1-22 | Isar @collection pattern |
| P0 | `lib/features/session/domain/repositories/session_repository.dart` | 1-9 | Abstract interface pattern |
| P0 | `lib/features/session/data/repositories/session_repository_impl.dart` | 1-41 | IsarRepository impl pattern |
| P0 | `lib/features/session/presentation/providers/session_provider.dart` | 1-130 | StateNotifier + enum status pattern |
| P0 | `lib/core/database/isar_provider.dart` | 1-19 | Schema registration + provider pattern |
| P1 | `lib/features/session/presentation/screens/session_screen.dart` | 1-102 | ConsumerWidget + switch expression |
| P1 | `lib/features/session/presentation/screens/session_complete_screen.dart` | 1-60 | Screen layout + navigation pattern |
| P1 | `lib/core/router/app_router.dart` | 1-26 | GoRoute registration |
| P1 | `lib/core/router/app_routes.dart` | 1-10 | Route constants (brainDump + journal already defined) |
| P2 | `lib/features/home/presentation/screens/home_screen.dart` | 1-58 | Button style pattern |
| P2 | `test/features/session/providers/session_provider_test.dart` | 1-128 | FakeRepo + waitForActive test pattern |

## External Documentation
| Topic | Source | Key Takeaway |
|---|---|---|
| Isar collections | established internal pattern | @collection, Id autoIncrement, late fields, @ignore for computed |
| build_runner | established internal pattern | `dart run build_runner build --delete-conflicting-outputs` after new @collection |

---

## Patterns to Mirror

### ISAR_COLLECTION_MODEL
```dart
// SOURCE: lib/features/session/data/models/session_entry.dart:1-22
import 'package:isar/isar.dart';
part 'session_entry.g.dart';

@collection
class SessionEntry {
  Id id = Isar.autoIncrement;
  late DateTime createdAt;
  late String status;
  late int questionCount;
  late String answersJson;

  @ignore
  bool get isCompleted => status == 'completed';
}
```

### REPOSITORY_INTERFACE
```dart
// SOURCE: lib/features/session/domain/repositories/session_repository.dart:1-9
abstract interface class SessionRepository {
  Future<void> saveSession(SessionEntry entry);
  Future<List<SessionEntry>> getRecentSessions({int limit = 10});
  Stream<List<SessionEntry>> watchSessions();
}
```

### ISAR_REPOSITORY_IMPL
```dart
// SOURCE: lib/features/session/data/repositories/session_repository_impl.dart:8-41
class IsarSessionRepository implements SessionRepository {
  const IsarSessionRepository(this._isar);
  final Isar _isar;

  @override
  Future<void> saveSession(SessionEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.sessionEntrys.put(entry);
    });
  }

  @override
  Future<List<SessionEntry>> getRecentSessions({int limit = 10}) {
    return _isar.sessionEntrys
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }
}
```

### STATE_NOTIFIER_PATTERN
```dart
// SOURCE: lib/features/session/presentation/providers/session_provider.dart:9-130
enum SessionStatus { loading, active, completed, error }

class SessionState {
  const SessionState({...});
  const SessionState.initial() : status = SessionStatus.loading, ...;
  SessionState copyWith({...}) => SessionState(...);
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._repository) : super(const SessionState.initial()) {
    _init();
  }
  final SessionRepository _repository;
}

final sessionProvider =
    StateNotifierProvider.autoDispose<SessionNotifier, SessionState>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return SessionNotifier(repo);
});
```

### ISAR_PROVIDER_REGISTRATION
```dart
// SOURCE: lib/core/database/isar_provider.dart:1-19
final isarProvider = FutureProvider<Isar>((ref) async {
  return IsarService.getInstance([SessionEntrySchema]);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => IsarSessionRepository(isar),
    loading: () => throw StateError('Isar henüz hazır değil'),
    error: (e, _) => throw StateError('Isar hatası: $e'),
  );
});
```

### CONSUMER_WIDGET_SCREEN
```dart
// SOURCE: lib/features/session/presentation/screens/session_screen.dart:12-47
class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider);
    return Scaffold(
      body: SafeArea(
        child: switch (state.status) {
          SessionStatus.loading => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          SessionStatus.error => Center(child: Text(state.errorMessage ?? 'Bir hata oluştu', style: const TextStyle(color: AppColors.error))),
          SessionStatus.active => _ActiveBody(state: state),
          SessionStatus.completed => const SizedBox.shrink(),
        },
      ),
    );
  }
}
```

### HOME_BUTTON_STYLE
```dart
// SOURCE: lib/features/home/presentation/screens/home_screen.dart:32-50
GestureDetector(
  onTap: () => context.go(AppRoutes.session),
  child: Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: Text('Seans Başlat', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16)),
  ),
),
```

### TEST_STRUCTURE
```dart
// SOURCE: test/features/session/providers/session_provider_test.dart:10-128
class FakeBrainDumpRepository implements BrainDumpRepository {
  final List<BrainDumpEntry> saved = [];
  @override Future<void> saveEntry(BrainDumpEntry entry) async => saved.add(entry);
  @override Future<List<BrainDumpEntry>> getRecentEntries({int limit = 20}) async => saved;
  @override Stream<List<BrainDumpEntry>> watchEntries() => Stream.value(saved);
}

// ProviderContainer with override
container = ProviderContainer(overrides: [
  brainDumpRepositoryProvider.overrideWithValue(fakeRepo),
]);
addTearDown(container.dispose);
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `lib/features/brain_dump/domain/repositories/brain_dump_repository.dart` | CREATE | Abstract interface |
| `lib/features/brain_dump/data/models/brain_dump_entry.dart` | CREATE | Isar @collection model |
| `lib/features/brain_dump/data/models/brain_dump_entry.g.dart` | AUTO-GEN | build_runner output |
| `lib/features/brain_dump/data/repositories/brain_dump_repository_impl.dart` | CREATE | Isar implementation |
| `lib/features/brain_dump/presentation/providers/brain_dump_provider.dart` | CREATE | StateNotifier + state |
| `lib/features/brain_dump/presentation/screens/brain_dump_screen.dart` | CREATE | UI screen |
| `lib/features/journal/domain/repositories/journal_repository.dart` | CREATE | Abstract interface |
| `lib/features/journal/data/models/journal_entry.dart` | CREATE | Isar @collection model |
| `lib/features/journal/data/models/journal_entry.g.dart` | AUTO-GEN | build_runner output |
| `lib/features/journal/data/repositories/journal_repository_impl.dart` | CREATE | Isar implementation |
| `lib/features/journal/presentation/providers/journal_provider.dart` | CREATE | StateNotifier + state |
| `lib/features/journal/presentation/screens/journal_screen.dart` | CREATE | UI screen |
| `lib/core/database/isar_provider.dart` | UPDATE | Add BrainDumpEntrySchema, JournalEntrySchema, new providers |
| `lib/core/router/app_router.dart` | UPDATE | Add /brain-dump and /journal routes |
| `lib/features/home/presentation/screens/home_screen.dart` | UPDATE | Add Brain Dump + Journal buttons |
| `test/features/brain_dump/providers/brain_dump_provider_test.dart` | CREATE | Unit tests |
| `test/features/journal/providers/journal_provider_test.dart` | CREATE | Unit tests |

## NOT Building
- Editing / deleting existing entries (V1 out of scope)
- Voice input for Brain Dump / Journal (session'da var, writing'de yok — basit tutuyoruz)
- Search / filter for past entries
- Character count / word limit UI
- Sync to Supabase (Faz sonrası)

---

## Step-by-Step Tasks

### Task 1: BrainDumpEntry Isar model
- **ACTION**: `lib/features/brain_dump/data/models/brain_dump_entry.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:isar/isar.dart';
  part 'brain_dump_entry.g.dart';

  @collection
  class BrainDumpEntry {
    Id id = Isar.autoIncrement;
    late DateTime createdAt;
    late String content;

    @ignore
    bool get isEmpty => content.trim().isEmpty;
  }
  ```
- **MIRROR**: ISAR_COLLECTION_MODEL
- **IMPORTS**: `package:isar/isar.dart`
- **GOTCHA**: `part 'brain_dump_entry.g.dart';` satırı gerekli — build_runner bunu üretecek. Klasörü de oluştur.
- **VALIDATE**: Dosya kaydedildi, `part` directive var

### Task 2: JournalEntry Isar model
- **ACTION**: `lib/features/journal/data/models/journal_entry.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:isar/isar.dart';
  part 'journal_entry.g.dart';

  @collection
  class JournalEntry {
    Id id = Isar.autoIncrement;
    late DateTime createdAt;
    late String gratitude;   // "Bugün minnettar olduğun şeyler"
    late String reflection;  // "Bugün nasıl geçti?"

    @ignore
    bool get isEmpty => gratitude.trim().isEmpty && reflection.trim().isEmpty;
  }
  ```
- **MIRROR**: ISAR_COLLECTION_MODEL
- **IMPORTS**: `package:isar/isar.dart`
- **GOTCHA**: `part 'journal_entry.g.dart';` ekle
- **VALIDATE**: Dosya kaydedildi

### Task 3: build_runner — generate .g.dart files
- **ACTION**: `dart run build_runner build --delete-conflicting-outputs` çalıştır
- **IMPLEMENT**: Terminal komutunu çalıştır
- **MIRROR**: Faz 2'de aynı komut kullanıldı
- **GOTCHA**: Komut `brain_dump_entry.g.dart` ve `journal_entry.g.dart` üretecek. Hata varsa import path'lerini kontrol et.
- **VALIDATE**: `brain_dump_entry.g.dart` ve `journal_entry.g.dart` dosyaları oluştu

### Task 4: BrainDumpRepository interface
- **ACTION**: `lib/features/brain_dump/domain/repositories/brain_dump_repository.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import '../../data/models/brain_dump_entry.dart';

  abstract interface class BrainDumpRepository {
    Future<void> saveEntry(BrainDumpEntry entry);
    Future<List<BrainDumpEntry>> getRecentEntries({int limit = 20});
    Stream<List<BrainDumpEntry>> watchEntries();
  }
  ```
- **MIRROR**: REPOSITORY_INTERFACE
- **IMPORTS**: `../../data/models/brain_dump_entry.dart`
- **GOTCHA**: `abstract interface class` (Dart 3 keyword) — not `abstract class`
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 5: JournalRepository interface
- **ACTION**: `lib/features/journal/domain/repositories/journal_repository.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import '../../data/models/journal_entry.dart';

  abstract interface class JournalRepository {
    Future<void> saveEntry(JournalEntry entry);
    Future<List<JournalEntry>> getRecentEntries({int limit = 20});
    Stream<List<JournalEntry>> watchEntries();
  }
  ```
- **MIRROR**: REPOSITORY_INTERFACE
- **GOTCHA**: `abstract interface class`
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 6: IsarBrainDumpRepository implementation
- **ACTION**: `lib/features/brain_dump/data/repositories/brain_dump_repository_impl.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:isar/isar.dart';
  import '../../domain/repositories/brain_dump_repository.dart';
  import '../models/brain_dump_entry.dart';

  class IsarBrainDumpRepository implements BrainDumpRepository {
    const IsarBrainDumpRepository(this._isar);
    final Isar _isar;

    @override
    Future<void> saveEntry(BrainDumpEntry entry) async {
      await _isar.writeTxn(() async {
        await _isar.brainDumpEntrys.put(entry);
      });
    }

    @override
    Future<List<BrainDumpEntry>> getRecentEntries({int limit = 20}) {
      return _isar.brainDumpEntrys
          .where()
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();
    }

    @override
    Stream<List<BrainDumpEntry>> watchEntries() {
      return _isar.brainDumpEntrys.where().watch(fireImmediately: true);
    }
  }
  ```
- **MIRROR**: ISAR_REPOSITORY_IMPL
- **GOTCHA**: Isar otomatik `brainDumpEntrys` collection ismi üretir (camelCase, plural). Generated .g.dart'ta kontrol et.
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 7: IsarJournalRepository implementation
- **ACTION**: `lib/features/journal/data/repositories/journal_repository_impl.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:isar/isar.dart';
  import '../../domain/repositories/journal_repository.dart';
  import '../models/journal_entry.dart';

  class IsarJournalRepository implements JournalRepository {
    const IsarJournalRepository(this._isar);
    final Isar _isar;

    @override
    Future<void> saveEntry(JournalEntry entry) async {
      await _isar.writeTxn(() async {
        await _isar.journalEntrys.put(entry);
      });
    }

    @override
    Future<List<JournalEntry>> getRecentEntries({int limit = 20}) {
      return _isar.journalEntrys
          .where()
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();
    }

    @override
    Stream<List<JournalEntry>> watchEntries() {
      return _isar.journalEntrys.where().watch(fireImmediately: true);
    }
  }
  ```
- **MIRROR**: ISAR_REPOSITORY_IMPL
- **GOTCHA**: `journalEntrys` (Isar pluralization — "y" → "ys" değil, sadece "s" ekler "y"yi korur — generated .g.dart'a bak)
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 8: isar_provider.dart güncelle
- **ACTION**: `lib/core/database/isar_provider.dart` güncelle — 3 yeni şey ekle
- **IMPLEMENT**: Dosyayı şu şekilde yeniden yaz:
  ```dart
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
  import 'isar_service.dart';

  final isarProvider = FutureProvider<Isar>((ref) async {
    return IsarService.getInstance([
      SessionEntrySchema,
      BrainDumpEntrySchema,
      JournalEntrySchema,
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
  ```
- **MIRROR**: ISAR_PROVIDER_REGISTRATION
- **GOTCHA**: `IsarService.getInstance` singleton — tüm schema'ları TEK seferde açılışta vermelisin. Sonradan eklenen schema'lar çalışmaz. Yani mevcut `[SessionEntrySchema]` listesini genişlet, yeni provider aç.
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 9: BrainDumpProvider (state + notifier)
- **ACTION**: `lib/features/brain_dump/presentation/providers/brain_dump_provider.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../data/models/brain_dump_entry.dart';
  import '../../domain/repositories/brain_dump_repository.dart';
  import '../../../../core/database/isar_provider.dart';

  enum BrainDumpStatus { idle, saving, saved, error }

  class BrainDumpState {
    const BrainDumpState({
      required this.status,
      required this.recentEntries,
      this.errorMessage,
    });

    const BrainDumpState.initial()
        : status = BrainDumpStatus.idle,
          recentEntries = const [],
          errorMessage = null;

    final BrainDumpStatus status;
    final List<BrainDumpEntry> recentEntries;
    final String? errorMessage;

    BrainDumpState copyWith({
      BrainDumpStatus? status,
      List<BrainDumpEntry>? recentEntries,
      String? errorMessage,
    }) =>
        BrainDumpState(
          status: status ?? this.status,
          recentEntries: recentEntries ?? this.recentEntries,
          errorMessage: errorMessage,
        );
  }

  class BrainDumpNotifier extends StateNotifier<BrainDumpState> {
    BrainDumpNotifier(this._repository) : super(const BrainDumpState.initial()) {
      _loadRecent();
    }

    final BrainDumpRepository _repository;

    Future<void> _loadRecent() async {
      try {
        final entries = await _repository.getRecentEntries();
        state = state.copyWith(recentEntries: entries);
      } on Exception catch (e) {
        state = state.copyWith(
          status: BrainDumpStatus.error,
          errorMessage: e.toString(),
        );
      }
    }

    Future<void> save(String content) async {
      final trimmed = content.trim();
      if (trimmed.isEmpty) return;

      state = state.copyWith(status: BrainDumpStatus.saving);
      try {
        final entry = BrainDumpEntry()
          ..createdAt = DateTime.now()
          ..content = trimmed;
        await _repository.saveEntry(entry);
        final updated = await _repository.getRecentEntries();
        state = state.copyWith(
          status: BrainDumpStatus.saved,
          recentEntries: updated,
        );
      } on Exception catch (e) {
        state = state.copyWith(
          status: BrainDumpStatus.error,
          errorMessage: e.toString(),
        );
      }
    }

    void reset() => state = state.copyWith(status: BrainDumpStatus.idle);
  }

  final brainDumpProvider =
      StateNotifierProvider.autoDispose<BrainDumpNotifier, BrainDumpState>((ref) {
    final repo = ref.watch(brainDumpRepositoryProvider);
    return BrainDumpNotifier(repo);
  });
  ```
- **MIRROR**: STATE_NOTIFIER_PATTERN
- **GOTCHA**: `errorMessage` in copyWith: `errorMessage: errorMessage` (NOT `errorMessage ?? this.errorMessage`) — allows resetting error to null
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 10: JournalProvider (state + notifier)
- **ACTION**: `lib/features/journal/presentation/providers/journal_provider.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../data/models/journal_entry.dart';
  import '../../domain/repositories/journal_repository.dart';
  import '../../../../core/database/isar_provider.dart';

  enum JournalStatus { idle, saving, saved, error }

  class JournalState {
    const JournalState({
      required this.status,
      required this.recentEntries,
      this.errorMessage,
    });

    const JournalState.initial()
        : status = JournalStatus.idle,
          recentEntries = const [],
          errorMessage = null;

    final JournalStatus status;
    final List<JournalEntry> recentEntries;
    final String? errorMessage;

    JournalState copyWith({
      JournalStatus? status,
      List<JournalEntry>? recentEntries,
      String? errorMessage,
    }) =>
        JournalState(
          status: status ?? this.status,
          recentEntries: recentEntries ?? this.recentEntries,
          errorMessage: errorMessage,
        );
  }

  class JournalNotifier extends StateNotifier<JournalState> {
    JournalNotifier(this._repository) : super(const JournalState.initial()) {
      _loadRecent();
    }

    final JournalRepository _repository;

    Future<void> _loadRecent() async {
      try {
        final entries = await _repository.getRecentEntries();
        state = state.copyWith(recentEntries: entries);
      } on Exception catch (e) {
        state = state.copyWith(
          status: JournalStatus.error,
          errorMessage: e.toString(),
        );
      }
    }

    Future<void> save(String gratitude, String reflection) async {
      final trimmedGratitude = gratitude.trim();
      final trimmedReflection = reflection.trim();
      if (trimmedGratitude.isEmpty && trimmedReflection.isEmpty) return;

      state = state.copyWith(status: JournalStatus.saving);
      try {
        final entry = JournalEntry()
          ..createdAt = DateTime.now()
          ..gratitude = trimmedGratitude
          ..reflection = trimmedReflection;
        await _repository.saveEntry(entry);
        final updated = await _repository.getRecentEntries();
        state = state.copyWith(
          status: JournalStatus.saved,
          recentEntries: updated,
        );
      } on Exception catch (e) {
        state = state.copyWith(
          status: JournalStatus.error,
          errorMessage: e.toString(),
        );
      }
    }

    void reset() => state = state.copyWith(status: JournalStatus.idle);
  }

  final journalProvider =
      StateNotifierProvider.autoDispose<JournalNotifier, JournalState>((ref) {
    final repo = ref.watch(journalRepositoryProvider);
    return JournalNotifier(repo);
  });
  ```
- **MIRROR**: STATE_NOTIFIER_PATTERN
- **GOTCHA**: `save(gratitude, reflection)` — her ikisi de boşsa erken dön
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 11: BrainDumpScreen UI
- **ACTION**: `lib/features/brain_dump/presentation/screens/brain_dump_screen.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:intl/intl.dart';
  import '../providers/brain_dump_provider.dart';
  import '../../../../core/theme/app_colors.dart';
  import '../../../../core/theme/app_spacing.dart';

  class BrainDumpScreen extends ConsumerStatefulWidget {
    const BrainDumpScreen({super.key});

    @override
    ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
  }

  class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> {
    late final TextEditingController _controller;

    @override
    void initState() {
      super.initState();
      _controller = TextEditingController();
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    Future<void> _save() async {
      await ref.read(brainDumpProvider.notifier).save(_controller.text);
      _controller.clear();
    }

    @override
    Widget build(BuildContext context) {
      final state = ref.watch(brainDumpProvider);
      final theme = Theme.of(context);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Brain Dump'),
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
                  'Kafanda ne var? Yaz, dökelemle.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceDim,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  autofocus: true,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Buraya yaz...',
                    hintStyle: TextStyle(color: AppColors.onSurfaceDim),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: state.status == BrainDumpStatus.saving ? null : _save,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: state.status == BrainDumpStatus.saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Kaydet',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
                if (state.status == BrainDumpStatus.saved) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Center(
                    child: Text(
                      'Kaydedildi ✓',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (state.recentEntries.isNotEmpty) ...[
                  Text('Geçmiş', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.recentEntries.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final entry = state.recentEntries[i];
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('d MMM HH:mm', 'tr_TR')
                                    .format(entry.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceDim),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                entry.content,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }
  ```
- **MIRROR**: CONSUMER_WIDGET_SCREEN, HOME_BUTTON_STYLE
- **IMPORTS**: `intl` paketi (zaten pubspec'te var), ConsumerStatefulWidget (TextEditingController lifecycle için)
- **GOTCHA**: `ConsumerStatefulWidget` kullan (TextEditingController dispose gerekiyor). `autofocus: true` — ekran açılınca klavye anında çıkar (sıfır friction hedefi).
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 12: JournalScreen UI
- **ACTION**: `lib/features/journal/presentation/screens/journal_screen.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:intl/intl.dart';
  import '../providers/journal_provider.dart';
  import '../../../../core/theme/app_colors.dart';
  import '../../../../core/theme/app_spacing.dart';

  class JournalScreen extends ConsumerStatefulWidget {
    const JournalScreen({super.key});

    @override
    ConsumerState<JournalScreen> createState() => _JournalScreenState();
  }

  class _JournalScreenState extends ConsumerState<JournalScreen> {
    late final TextEditingController _gratitudeController;
    late final TextEditingController _reflectionController;

    @override
    void initState() {
      super.initState();
      _gratitudeController = TextEditingController();
      _reflectionController = TextEditingController();
    }

    @override
    void dispose() {
      _gratitudeController.dispose();
      _reflectionController.dispose();
      super.dispose();
    }

    Future<void> _save() async {
      await ref.read(journalProvider.notifier).save(
            _gratitudeController.text,
            _reflectionController.text,
          );
      _gratitudeController.clear();
      _reflectionController.clear();
    }

    @override
    Widget build(BuildContext context) {
      final state = ref.watch(journalProvider);
      final theme = Theme.of(context);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Journal'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PromptField(
                  label: 'Minnet',
                  hint: 'Bugün minnettar olduğun şeyler...',
                  controller: _gratitudeController,
                  theme: theme,
                ),
                const SizedBox(height: AppSpacing.md),
                _PromptField(
                  label: 'Yansıma',
                  hint: 'Bugün nasıl geçti?',
                  controller: _reflectionController,
                  theme: theme,
                ),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: state.status == JournalStatus.saving ? null : _save,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: state.status == JournalStatus.saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Kaydet',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
                if (state.status == JournalStatus.saved) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Center(
                    child: Text(
                      'Kaydedildi ✓',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
                if (state.recentEntries.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Geçmiş', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ...state.recentEntries.map((entry) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('d MMM HH:mm', 'tr_TR')
                                    .format(entry.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceDim),
                              ),
                              if (entry.gratitude.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text('Minnet: ${entry.gratitude}',
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                              if (entry.reflection.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text('Yansıma: ${entry.reflection}',
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }

  class _PromptField extends StatelessWidget {
    const _PromptField({
      required this.label,
      required this.hint,
      required this.controller,
      required this.theme,
    });

    final String label;
    final String hint;
    final TextEditingController controller;
    final ThemeData theme;

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            maxLines: 4,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.onSurfaceDim),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );
    }
  }
  ```
- **MIRROR**: CONSUMER_WIDGET_SCREEN, HOME_BUTTON_STYLE
- **GOTCHA**: `SingleChildScrollView` kullan — 2 text field + liste uzun olabilir, overflow önle
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 13: app_router.dart güncelle
- **ACTION**: `lib/core/router/app_router.dart` güncelle — /brain-dump ve /journal route'larını ekle
- **IMPLEMENT**: Mevcut dosyaya yeni import + GoRoute'ları ekle:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import '../../features/home/presentation/screens/home_screen.dart';
  import '../../features/session/presentation/screens/session_screen.dart';
  import '../../features/session/presentation/screens/session_complete_screen.dart';
  import '../../features/brain_dump/presentation/screens/brain_dump_screen.dart';
  import '../../features/journal/presentation/screens/journal_screen.dart';
  import 'app_routes.dart';

  final routerProvider = Provider<GoRouter>((ref) {
    return GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
        GoRoute(path: AppRoutes.session, builder: (context, state) => const SessionScreen()),
        GoRoute(path: AppRoutes.sessionComplete, builder: (context, state) => const SessionCompleteScreen()),
        GoRoute(path: AppRoutes.brainDump, builder: (context, state) => const BrainDumpScreen()),
        GoRoute(path: AppRoutes.journal, builder: (context, state) => const JournalScreen()),
      ],
    );
  });
  ```
- **MIRROR**: CONSUMER_WIDGET_SCREEN (router pattern)
- **GOTCHA**: `AppRoutes.brainDump` ve `AppRoutes.journal` zaten `app_routes.dart`'ta tanımlı
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 14: home_screen.dart güncelle — 2 yeni buton
- **ACTION**: `lib/features/home/presentation/screens/home_screen.dart` güncelle
- **IMPLEMENT**: Mevcut "Seans Başlat" butonundan sonra Brain Dump ve Journal butonlarını ekle. Butonlar biraz daha subdued renk (surfaceElevated + border) ile:
  ```dart
  // Seans Başlat butonundan sonra:
  const SizedBox(height: AppSpacing.sm),
  GestureDetector(
    onTap: () => context.go(AppRoutes.brainDump),
    child: Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        'Brain Dump',
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppColors.onSurface,
          fontSize: 16,
        ),
      ),
    ),
  ),
  const SizedBox(height: AppSpacing.sm),
  GestureDetector(
    onTap: () => context.go(AppRoutes.journal),
    child: Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        'Journal',
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppColors.onSurface,
          fontSize: 16,
        ),
      ),
    ),
  ),
  ```
- **MIRROR**: HOME_BUTTON_STYLE
- **GOTCHA**: `AppColors.primary.withOpacity(0.3)` — deprecated Flutter 3.x'te `withValues(alpha: 0.3)` kullanılması önerilir, ama `withOpacity` hâlâ çalışır. Analiz uyarısı verirse `withValues` ile değiştir.
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 15: BrainDump provider unit tests
- **ACTION**: `test/features/brain_dump/providers/brain_dump_provider_test.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'dart:async';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:dilos/features/brain_dump/data/models/brain_dump_entry.dart';
  import 'package:dilos/features/brain_dump/domain/repositories/brain_dump_repository.dart';
  import 'package:dilos/features/brain_dump/presentation/providers/brain_dump_provider.dart';
  import 'package:dilos/core/database/isar_provider.dart';

  class FakeBrainDumpRepository implements BrainDumpRepository {
    final List<BrainDumpEntry> _entries = [];

    @override
    Future<void> saveEntry(BrainDumpEntry entry) async => _entries.add(entry);

    @override
    Future<List<BrainDumpEntry>> getRecentEntries({int limit = 20}) async =>
        List.unmodifiable(_entries);

    @override
    Stream<List<BrainDumpEntry>> watchEntries() =>
        Stream.value(List.unmodifiable(_entries));
  }

  Future<void> waitForIdle(ProviderContainer container) async {
    if (container.read(brainDumpProvider).status != BrainDumpStatus.saving) return;
    final completer = Completer<void>();
    final sub = container.listen(brainDumpProvider, (_, next) {
      if (next.status != BrainDumpStatus.saving && !completer.isCompleted) {
        completer.complete();
      }
    });
    await completer.future.timeout(const Duration(seconds: 5));
    sub.close();
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

      test('başlangıç durumu idle ve boş liste', () {
        expect(container.read(brainDumpProvider).status, BrainDumpStatus.idle);
      });

      test('save sonrası status saved olur', () async {
        await container.read(brainDumpProvider.notifier).save('Test içerik');
        expect(container.read(brainDumpProvider).status, BrainDumpStatus.saved);
      });

      test('save sonrası entry repository\'e kaydedilir', () async {
        await container.read(brainDumpProvider.notifier).save('Test içerik');
        expect(fakeRepo._entries, hasLength(1));
        expect(fakeRepo._entries.first.content, 'Test içerik');
      });

      test('boş içerik kaydedilmez', () async {
        await container.read(brainDumpProvider.notifier).save('   ');
        expect(fakeRepo._entries, isEmpty);
      });

      test('save sonrası recentEntries güncellenir', () async {
        await container.read(brainDumpProvider.notifier).save('Test içerik');
        expect(container.read(brainDumpProvider).recentEntries, hasLength(1));
      });

      test('reset idle duruma döner', () async {
        await container.read(brainDumpProvider.notifier).save('Test');
        container.read(brainDumpProvider.notifier).reset();
        expect(container.read(brainDumpProvider).status, BrainDumpStatus.idle);
      });
    });
  }
  ```
- **MIRROR**: TEST_STRUCTURE
- **GOTCHA**: `FakeBrainDumpRepository` `_entries` field private — test methodları `fakeRepo._entries` ile erişir (same library)
- **VALIDATE**: `flutter test test/features/brain_dump/` — 6/6 pass

### Task 16: Journal provider unit tests
- **ACTION**: `test/features/journal/providers/journal_provider_test.dart` oluştur
- **IMPLEMENT**: BrainDump test'ine benzer yapı, `JournalNotifier` için:
  ```dart
  import 'dart:async';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:dilos/features/journal/data/models/journal_entry.dart';
  import 'package:dilos/features/journal/domain/repositories/journal_repository.dart';
  import 'package:dilos/features/journal/presentation/providers/journal_provider.dart';
  import 'package:dilos/core/database/isar_provider.dart';

  class FakeJournalRepository implements JournalRepository {
    final List<JournalEntry> _entries = [];

    @override
    Future<void> saveEntry(JournalEntry entry) async => _entries.add(entry);

    @override
    Future<List<JournalEntry>> getRecentEntries({int limit = 20}) async =>
        List.unmodifiable(_entries);

    @override
    Stream<List<JournalEntry>> watchEntries() =>
        Stream.value(List.unmodifiable(_entries));
  }

  void main() {
    group('JournalNotifier', () {
      late ProviderContainer container;
      late FakeJournalRepository fakeRepo;

      setUp(() {
        fakeRepo = FakeJournalRepository();
        container = ProviderContainer(overrides: [
          journalRepositoryProvider.overrideWithValue(fakeRepo),
        ]);
      });

      tearDown(() => container.dispose());

      test('başlangıç durumu idle', () {
        expect(container.read(journalProvider).status, JournalStatus.idle);
      });

      test('save sonrası status saved olur', () async {
        await container.read(journalProvider.notifier).save('Minnet', 'Yansıma');
        expect(container.read(journalProvider).status, JournalStatus.saved);
      });

      test('save sonrası entry repository\'e kaydedilir', () async {
        await container.read(journalProvider.notifier).save('Minnet A', 'Yansıma B');
        expect(fakeRepo._entries, hasLength(1));
        expect(fakeRepo._entries.first.gratitude, 'Minnet A');
        expect(fakeRepo._entries.first.reflection, 'Yansıma B');
      });

      test('iki alan da boşsa kaydedilmez', () async {
        await container.read(journalProvider.notifier).save('  ', '  ');
        expect(fakeRepo._entries, isEmpty);
      });

      test('sadece gratitude dolu olsa kaydedilir', () async {
        await container.read(journalProvider.notifier).save('Minnet var', '');
        expect(fakeRepo._entries, hasLength(1));
      });

      test('save sonrası recentEntries güncellenir', () async {
        await container.read(journalProvider.notifier).save('Minnet', 'Yansıma');
        expect(container.read(journalProvider).recentEntries, hasLength(1));
      });
    });
  }
  ```
- **MIRROR**: TEST_STRUCTURE
- **VALIDATE**: `flutter test test/features/journal/` — 6/6 pass

---

## Testing Strategy

### Unit Tests

| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| BrainDump idle start | init | status=idle, entries=[] | No |
| BrainDump save | "Test içerik" | status=saved, 1 entry | No |
| BrainDump empty skip | "   " | entries still empty | Yes |
| BrainDump recent update | save | recentEntries.length=1 | No |
| BrainDump reset | after save | status=idle | No |
| Journal idle start | init | status=idle | No |
| Journal save both | "Minnet","Yansıma" | 1 entry, correct fields | No |
| Journal both empty | "  ","  " | no save | Yes |
| Journal only gratitude | "Minnet","" | saved (partial ok) | Yes |
| Journal recent update | save | recentEntries.length=1 | No |

### Edge Cases Checklist
- [x] Empty content — skipped without save
- [x] Only whitespace — trimmed, treated as empty
- [x] Partial journal entry (one field only) — allowed
- [ ] Very long content — TextField has no hard limit (fine for MVP)
- [ ] Concurrent saves — StateNotifier is single-threaded (no issue)

---

## Validation Commands

### Static Analysis
```bash
flutter analyze
```
EXPECT: Zero issues

### Unit Tests
```bash
flutter test test/features/brain_dump/
flutter test test/features/journal/
```
EXPECT: All tests pass

### Full Test Suite
```bash
flutter test
```
EXPECT: No regressions (9 existing + 12 new = 21 total)

### Build Check
```bash
flutter build apk --debug
```
EXPECT: BUILD SUCCESSFUL

### Manual Validation
- [ ] Ana sayfada "Brain Dump" ve "Journal" butonları görünüyor
- [ ] Brain Dump butonuna basınca /brain-dump açılıyor, klavye otomatik çıkıyor
- [ ] Brain Dump: yazıp "Kaydet"e basınca "Kaydedildi ✓" görünüyor, liste güncelleniyor
- [ ] Journal butonuna basınca /journal açılıyor
- [ ] Journal: iki alana yazıp kaydet — her iki alanda geçmişte görünüyor
- [ ] Geri gidince Ana Sayfa açılıyor (AppBar back button)

---

## Acceptance Criteria
- [ ] Tüm tasklar tamamlandı
- [ ] `flutter analyze` — 0 hata
- [ ] `flutter test` — 21/21 geçti
- [ ] Brain Dump ekranı veri kaydedip listeleyebiliyor
- [ ] Journal ekranı veri kaydedip listeleyebiliyor
- [ ] Ana sayfadan her iki ekrana navigasyon çalışıyor
- [ ] Lint hatası yok

## Completion Checklist
- [ ] Isar schema'ları isarProvider'a eklendi
- [ ] build_runner çalıştırıldı, .g.dart dosyaları üretildi
- [ ] Test pattern (FakeRepo + ProviderContainer) takip edildi
- [ ] ConsumerStatefulWidget kullanıldı (TextEditingController)
- [ ] Hardcoded değer yok
- [ ] Dart coding style: `final`, `const`, `late` doğru kullanıldı

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Isar collection name (plural) yanlış | Medium | Build hata | Generated .g.dart'ta `get brainDumpEntrys` adını kontrol et |
| intl locale 'tr_TR' uyarısı | Low | Lint uyarı | DateFormat çağrısından önce locale init gerekebilir — basit string format fallback hazır tut |
| withOpacity deprecation uyarısı | Medium | Lint uyarı | `withValues(alpha: 0.3)` ile değiştir |

## Notes
- Faz 3 ve Faz 4 (AI Layer) paralel geliştirilebilir — bu plan Faz 4'e bağımlı değil
- `intl` paketi zaten pubspec.yaml'da var — ek bağımlılık yok
- Isar singleton: ilk `IsarService.getInstance()` çağrısında tüm schema'lar verilmeli. Uygulama yeniden başlatılmadan schema eklenemez.
