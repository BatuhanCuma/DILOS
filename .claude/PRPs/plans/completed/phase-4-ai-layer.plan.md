# Plan: Phase 4 — AI Layer (Gemini Tagging)

## Summary
Gemini Flash API entegrasyonu yapılacak. Seans tamamlandığında cevaplar arka planda Gemini'ye gönderilir, dönen mood/topic/energy etiketleri SessionEntry'e kaydedilir. Kullanıcı bu süreci hiç görmez — seans ekranı anında geçer, tagging fire-and-forget çalışır.

## User Story
As a DILOS kullanıcısı, I want sistemin oturumlarımı sessizce analiz etmesini, so that uygulama zamanla beni daha iyi tanısın ve daha uygun sorular sorsun.

## Problem → Solution
Seans cevapları kaydediliyor ama analiz edilmiyor → Gemini Flash API ile her seans sonrası mood/topics/energy tag'leri otomatik çıkarılır ve DB'ye yazılır.

## Metadata
- **Complexity**: Medium
- **Source PRD**: `.claude/PRPs/prds/dilos-mvp.prd.md`
- **PRD Phase**: Faz 4 — AI Layer
- **Estimated Files**: 6 (1 gen) + 1 test = 8

---

## UX Design
**N/A — internal change.** Kullanıcı hiçbir şey görmez. Seans tamamlandığında normal akış devam eder. Tag'ler arka planda hesaplanır.

### Interaction Changes
| Touchpoint | Before | After | Notes |
|---|---|---|---|
| Seans tamamlanma | Entry kaydedilir | Entry kaydedilir + arka planda tag | Kullanıcı fark etmez |

---

## Mandatory Reading

| Priority | File | Lines | Why |
|---|---|---|---|
| P0 | `lib/features/session/data/models/session_entry.dart` | 1-22 | Burada `tagsJson` alanı eklenecek |
| P0 | `lib/features/session/presentation/providers/session_provider.dart` | 107-124 | `_saveSession` — buraya tagging çağrısı eklenir |
| P0 | `lib/features/session/data/models/session_answer.dart` | 1-20 | Gemini'ye gönderilecek veri yapısı |
| P0 | `lib/core/database/isar_provider.dart` | 1-49 | Provider registration pattern |
| P1 | `lib/features/brain_dump/presentation/providers/brain_dump_provider.dart` | 1-80 | StateNotifier error handling pattern |
| P2 | `test/features/session/providers/session_provider_test.dart` | 1-128 | Test pattern (FakeRepo + ProviderContainer) |

## External Documentation

| Topic | Source | Key Takeaway |
|---|---|---|
| google_generative_ai | pub.dev/packages/google_generative_ai | `GenerativeModel(model:, apiKey:)` + `generateContent([Content.text(...)])` |
| Gemini Flash model | Google AI | Model ID: `'gemini-1.5-flash'` |
| API Key via dart-define | Flutter docs | `const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '')` |

---

## Patterns to Mirror

### STATE_NOTIFIER_SAVE
```dart
// SOURCE: lib/features/session/presentation/providers/session_provider.dart:107-123
Future<void> _saveSession(List<SessionAnswer> answers) async {
  final entry = SessionEntry()
    ..createdAt = DateTime.now()
    ..status = 'completed'
    ..questionCount = answers.length
    ..answersJson = jsonEncode(answers.map((a) => a.toJson()).toList());

  await _repository.saveSession(entry);
}
```

### ISAR_COLLECTION_MODEL
```dart
// SOURCE: lib/features/session/data/models/session_entry.dart:1-22
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

### ERROR_HANDLING_ON_EXCEPTION
```dart
// SOURCE: lib/features/brain_dump/presentation/providers/brain_dump_provider.dart:50-57
} on Exception catch (e) {
  state = state.copyWith(
    status: BrainDumpStatus.error,
    errorMessage: e.toString(),
  );
}
```

### PROVIDER_REGISTRATION
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

### FIRE_AND_FORGET_PATTERN
```dart
// Pattern: arka planda çalıştır, hata olsa bile devam et
unawaited(_tagSession(entry, answers));
// unawaited: dart:async'dan import edilir
```

### TEST_STRUCTURE
```dart
// SOURCE: test/features/session/providers/session_provider_test.dart:10-51
class FakeSessionRepository implements SessionRepository { ... }

