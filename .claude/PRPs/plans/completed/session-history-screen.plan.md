# Plan: Session History Screen

## Summary
Geçmiş seansları listeleyen bir ekran eklenir. Her seans kartı tarih, soru sayısı ve AI etiketlerini (mood/energy) gösterir; karta tıklanınca cevaplar açılır. Veri zaten DB'de mevcut — sadece görünür kılınacak.

## User Story
As a DILOS user, I want to see my past sessions with their answers and AI tags, so that I can reflect on my patterns over time.

## Problem → Solution
Seans verileri DB'de birikmiş ama kullanıcıya gösterilmiyor → Session History ekranı ile görünür hale getirilir.

## Metadata
- **Complexity**: Medium
- **Source PRD**: N/A (PRD'de "Thought Catalog" olarak bahsedilen özelliğin ilk adımı)
- **PRD Phase**: standalone
- **Estimated Files**: 6

---

## UX Design

### Before
```
┌─────────────────────────┐
│  DILOS     (settings)   │
│  Hayatın zaten güzel.   │
│                         │
│  [Seans Başlat]         │
│  [Brain Dump]           │
│  [Journal]              │
│                         │
│  (seanslar kaybolup     │
│   gidiyor, görünmüyor)  │
└─────────────────────────┘
```

### After
```
┌─────────────────────────┐    ┌─────────────────────────┐
│  DILOS     (settings)   │    │ ← Seans Geçmişi          │
│  Hayatın zaten güzel.   │    │                          │
│                         │    │ ┌──────────────────────┐ │
│  [Seans Başlat]         │    │ │ 18 Nis 09:30 · 3 soru│ │
│  [Brain Dump]           │──▶ │ │ 😌 neutral  ⚡ medium │ │
│  [Journal]              │    │ ├──────────────────────┤ │
│  [Seans Geçmişi]        │    │ │ Biraz yorgunum ama   │ │
│                         │    │ │ iyiyim genel olarak. │ │
└─────────────────────────┘    │ │ İş yerinde stres var.│ │
                               │ └──────────────────────┘ │
                               │                          │
                               │ ┌──────────────────────┐ │
                               │ │ 17 Nis 21:00 · 2 soru│ │
                               │ │ 😊 positive  ⚡ high  │ │
                               │ └──────────────────────┘ │
                               │                          │
                               │  (empty: Henüz seans     │
                               │   tamamlamadın.)         │
                               └─────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| HomeScreen | 3 buton | 4 buton | "Seans Geçmişi" eklenir |
| Seans Geçmişi | Yok | Liste ekranı | `context.push(AppRoutes.sessionHistory)` |
| Seans kartı | N/A | Genişleyip cevapları gösterir | `ExpansionTile` ile |
| AI tag yok | N/A | Tag satırı gösterilmez | `tagsJson == null` → sadece tarih/soru sayısı |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/features/session/data/models/session_entry.dart` | all | SessionEntry model — answers/tagsJson getters |
| P0 | `lib/core/ai/session_tags.dart` | all | SessionTags.fromJson — AI tag parse pattern |
| P0 | `lib/features/session/domain/repositories/session_repository.dart` | all | watchSessions() — reactive stream |
| P0 | `lib/features/home/presentation/screens/home_screen.dart` | all | Buton ekleme pattern'i |
| P1 | `lib/features/brain_dump/presentation/screens/brain_dump_screen.dart` | 108-155 | Liste + empty state pattern |
| P1 | `lib/features/session/presentation/screens/session_complete_screen.dart` | all | Screen scaffold pattern |
| P2 | `lib/core/router/app_router.dart` | all | Route ekleme pattern |
| P2 | `lib/core/theme/app_colors.dart` | all | Renk referansları |

## External Documentation
No external research needed — feature uses established internal patterns.

---

## Patterns to Mirror

### STREAM_PROVIDER_PATTERN
```dart
// SOURCE: lib/core/database/isar_provider.dart:17-24
final isarProvider = FutureProvider<Isar>((ref) async {
  return IsarService.getInstance([...]);
});
```
`sessionHistoryProvider` için `StreamProvider` kullanılacak:
```dart
final sessionHistoryProvider = StreamProvider<List<SessionEntry>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchSessions();
});
```

### CONSUMER_WIDGET_PATTERN
```dart
// SOURCE: lib/features/session/presentation/screens/session_complete_screen.dart:7-11
class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
```
SessionHistoryScreen → `ConsumerWidget` (ref.watch gerekiyor).

### APPBAR_PATTERN
```dart
// SOURCE: lib/features/brain_dump/presentation/screens/brain_dump_screen.dart:41-45
appBar: AppBar(
  title: const Text('Brain Dump'),
  backgroundColor: Colors.transparent,
  elevation: 0,
),
```
Aynı pattern, başlık: `'Seans Geçmişi'`.

### LIST_ENTRY_CARD_PATTERN
```dart
// SOURCE: lib/features/brain_dump/presentation/screens/brain_dump_screen.dart:119-144
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(DateFormat('d MMM HH:mm', 'tr_TR').format(entry.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceDim)),
      ...
    ],
  ),
)
```

### EMPTY_STATE_PATTERN
```dart
// SOURCE: lib/features/brain_dump/presentation/screens/brain_dump_screen.dart:148-175
] else ...[
  const SizedBox(height: AppSpacing.lg),
  Center(
    child: Column(
      children: [
        const Icon(Icons.edit_note_outlined, size: 48, color: AppColors.onSurfaceDim),
        const SizedBox(height: AppSpacing.sm),
        Text('Henüz bir şey yazmadın.', style: theme.textTheme.bodyMedium, ...),
      ],
    ),
  ),
],
```

### HOME_BUTTON_PATTERN
```dart
// SOURCE: lib/features/home/presentation/screens/home_screen.dart:72-93
GestureDetector(
  onTap: () => context.push(AppRoutes.brainDump),
  child: Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
    ),
    alignment: Alignment.center,
    child: Text('Brain Dump', style: theme.textTheme.labelLarge?.copyWith(
      color: AppColors.onSurface, fontSize: 16)),
  ),
),
```

### ROUTE_PATTERN
```dart
// SOURCE: lib/core/router/app_router.dart:35-38
GoRoute(
  path: AppRoutes.brainDump,
  builder: (context, state) => const BrainDumpScreen(),
),
```

### TEST_STREAM_PROVIDER_PATTERN
```dart
// SOURCE: test/features/brain_dump/providers/brain_dump_provider_test.dart:8-30
class FakeBrainDumpRepository implements BrainDumpRepository {
  final List<BrainDumpEntry> entries = [];
  @override
  Stream<List<BrainDumpEntry>> watchEntries() =>
      Stream.value(List.unmodifiable(entries));
}
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `lib/core/router/app_routes.dart` | UPDATE | `sessionHistory` route sabiti |
| `lib/features/session/presentation/providers/session_history_provider.dart` | CREATE | StreamProvider wrapping watchSessions() |
| `lib/features/session/presentation/screens/session_history_screen.dart` | CREATE | Seans listesi + expanson tile + empty state |
| `lib/core/router/app_router.dart` | UPDATE | SessionHistoryScreen route eklenir |
| `lib/features/home/presentation/screens/home_screen.dart` | UPDATE | "Seans Geçmişi" butonu |
| `test/features/session/providers/session_history_provider_test.dart` | CREATE | StreamProvider + boş liste + dolu liste testleri |

## NOT Building
- Seans detay sayfası (ayrı route) — tek ekranda expansion yeterli
- Seans silme — MVP scope dışı
- Filtreleme / arama — PRD scope dışı
- Seans tekrar etme — scope dışı
- Grafik / visualization — "Thought Catalog" V2'ye bırakıldı

---

## Step-by-Step Tasks

### Task 1: AppRoutes — sessionHistory ekle
- **ACTION**: `lib/core/router/app_routes.dart`'a `sessionHistory` sabiti ekle
- **IMPLEMENT**:
  ```dart
  static const sessionHistory = '/session-history';
  ```
  `settings` satırından önce ekle.
- **MIRROR**: Mevcut route sabitleri
- **GOTCHA**: `thoughtCatalog` zaten var ama kullanılmıyor — ona dokunma
- **VALIDATE**: `flutter analyze` passes

### Task 2: SessionHistoryProvider
- **ACTION**: `lib/features/session/presentation/providers/session_history_provider.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../data/models/session_entry.dart';
  import '../../../../core/database/isar_provider.dart';

  final sessionHistoryProvider = StreamProvider<List<SessionEntry>>((ref) {
    final repo = ref.watch(sessionRepositoryProvider);
    return repo.watchSessions();
  });
  ```
- **MIRROR**: STREAM_PROVIDER_PATTERN
- **IMPORTS**: `flutter_riverpod`, `session_entry.dart`, `isar_provider.dart`
- **GOTCHA**: `watchSessions()` zaten tüm seansları döner (`fireImmediately: true` ile), limit yok. `getRecentSessions()` yerine bunu kullan çünkü history ekranında tüm geçmiş gösterilmeli.
- **VALIDATE**: `flutter analyze` passes

### Task 3: SessionHistoryScreen
- **ACTION**: `lib/features/session/presentation/screens/session_history_screen.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:intl/intl.dart';
  import '../providers/session_history_provider.dart';
  import '../../data/models/session_entry.dart';
  import '../../../../core/ai/session_tags.dart';
  import '../../../../core/theme/app_colors.dart';
  import '../../../../core/theme/app_spacing.dart';

  class SessionHistoryScreen extends ConsumerWidget {
    const SessionHistoryScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final theme = Theme.of(context);
      final sessionsAsync = ref.watch(sessionHistoryProvider);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Seans Geçmişi'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: sessionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Hata: $e', style: const TextStyle(color: AppColors.error)),
            ),
            data: (sessions) {
              // Only show completed sessions
              final completed = sessions.where((s) => s.isCompleted).toList();
              if (completed.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_outlined, size: 64, color: AppColors.onSurfaceDim),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Henüz tamamlanmış seans yok.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'İlk seansını tamamla,\nburada görünecek.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceDim.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: completed.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) => _SessionCard(entry: completed[i]),
              );
            },
          ),
        ),
      );
    }
  }

  class _SessionCard extends StatelessWidget {
    const _SessionCard({required this.entry});
    final SessionEntry entry;

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      final dateStr = DateFormat('d MMM HH:mm', 'tr_TR').format(entry.createdAt);
      final tags = entry.isTagged
          ? SessionTags.fromJson(jsonDecode(entry.tagsJson!) as Map<String, dynamic>)
          : null;
      final answers = entry.answers;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$dateStr · ${entry.questionCount} soru',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
              if (tags != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _TagChip(label: _moodEmoji(tags.mood) + ' ' + tags.mood),
                    const SizedBox(width: AppSpacing.xs),
                    _TagChip(label: '⚡ ' + tags.energy),
                    if (tags.topics.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.xs),
                      _TagChip(label: tags.topics.first),
                    ],
                  ],
                ),
              ],
            ],
          ),
          children: answers.map((a) {
            final text = a['text'] as String? ?? '';
            if (text.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                '• $text',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }).toList(),
        ),
      );
    }

    String _moodEmoji(String mood) {
      return switch (mood) {
        'positive' => '😊',
        'negative' => '😞',
        'anxious' => '😰',
        'sad' => '😔',
        'excited' => '🤩',
        _ => '😌',
      };
    }
  }

  class _TagChip extends StatelessWidget {
    const _TagChip({required this.label});
    final String label;

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
          ),
        ),
      );
    }
  }
  ```
- **MIRROR**: APPBAR_PATTERN, LIST_ENTRY_CARD_PATTERN, EMPTY_STATE_PATTERN
- **IMPORTS**: `dart:convert`, `flutter`, `flutter_riverpod`, `intl`, providers, models, theme
- **GOTCHA**:
  - `entry.answers` getter zaten `jsonDecode` yapıyor → `answersJson`'ı doğrudan decode etme
  - `entry.tagsJson` null olabilir → `entry.isTagged` ile kontrol et
  - `ExpansionTile`'ın `shape`/`collapsedShape` ayarlanmazsa default Material border çıkar — her ikisi de `RoundedRectangleBorder(radius: 12)` olmalı
  - `answers.map().toList()` üzerindeki empty string'leri `SizedBox.shrink()` ile gizle — DB'de boş cevap olabilir
  - `switch` expression Dart 3+ gerektirir — proje Dart ^3.10.7 olduğu için sorun yok
- **VALIDATE**: `flutter analyze` passes

### Task 4: AppRouter — route ekle
- **ACTION**: `lib/core/router/app_router.dart`'a `SessionHistoryScreen` import + route ekle
- **IMPLEMENT**:
  Import satırı (diğer screen importlarının yanına):
  ```dart
  import '../../features/session/presentation/screens/session_history_screen.dart';
  ```
  Route (settings route'undan önce):
  ```dart
  GoRoute(
    path: AppRoutes.sessionHistory,
    builder: (context, state) => const SessionHistoryScreen(),
  ),
  ```
- **MIRROR**: ROUTE_PATTERN
- **GOTCHA**: Import yolu — `app_router.dart` `lib/core/router/` içinde, `session_history_screen.dart` `lib/features/session/presentation/screens/` içinde → `'../../features/session/presentation/screens/session_history_screen.dart'`
- **VALIDATE**: `flutter analyze` passes

### Task 5: HomeScreen — "Seans Geçmişi" butonu ekle
- **ACTION**: `lib/features/home/presentation/screens/home_screen.dart`'a 4. buton ekle
- **IMPLEMENT**: Journal butonundan sonra:
  ```dart
  const SizedBox(height: AppSpacing.sm),
  GestureDetector(
    onTap: () => context.push(AppRoutes.sessionHistory),
    child: Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'Seans Geçmişi',
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppColors.onSurface,
          fontSize: 16,
        ),
      ),
    ),
  ),
  ```
- **MIRROR**: HOME_BUTTON_PATTERN
- **GOTCHA**: `context.push()` kullan (geri tuşu için), `context.go()` değil — diğer butonlarla tutarlı
- **VALIDATE**: `flutter analyze` passes

### Task 6: SessionHistory provider test
- **ACTION**: `test/features/session/providers/session_history_provider_test.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:dilos/features/session/data/models/session_entry.dart';
  import 'package:dilos/features/session/domain/repositories/session_repository.dart';
  import 'package:dilos/features/session/presentation/providers/session_history_provider.dart';
  import 'package:dilos/core/database/isar_provider.dart';
  import 'package:isar/isar.dart';

  class FakeSessionRepository implements SessionRepository {
    final List<SessionEntry> _sessions = [];

    @override
    Stream<List<SessionEntry>> watchSessions() =>
        Stream.value(List.unmodifiable(_sessions));

    @override
    Future<List<SessionEntry>> getRecentSessions({int limit = 10}) async =>
        _sessions.take(limit).toList();

    @override
    Future<void> saveSession(SessionEntry entry) async => _sessions.add(entry);

    @override
    Future<void> updateTags(Id entryId, String tagsJson) async {}

    @override
    Future<List<dynamic>> getQuestions() async => [];

    void addSession(SessionEntry entry) => _sessions.add(entry);
  }

  SessionEntry _makeEntry({String status = 'completed'}) {
    final e = SessionEntry()
      ..createdAt = DateTime.now()
      ..status = status
      ..questionCount = 3
      ..answersJson = '[{"questionId":"q1","text":"Test cevap","inputType":"text","answeredAt":"${DateTime.now().toIso8601String()}"}]';
    return e;
  }

  void main() {
    group('sessionHistoryProvider', () {
      late ProviderContainer container;
      late FakeSessionRepository fakeRepo;

      setUp(() {
        fakeRepo = FakeSessionRepository();
        container = ProviderContainer(overrides: [
          sessionRepositoryProvider.overrideWithValue(fakeRepo),
        ]);
      });

      tearDown(() => container.dispose());

      test('boş liste ile loading sonrası data döner', () async {
        final result = await container.read(sessionHistoryProvider.future);
        expect(result, isEmpty);
      });

      test('eklenen seans listede görünür', () async {
        fakeRepo.addSession(_makeEntry());
        final result = await container.read(sessionHistoryProvider.future);
        expect(result.length, 1);
      });

      test('tüm status türleri listelenir (filtreleme ekranda)', () async {
        fakeRepo.addSession(_makeEntry(status: 'completed'));
        fakeRepo.addSession(_makeEntry(status: 'abandoned'));
        final result = await container.read(sessionHistoryProvider.future);
        expect(result.length, 2);
      });
    });
  }
  ```
- **MIRROR**: TEST_STREAM_PROVIDER_PATTERN
- **IMPORTS**: `flutter_test`, `flutter_riverpod`, session models/repo/provider, `isar`
- **GOTCHA**: `FakeSessionRepository.getQuestions()` `List<SessionQuestion>` değil `List<dynamic>` döndüreceği için tip uyumunu sağlamak gerekebilir — tam return type `Future<List<SessionQuestion>>` olmalı; import ekle.
- **VALIDATE**: `flutter test test/features/session/providers/session_history_provider_test.dart` passes

---

## Testing Strategy

### Unit Tests

| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| boş repo | watchSessions → [] | AsyncData([]) | No |
| 1 session | addSession + watch | AsyncData([entry]) | No |
| completed + abandoned | 2 entries | 2 döner (filtreleme UI'da) | No |

### Edge Cases Checklist
- [x] Boş liste → empty state gösterilir (`completed.isEmpty`)
- [x] `tagsJson == null` → AI chip satırı gösterilmez (`entry.isTagged` check)
- [x] Cevap metni boş string → `SizedBox.shrink()` ile gizlenir
- [x] `abandoned` seanslar → ekranda filtrelenir (`s.isCompleted` where clause)
- [ ] 100+ seans → `ListView` lazy render ediyor, sorun yok

---

## Validation Commands

### Static Analysis
```bash
flutter analyze
```
EXPECT: Zero issues

### Unit Tests
```bash
flutter test test/features/session/providers/session_history_provider_test.dart
```
EXPECT: 3 tests pass

### Full Test Suite
```bash
flutter test
```
EXPECT: 42/42 pass (39 existing + 3 new)

### Manual Validation
- [ ] HomeScreen'de "Seans Geçmişi" butonu görünüyor
- [ ] Seans yokken empty state gösteriliyor
- [ ] Seans tamamladıktan sonra listede görünüyor
- [ ] Karta tıklanınca cevaplar açılıyor
- [ ] AI etiketi olan seanslarda mood/energy chip'leri görünüyor
- [ ] AI etiketi olmayan (tagging pending) seanslarda chip yok — sadece tarih
- [ ] Geri tuşu (AppBar) çalışıyor

---

## Acceptance Criteria
- [ ] 6 task tamamlandı
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — 42/42
- [ ] HomeScreen'de buton var
- [ ] Geçmiş seanslar listeleniyor
- [ ] AI etiketleri gösteriliyor

## Completion Checklist
- [ ] `context.push()` kullanıldı (geri tuş için)
- [ ] `entry.isCompleted` ile filtreleme yapıldı
- [ ] `entry.isTagged` ile null-safe tag parse
- [ ] `ExpansionTile` shape ayarlandı (border leak önlenir)
- [ ] Empty state — icon + 2 satır metin

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `getQuestions()` fake impl tipi | Low | Test compile error | Import `SessionQuestion` + doğru return type |
| ExpansionTile default border | Medium | Görsel bozukluk | shape + collapsedShape set edildi |
| `answersJson` formatı değişmiş | Low | Runtime exception | `entry.answers` getter zaten try-free parse |

## Notes
- `watchSessions()` `fireImmediately: true` ile açılıyor → ilk frame'de liste hemen gelir, `loading` state çok kısa sürer
- Filtreleme (`s.isCompleted`) UI'da yapılıyor, provider'da değil — bu sayede test tüm seansları döndürebiliyor ve ekran kendi mantığını bağımsız uygulayabiliyor
- `_moodEmoji` için Dart 3 `switch` expression kullanıldı (proje Dart ^3.10.7)