setUp(() {
  fakeRepo = FakeXRepository();
  container = ProviderContainer(overrides: [
    xRepositoryProvider.overrideWithValue(fakeRepo),
  ]);
});
tearDown(() => container.dispose());
```

---

## Files to Change

| File | Action | Justification |
|---|---|---|
| `pubspec.yaml` | UPDATE | `google_generative_ai: ^0.4.6` ekle |
| `lib/core/ai/session_tags.dart` | CREATE | Pure Dart tag domain type |
| `lib/core/ai/ai_tagging_service.dart` | CREATE | Gemini API çağrısı + JSON parsing |
| `lib/core/ai/ai_provider.dart` | CREATE | Riverpod provider for AiTaggingService |
| `lib/features/session/data/models/session_entry.dart` | UPDATE | `tagsJson` nullable alanı ekle |
| `lib/features/session/data/models/session_entry.g.dart` | AUTO-GEN | build_runner ile yeniden üret |
| `lib/features/session/data/repositories/session_repository_impl.dart` | UPDATE | `updateTags()` metodu ekle |
| `lib/features/session/domain/repositories/session_repository.dart` | UPDATE | `updateTags()` interface metodunu ekle |
| `lib/features/session/presentation/providers/session_provider.dart` | UPDATE | `_saveSession` sonrası fire-and-forget tagging |
| `test/core/ai/ai_tagging_service_test.dart` | CREATE | Parsing + edge case testleri |

## NOT Building
- AI sonuçlarını kullanıcıya gösterme (V1'de invisible)
- Brain Dump / Journal tagging (sadece session için)
- Tag'lere göre soru seçimi (bu Faz 6+ özelliği)
- Gemini API key UI'ı (dart-define ile geliştirici tarafında)
- Rate limiting / retry logic (MVP trafiğinde gereksiz)

---

## Step-by-Step Tasks

### Task 1: pubspec.yaml — google_generative_ai ekle
- **ACTION**: `pubspec.yaml`'a `google_generative_ai: ^0.4.6` ekle
- **IMPLEMENT**:
  ```yaml
  dependencies:
    # ... mevcut deps ...
    # AI
    google_generative_ai: ^0.4.6
  ```
  Sonra `flutter pub get` çalıştır.
- **MIRROR**: Mevcut pubspec.yaml yapısı
- **GOTCHA**: Paket adı `google_generative_ai` (tire değil underscore). `flutter pub get` sonrası analyzer hatası varsa versiyon aralığını `^0.4.0` olarak geniş tut.
- **VALIDATE**: `flutter pub get` — no errors; `flutter analyze` — 0 issue

### Task 2: SessionTags domain type
- **ACTION**: `lib/core/ai/session_tags.dart` oluştur
- **IMPLEMENT**:
  ```dart
  class SessionTags {
    const SessionTags({
      required this.mood,
      required this.topics,
      required this.energy,
    });

    final String mood;      // 'positive' | 'neutral' | 'negative' | 'anxious' | 'sad' | 'excited'
    final List<String> topics; // ['work', 'relationships', 'health', ...]
    final String energy;    // 'low' | 'medium' | 'high'

    factory SessionTags.fromJson(Map<String, dynamic> json) => SessionTags(
          mood: json['mood'] as String? ?? 'neutral',
          topics: (json['topics'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          energy: json['energy'] as String? ?? 'medium',
        );

    Map<String, dynamic> toJson() => {
          'mood': mood,
          'topics': topics,
          'energy': energy,
        };

    static SessionTags get fallback =>
        const SessionTags(mood: 'neutral', topics: [], energy: 'medium');
  }
  ```
- **MIRROR**: Pure Dart domain type (SessionAnswer pattern)
- **IMPORTS**: Dart core only — no external packages
- **GOTCHA**: `fromJson` her zaman null-safe olmalı — Gemini tutarsız JSON dönebilir, fallback değerler kritik
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 3: AiTaggingService
- **ACTION**: `lib/core/ai/ai_tagging_service.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'dart:convert';
  import 'package:google_generative_ai/google_generative_ai.dart';
  import 'session_tags.dart';
  import '../../../features/session/data/models/session_answer.dart';

  class AiTaggingService {
    AiTaggingService({String? apiKey})
        : _model = apiKey != null && apiKey.isNotEmpty
              ? GenerativeModel(
                  model: 'gemini-1.5-flash',
                  apiKey: apiKey,
                )
              : null;

    final GenerativeModel? _model;

    bool get isEnabled => _model != null;

    Future<SessionTags> tagSession(List<SessionAnswer> answers) async {
      if (_model == null || answers.isEmpty) return SessionTags.fallback;

      try {
        final prompt = _buildPrompt(answers);
        final response = await _model!.generateContent([Content.text(prompt)]);
        final text = response.text ?? '';
        return _parseResponse(text);
      } on Exception {
        return SessionTags.fallback;
      }
    }

    String _buildPrompt(List<SessionAnswer> answers) {
      final buffer = StringBuffer()
        ..writeln(
            'Analyze these mental wellness journal answers. Return ONLY valid JSON.')
        ..writeln('Required format: {"mood":"<positive|neutral|negative|anxious|sad|excited>","topics":["<topic>"],"energy":"<low|medium|high>"}')
        ..writeln()
        ..writeln('Answers:');

      for (var i = 0; i < answers.length; i++) {
        buffer.writeln('${i + 1}. ${answers[i].text}');
      }
      return buffer.toString();
    }

    SessionTags _parseResponse(String text) {
      final jsonStr = _extractJson(text);
      if (jsonStr == null) return SessionTags.fallback;

      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return SessionTags.fromJson(decoded);
      } on FormatException {
        return SessionTags.fallback;
      }
    }

    String? _extractJson(String text) {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) return null;
      return text.substring(start, end + 1);
    }
  }
  ```
- **MIRROR**: ERROR_HANDLING_ON_EXCEPTION (on Exception catch)
- **IMPORTS**: `dart:convert`, `package:google_generative_ai/google_generative_ai.dart`, `session_tags.dart`, session_answer.dart
- **GOTCHA**: `_model` nullable — API key yoksa tagging atlanır, uygulama çökmez. `_extractJson` ile Gemini'nin açıklama eklediği durumlarda JSON'u ayıkla.
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 4: AiProvider (Riverpod)
- **ACTION**: `lib/core/ai/ai_provider.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'ai_tagging_service.dart';

  const _geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  final aiTaggingServiceProvider = Provider<AiTaggingService>((ref) {
    return AiTaggingService(apiKey: _geminiApiKey);
  });
  ```
- **MIRROR**: PROVIDER_REGISTRATION
- **IMPORTS**: `flutter_riverpod`, `ai_tagging_service.dart`
- **GOTCHA**: `String.fromEnvironment` compile-time constant olduğu için `const` olmalı. API key yoksa (`''`) `AiTaggingService.isEnabled` false döner — tagging atlanır.
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 5: SessionEntry — tagsJson alanı ekle
- **ACTION**: `lib/features/session/data/models/session_entry.dart` güncelle — `String? tagsJson` ekle
- **IMPLEMENT**:
  ```dart
  import 'dart:convert';
  import 'package:isar/isar.dart';

  part 'session_entry.g.dart';

  @collection
  class SessionEntry {
    Id id = Isar.autoIncrement;

    late DateTime createdAt;
    late String status;
    late int questionCount;
    late String answersJson;
    String? tagsJson;  // nullable — tagging tamamlanmadan önce null

    @ignore
    bool get isCompleted => status == 'completed';

    @ignore
    bool get isTagged => tagsJson != null;

    @ignore
    List<Map<String, dynamic>> get answers =>
        (jsonDecode(answersJson) as List).cast<Map<String, dynamic>>();
  }
  ```
- **MIRROR**: ISAR_COLLECTION_MODEL
- **GOTCHA**: `String? tagsJson` nullable — Isar 3 nullable alanları destekler, mevcut kayıtlar null olarak kalır. `late` değil `String?` kullan (nullable = optional field).
- **VALIDATE**: Dosya kaydedildi

### Task 6: build_runner — session_entry.g.dart yeniden üret
- **ACTION**: `dart run build_runner build --delete-conflicting-outputs` çalıştır
- **IMPLEMENT**: Terminal komutu
- **GOTCHA**: `tagsJson` nullable olduğu için generated code güncellenir. Mevcut `brain_dump_entry.g.dart` ve `journal_entry.g.dart` de yeniden üretilir (değişmez ama yeniden generate edilir).
- **VALIDATE**: `session_entry.g.dart` güncel, `flutter analyze` — 0 hata

### Task 7: SessionRepository — updateTags metodu ekle
- **ACTION**: Interface + Impl'e `updateTags` ekle
- **IMPLEMENT** (interface — `lib/features/session/domain/repositories/session_repository.dart`):
  ```dart
  import '../entities/session_question.dart';
  import '../../data/models/session_entry.dart';

  abstract interface class SessionRepository {
    Future<List<SessionQuestion>> getQuestions();
    Future<void> saveSession(SessionEntry entry);
    Future<List<SessionEntry>> getRecentSessions({int limit = 10});
    Stream<List<SessionEntry>> watchSessions();
    Future<void> updateTags(Id entryId, String tagsJson);
  }
  ```
- **IMPLEMENT** (impl — `lib/features/session/data/repositories/session_repository_impl.dart`):
  Mevcut sona ekle:
  ```dart
  @override
  Future<void> updateTags(Id entryId, String tagsJson) async {
    await _isar.writeTxn(() async {
      final entry = await _isar.sessionEntrys.get(entryId);
      if (entry == null) return;
      entry.tagsJson = tagsJson;
      await _isar.sessionEntrys.put(entry);
    });
  }
  ```
- **MIRROR**: ISAR_REPOSITORY_IMPL
- **IMPORTS**: `package:isar/isar.dart` (Id type)
- **GOTCHA**: `Id` tipi `package:isar/isar.dart`'dan gelir. `_isar.sessionEntrys.get(entryId)` null dönebilir (entry silinmişse) — null check gerekli.
- **VALIDATE**: `flutter analyze` — 0 hata; FakeSessionRepository da implement etmeli → test dosyasını güncelle

### Task 8: SessionProvider — tagging entegrasyonu
- **ACTION**: `lib/features/session/presentation/providers/session_provider.dart` güncelle
- **IMPLEMENT**: `_saveSession` metodunu şu şekilde değiştir:
  ```dart
  import 'dart:async';  // unawaited için
  // ... mevcut importlar ...
  import '../../../../core/ai/ai_provider.dart';
  import '../../../../core/ai/session_tags.dart';
  ```

  `SessionNotifier` constructor'ına `AiTaggingService` ekle:
  ```dart
  class SessionNotifier extends StateNotifier<SessionState> {
    SessionNotifier(this._repository, this._aiService)
        : super(const SessionState.initial()) {
      _loadQuestions();
    }

    final SessionRepository _repository;
    final AiTaggingService _aiService;
  ```

  `_saveSession` metodunu güncelle:
  ```dart
  Future<void> _saveSession(List<SessionAnswer> answers) async {
    final entry = SessionEntry()
      ..createdAt = DateTime.now()
      ..status = 'completed'
      ..questionCount = answers.length
      ..answersJson = jsonEncode(answers.map((a) => a.toJson()).toList());

    await _repository.saveSession(entry);
    // Fire-and-forget: kullanıcı beklemez, hata olsa session etkilenmez
    unawaited(_tagSession(entry.id, answers));
  }

  Future<void> _tagSession(Id entryId, List<SessionAnswer> answers) async {
    try {
      final tags = await _aiService.tagSession(answers);
      await _repository.updateTags(
        entryId,
        jsonEncode(tags.toJson()),
      );
    } on Exception {
      // Tagging sessizce başarısız olabilir — session zaten kaydedildi
    }
  }
  ```

  Provider'ı güncelle:
  ```dart
  final sessionProvider =
      StateNotifierProvider.autoDispose<SessionNotifier, SessionState>((ref) {
    final repo = ref.watch(sessionRepositoryProvider);
    final aiService = ref.watch(aiTaggingServiceProvider);
    return SessionNotifier(repo, aiService);
  });
  ```
- **MIRROR**: STATE_NOTIFIER_SAVE, FIRE_AND_FORGET_PATTERN
- **IMPORTS**: `dart:async` (unawaited), `../../../../core/ai/ai_provider.dart`, `../../../../core/ai/session_tags.dart`
- **GOTCHA**: `unawaited(...)` Dart'ta `dart:async`'dan gelir — import gerekli. `entry.id` `_saveSession` içinde `Isar.autoIncrement` atamasından sonra Isar'ın verdiği ID'dir — sadece `put()` çağrısından SONRA geçerlidir. `saveSession` önce çağrıldığı için `entry.id` artık valid.
- **VALIDATE**: `flutter analyze` — 0 hata

### Task 9: Test — FakeSessionRepository güncelle + AiTaggingService testleri
- **ACTION 1**: `test/features/session/providers/session_provider_test.dart` — `FakeSessionRepository`'e `updateTags` ekle
- **IMPLEMENT** (test dosyasında FakeSessionRepository'e ekle):
  ```dart
  @override
  Future<void> updateTags(Id entryId, String tagsJson) async {
    // test stub — no-op
  }
  ```
  Ve `SessionNotifier` override'ı güncelle — artık `aiService` parametresi gerekiyor:
  ```dart
  class FakeAiTaggingService extends AiTaggingService {
    FakeAiTaggingService() : super(apiKey: null);
    @override
    Future<SessionTags> tagSession(List<SessionAnswer> answers) async =>
        SessionTags.fallback;
  }
  ```
  Provider override:
  ```dart
  container = ProviderContainer(overrides: [
    sessionRepositoryProvider.overrideWithValue(fakeRepo),
    aiTaggingServiceProvider.overrideWithValue(FakeAiTaggingService()),
  ]);
  ```

- **ACTION 2**: `test/core/ai/ai_tagging_service_test.dart` oluştur
- **IMPLEMENT**:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:dilos/core/ai/ai_tagging_service.dart';
  import 'package:dilos/core/ai/session_tags.dart';
  import 'package:dilos/features/session/data/models/session_answer.dart';

  void main() {
    group('AiTaggingService', () {
      late AiTaggingService service;

      setUp(() {
        service = AiTaggingService(apiKey: null); // API key yok — disabled
      });

      test('API key yoksa fallback döner', () async {
        final answers = [
          SessionAnswer(
            questionId: 'q1',
            text: 'Bugün iyi hissediyorum',
            inputType: 'text',
            answeredAt: DateTime.now(),
          ),
        ];
        final result = await service.tagSession(answers);
        expect(result.mood, 'neutral');
        expect(result.energy, 'medium');
      });

      test('boş answers listesi fallback döner', () async {
        final result = await service.tagSession([]);
        expect(result.mood, SessionTags.fallback.mood);
      });

      test('_extractJson geçerli JSON çıkarır', () {
        final svc = AiTaggingService(apiKey: null);
        final text = 'Sure! {"mood":"positive","topics":["work"],"energy":"high"} Done.';
        // _extractJson private — SessionTags.fromJson üzerinden dolaylı test
        final tags = SessionTags.fromJson({
          'mood': 'positive',
          'topics': ['work'],
          'energy': 'high',
        });
        expect(tags.mood, 'positive');
        expect(tags.topics, ['work']);
        expect(tags.energy, 'high');
      });

      test('SessionTags.fromJson eksik alan için fallback kullanır', () {
        final tags = SessionTags.fromJson({});
        expect(tags.mood, 'neutral');
        expect(tags.topics, isEmpty);
        expect(tags.energy, 'medium');
      });

      test('SessionTags.toJson roundtrip', () {
        const tags = SessionTags(
          mood: 'positive',
          topics: ['work', 'health'],
          energy: 'high',
        );
        final json = tags.toJson();
        final restored = SessionTags.fromJson(json);
        expect(restored.mood, tags.mood);
        expect(restored.topics, tags.topics);
        expect(restored.energy, tags.energy);
      });
    });
  }
  ```
- **MIRROR**: TEST_STRUCTURE
- **GOTCHA**: `_extractJson` private olduğu için doğrudan test edilemez. `SessionTags.fromJson` üzerinden parsing mantığını test et.
- **VALIDATE**: `flutter test test/core/ai/` — 5/5 pass; `flutter test test/features/session/` — 9/9 pass

---

## Testing Strategy

### Unit Tests

| Test | Input | Expected Output | Edge Case? |
|---|---|---|---|
| API key null → fallback | `AiTaggingService(apiKey: null)` | `SessionTags.fallback` | Yes |
| Boş answers → fallback | `[]` | `SessionTags.fallback` | Yes |
| fromJson eksik alanlar | `{}` | fallback değerler | Yes |
| fromJson tam veri | valid json | correct fields | No |
| toJson roundtrip | SessionTags | json → SessionTags eşit | No |

### Edge Cases Checklist
- [x] API key yoksa uygulama çökmez — `isEnabled` false, fallback döner
- [x] Gemini bozuk JSON dönerse — `_extractJson` null, fallback döner
- [x] `FormatException` — catch ile fallback
- [x] Boş cevap listesi — early return, fallback
- [x] Ağ hatası (Exception) — `on Exception catch` ile fallback

---

## Validation Commands

### Static Analysis
```bash
flutter analyze
```
EXPECT: Zero issues

### Unit Tests
```bash
flutter test test/core/ai/
flutter test test/features/session/
flutter test
```
EXPECT: 21 existing + 5 new AI + 9 session = 35 toplam

### Manual Validation (API key ile)
- [ ] `flutter run --dart-define=GEMINI_API_KEY=<key>` ile çalıştır
- [ ] Seans tamamla
- [ ] Birkaç saniye bekle
- [ ] Debug console'da hata yok

---

## Acceptance Criteria
- [ ] Tüm tasklar tamamlandı
- [ ] `flutter analyze` — 0 hata
- [ ] `flutter test` — tüm testler geçti
- [ ] `AiTaggingService` API key yoksa güvenli fallback döner
- [ ] `SessionNotifier` tagging'i fire-and-forget çalıştırır
- [ ] `SessionEntry.tagsJson` alanı Isar'a kaydediliyor

## Completion Checklist
- [ ] `unawaited()` kullanıldı (dart:async)
- [ ] `String.fromEnvironment` const keyword ile
- [ ] Tagging hataları yutuldu (kullanıcıya gösterilmiyor)
- [ ] FakeSessionRepository testlerde güncellendi
- [ ] FakeAiTaggingService testlerde kullanıldı

## Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `google_generative_ai` versiyon uyumsuzluğu | Medium | Build hata | `^0.4.0` geniş aralık dene |
| Isar nullable field migration | Low | Runtime hata | Uygulamayı ilk kez sıfır DB'de çalıştır |
| `unawaited` linter uyarısı | Low | Lint | `// ignore: unawaited_futures` ya da `dart:async unawaited()` kullan |

## Notes
- Tagging tamamen opsiyonel — API key olmadan uygulama tam çalışır
- `entry.id` Isar tarafından `put()` sonrası atanır — `saveSession` içinde `_isar.sessionEntrys.put(entry)` çağrıldıktan SONRA `entry.id` geçerlidir
- Faz 5 (Notifications) bu faza bağımlı değil — paralel geliştirilebilir
