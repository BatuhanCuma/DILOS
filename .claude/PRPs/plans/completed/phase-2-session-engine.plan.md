# Plan: Phase 2 — Session Engine

## Summary
DILOS'un kalbini oluşturan Auto Session sistemi: kullanıcı uygulamayı açınca sistem otomatik 2-5 dakikalık bir seans başlatır, soru havuzundan sorular sunar, ses veya yazıyla cevap alır ve seansı Isar'a kaydeder. Bu faz olmadan uygulama hiçbir değer üretmez.

## User Story
As a kullanıcı experiencing burnout,
I want the app to automatically start a guided session when I open it,
So that I don't need to decide what to do — I just follow the flow.

## Problem → Solution
Home ekranında çalışmayan "Seans Başlat" butonu → Tam çalışan Auto Session: soru akışı, ses/yazı input, Isar'a kayıt.

## Metadata
- **Complexity**: Large
- **Source PRD**: `.claude/PRPs/prds/dilos-mvp.prd.md`
- **PRD Phase**: Faz 2 — Session Engine
- **Estimated Files**: 20–25

---

## UX Design

### Before
```
┌─────────────────────────────┐
│  DILOS                      │
│  Hayatın zaten güzel.       │
│                             │
│  [Seans Başlat] (çalışmıyor)│
└─────────────────────────────┘
```

### After
```
┌─────────────────────────────┐       ┌─────────────────────────────┐
│  DILOS                      │  tap  │  Bugün kafanda ne var?       │
│  Hayatın zaten güzel.       │ ────► │                             │
│                             │       │  [🎤 Konuş]  [✏️ Yaz]       │
│  [Seans Başlat] ✓           │       │                             │
└─────────────────────────────┘       │  ──────────────────── 1/4   │
                                      └─────────────────────────────┘
                                                    │ cevap
                                                    ▼
                                      ┌─────────────────────────────┐
                                      │  Bugünden minik bir şey...  │
                                      │                             │
                                      │  [🎤]  [✏️]                 │
                                      │  ──────────────────── 2/4   │
                                      └─────────────────────────────┘
                                                    │
                                                    ▼
                                      ┌─────────────────────────────┐
                                      │  ✓ Seans tamamlandı         │
                                      │  Bugün 4 soruyu cevapladın  │
                                      │                             │
                                      │  [Ana Sayfaya Dön]          │
                                      └─────────────────────────────┘
```

### Interaction Changes
| Touchpoint | Before | After | Notlar |
|---|---|---|---|
| "Seans Başlat" butonu | Dokunulunca hiçbir şey | `/session` route'una gider | go_router ile |
| Session ekranı | Yok | Soru + input + ilerleme | 4 soru, adım adım |
| Ses girişi | Yok | Mikrofon butonu, canlı transkript | `speech_to_text 7.3.0` |
| Yazı girişi | Yok | TextField fallback | Her zaman açık |
| Seans sonu | Yok | Tamamlama ekranı + Isar'a kayıt | `SessionEntry` |

---

## Mandatory Reading

| Öncelik | Dosya | Neden |
|---|---|---|
| P0 | `lib/features/home/presentation/screens/home_screen.dart` | Butonu bağlayacağız |
| P0 | `lib/core/router/app_router.dart` | Session route eklenecek |
| P0 | `lib/core/router/app_routes.dart` | Route sabitleri |
| P0 | `lib/core/database/isar_provider.dart` | DB provider güncellenecek |
| P1 | `lib/core/theme/app_colors.dart` | Renk referansı |
| P1 | `lib/core/theme/app_spacing.dart` | Spacing referansı |

## External Documentation

| Konu | Kaynak | Önemli Not |
|---|---|---|
| speech_to_text 7.x | pub.dev/packages/speech_to_text | `SpeechToText().initialize()` async, `statusListener` ile durum takibi |
| Isar Collections | isar.dev/docs/schema | `@collection`, `Id id = Isar.autoIncrement`, `@ignore` computed fields |
| Riverpod StateNotifier | riverpod.dev | `StateNotifierProvider` için `StateNotifier<State>` extend et |

---

## Patterns to Mirror

### NAMING_CONVENTION
```dart
// SOURCE: lib/features/home/presentation/screens/home_screen.dart:1-6
// Dosyalar: snake_case, Sınıflar: PascalCase, ConsumerWidget extend
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
```

### FEATURE_FOLDER_STRUCTURE
```
lib/features/session/
  ├── data/
  │   ├── models/session_entry.dart        # Isar @collection
  │   └── repositories/session_repository_impl.dart
  ├── domain/
  │   ├── entities/session_question.dart   # Pure Dart
  │   └── repositories/session_repository.dart  # abstract interface
  └── presentation/
      ├── screens/session_screen.dart
      ├── screens/session_complete_screen.dart
      ├── widgets/question_card.dart
      ├── widgets/voice_input_button.dart
      ├── widgets/text_input_field.dart
      └── providers/session_provider.dart
```

### ISAR_COLLECTION
```dart
// SOURCE: lib/core/database/isar_provider.dart (pattern tanımı)
// Isar collection annotation — tüm modeller bu yapıyı takip eder
import 'package:isar/isar.dart';
part 'session_entry.g.dart'; // build_runner üretir

@collection
class SessionEntry {
  Id id = Isar.autoIncrement;
  late DateTime createdAt;
  late String type;
  late String status;

  @ignore
  bool get isCompleted => status == 'completed';
}
```

### REPOSITORY_PATTERN
```dart
// domain/repositories/session_repository.dart
abstract interface class SessionRepository {
  Future<void> saveSession(SessionEntry entry);
  Future<List<SessionEntry>> getAllSessions();
  Stream<List<SessionEntry>> watchSessions();
}

// data/repositories/session_repository_impl.dart
class IsarSessionRepository implements SessionRepository {
  const IsarSessionRepository(this._isar);
  final Isar _isar;

  @override
  Future<void> saveSession(SessionEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.sessionEntrys.put(entry);
    });
  }
}
```

### STATE_NOTIFIER_PATTERN
```dart
// presentation/providers/session_provider.dart
// StateNotifier ile session state yönetimi
class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._repository) : super(const SessionState.initial());

  final SessionRepository _repository;

  void nextQuestion() {
    // immutable state update — yeni nesne döndür
    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return SessionNotifier(repo);
});
```

### ERROR_HANDLING
```dart
// Result sealed class — Faz 1 plan'dan
sealed class Result<T> { const Result(); }
class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}
class Failure<T> extends Result<T> {
  const Failure(this.message);
  final String message;
}
```

### WIDGET_STYLE
```dart
// SOURCE: lib/features/home/presentation/screens/home_screen.dart:27-44
// Container ile buton stili — tüm butonlar bu pattern'ı takip eder
Container(
  width: double.infinity,
  height: 56,
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(16),
  ),
  alignment: Alignment.center,
  child: Text('Label', style: theme.textTheme.labelLarge),
)
```

### TEST_STRUCTURE
```dart
// test/ altında, feature klasörü mirror'ı
// test/features/session/providers/session_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('SessionNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        sessionRepositoryProvider.overrideWithValue(FakeSessionRepository()),
      ]);
    });

    tearDown(() => container.dispose());

    test('başlangıçta ilk soruyu gösterir', () {
      final state = container.read(sessionProvider);
      expect(state.currentIndex, 0);
    });
  });
}
```

---

## Files to Change

| Dosya | İşlem | Gerekçe |
|---|---|---|
| `pubspec.yaml` | UPDATE | `speech_to_text: ^7.3.0` ekle |
| `lib/core/database/isar_provider.dart` | UPDATE | `SessionEntrySchema` ekle |
| `lib/core/router/app_router.dart` | UPDATE | `/session` route ekle |
| `lib/features/home/presentation/screens/home_screen.dart` | UPDATE | Butonu bağla |
| `lib/features/session/data/models/session_entry.dart` | CREATE | Isar collection |
| `lib/features/session/data/models/session_entry.g.dart` | AUTO-GEN | `build_runner` üretir |
| `lib/features/session/data/models/session_answer.dart` | CREATE | Cevap value object |
| `lib/features/session/domain/entities/session_question.dart` | CREATE | Soru entity |
| `lib/features/session/domain/repositories/session_repository.dart` | CREATE | Abstract interface |
| `lib/features/session/data/repositories/session_repository_impl.dart` | CREATE | Isar impl |
| `lib/features/session/presentation/providers/session_provider.dart` | CREATE | State + notifier |
| `lib/features/session/presentation/screens/session_screen.dart` | CREATE | Ana seans ekranı |
| `lib/features/session/presentation/screens/session_complete_screen.dart` | CREATE | Tamamlama ekranı |
| `lib/features/session/presentation/widgets/question_card.dart` | CREATE | Soru widget |
| `lib/features/session/presentation/widgets/voice_input_button.dart` | CREATE | Mikrofon butonu |
| `lib/features/session/presentation/widgets/text_input_field.dart` | CREATE | Yazı input |
| `assets/data/session_questions.json` | CREATE | Soru havuzu |
| `test/features/session/providers/session_provider_test.dart` | CREATE | State testleri |

## NOT Building
- AI tagging — Faz 4
- Bildirimler — Faz 5
- Journal / Brain Dump ekranları — Faz 3
- Sesli playback (TTS) — scope dışı
- Seans geçmişi listesi — Faz 6

---

## Step-by-Step Tasks

### Task 1: speech_to_text ekle + pubspec güncelle
- **ACTION**: `speech_to_text 7.3.0` pubspec'e ekle
- **IMPLEMENT**:
```yaml
# pubspec.yaml dependencies bölümüne ekle:
speech_to_text: ^7.3.0
```
- **GOTCHA**: Android için `AndroidManifest.xml`'e mikrofon izni eklenmeli:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```
iOS için `Info.plist`:
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Sesli notlarını almak için mikrofon erişimi gerekiyor.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Sesli notlarını almak için mikrofon erişimi gerekiyor.</string>
```
- **VALIDATE**: `flutter pub get` hatasız

### Task 2: Soru havuzu JSON
- **ACTION**: `assets/data/session_questions.json` oluştur, pubspec'e asset ekle
- **IMPLEMENT**:
```json
{
  "questions": [
    {
      "id": "mood_check",
      "text": "Bugün kafanda ne var?",
      "type": "open",
      "category": "mood"
    },
    {
      "id": "daily_share",
      "text": "Bugünden minik bir şey paylaş — iyi ya da kötü.",
      "type": "open",
      "category": "reflection"
    },
    {
      "id": "positive_moment",
      "text": "Bugün sana iyi gelen bir şey oldu mu?",
      "type": "open",
      "category": "gratitude"
    },
    {
      "id": "recent_thought",
      "text": "Son zamanlarda seni etkileyen bir fikir var mı?",
      "type": "open",
      "category": "thought"
    },
    {
      "id": "energy_level",
      "text": "Şu an enerjin nasıl hissettiriyor sana?",
      "type": "open",
      "category": "mood"
    },
    {
      "id": "one_thing",
      "text": "Bugün bir şeyi değiştirebilseydin ne olurdu?",
      "type": "open",
      "category": "reflection"
    }
  ]
}
```
`pubspec.yaml` flutter bölümüne:
```yaml
flutter:
  assets:
    - assets/data/session_questions.json
```
- **VALIDATE**: `flutter pub get` başarılı, asset yüklenebiliyor

### Task 3: Domain entities
- **ACTION**: `SessionQuestion` ve `SessionAnswer` value object'lerini oluştur

`lib/features/session/domain/entities/session_question.dart`:
```dart
class SessionQuestion {
  const SessionQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.category,
  });

  final String id;
  final String text;
  final String type;
  final String category;

  factory SessionQuestion.fromJson(Map<String, dynamic> json) =>
      SessionQuestion(
        id: json['id'] as String,
        text: json['text'] as String,
        type: json['type'] as String,
        category: json['category'] as String,
      );
}
```

`lib/features/session/data/models/session_answer.dart`:
```dart
class SessionAnswer {
  const SessionAnswer({
    required this.questionId,
    required this.text,
    required this.inputType,
    required this.answeredAt,
  });

  final String questionId;
  final String text;
  final String inputType; // 'voice' | 'text'
  final DateTime answeredAt;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'text': text,
        'inputType': inputType,
        'answeredAt': answeredAt.toIso8601String(),
      };
}
```
- **MIRROR**: NAMING_CONVENTION
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 4: Isar SessionEntry modeli
- **ACTION**: `@collection` ile Isar modeli oluştur, `build_runner` çalıştır

`lib/features/session/data/models/session_entry.dart`:
```dart
import 'dart:convert';
import 'package:isar/isar.dart';

part 'session_entry.g.dart';

@collection
class SessionEntry {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;
  late String status; // 'pending' | 'completed' | 'abandoned'
  late int questionCount;
  late String answersJson; // JSON encoded List<SessionAnswer>

  @ignore
  bool get isCompleted => status == 'completed';

  @ignore
  List<Map<String, dynamic>> get answers =>
      (jsonDecode(answersJson) as List)
          .cast<Map<String, dynamic>>();
}
```

Sonra:
```bash
dart run build_runner build --delete-conflicting-outputs
```
- **GOTCHA**: `session_entry.g.dart` otomatik üretilir, elle düzenleme
- **VALIDATE**: `session_entry.g.dart` oluştu, `flutter analyze` geçiyor

### Task 5: Repository katmanı
- **ACTION**: Abstract interface + Isar implementasyonu

`lib/features/session/domain/repositories/session_repository.dart`:
```dart
import '../entities/session_question.dart';
import '../../data/models/session_entry.dart';

abstract interface class SessionRepository {
  Future<List<SessionQuestion>> getQuestions();
  Future<void> saveSession(SessionEntry entry);
  Future<List<SessionEntry>> getRecentSessions({int limit = 10});
  Stream<List<SessionEntry>> watchSessions();
}
```

`lib/features/session/data/repositories/session_repository_impl.dart`:
```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/session_question.dart';
import '../../domain/repositories/session_repository.dart';
import '../models/session_entry.dart';

class IsarSessionRepository implements SessionRepository {
  const IsarSessionRepository(this._isar);
  final Isar _isar;

  @override
  Future<List<SessionQuestion>> getQuestions() async {
    final String raw = await rootBundle.loadString(
      'assets/data/session_questions.json',
    );
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = (data['questions'] as List).cast<Map<String, dynamic>>();
    return list.map(SessionQuestion.fromJson).toList();
  }

  @override
  Future<void> saveSession(SessionEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.sessionEntrys.put(entry);
    });
  }

  @override
  Future<List<SessionEntry>> getRecentSessions({int limit = 10}) async {
    return _isar.sessionEntrys
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  @override
  Stream<List<SessionEntry>> watchSessions() {
    return _isar.sessionEntrys.where().watch(fireImmediately: true);
  }
}
```
- **MIRROR**: REPOSITORY_PATTERN
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 6: Isar provider güncellemesi
- **ACTION**: `SessionEntrySchema`'yı `isarProvider`'a ekle

`lib/core/database/isar_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../features/session/data/models/session_entry.dart';
import '../../features/session/data/repositories/session_repository_impl.dart';
import '../../features/session/domain/repositories/session_repository.dart';
import 'isar_service.dart';

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
- **GOTCHA**: `isarProvider` FutureProvider — provider kullanmadan önce `.when()` ile guard et
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 7: Session state — SessionState + SessionNotifier
- **ACTION**: Seans akışı için immutable state + notifier

`lib/features/session/presentation/providers/session_provider.dart`:
```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_answer.dart';
import '../../data/models/session_entry.dart';
import '../../domain/entities/session_question.dart';
import '../../domain/repositories/session_repository.dart';
import '../../../../core/database/isar_provider.dart';

// --- State ---
enum SessionStatus { loading, active, completed, error }

class SessionState {
  const SessionState({
    required this.status,
    required this.questions,
    required this.answers,
    required this.currentIndex,
    this.errorMessage,
  });

  const SessionState.initial()
      : status = SessionStatus.loading,
        questions = const [],
        answers = const [],
        currentIndex = 0,
        errorMessage = null;

  final SessionStatus status;
  final List<SessionQuestion> questions;
  final List<SessionAnswer> answers;
  final int currentIndex;
  final String? errorMessage;

  bool get isLastQuestion =>
      questions.isNotEmpty && currentIndex >= questions.length - 1;

  SessionQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  SessionState copyWith({
    SessionStatus? status,
    List<SessionQuestion>? questions,
    List<SessionAnswer>? answers,
    int? currentIndex,
    String? errorMessage,
  }) =>
      SessionState(
        status: status ?? this.status,
        questions: questions ?? this.questions,
        answers: answers ?? this.answers,
        currentIndex: currentIndex ?? this.currentIndex,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// --- Notifier ---
class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._repository) : super(const SessionState.initial()) {
    _loadQuestions();
  }

  final SessionRepository _repository;

  Future<void> _loadQuestions() async {
    try {
      final questions = await _repository.getQuestions();
      // Her seansta 4 rastgele soru seç
      questions.shuffle();
      state = state.copyWith(
        status: SessionStatus.active,
        questions: questions.take(4).toList(),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> submitAnswer(String answerText, String inputType) async {
    if (state.currentQuestion == null) return;

    final answer = SessionAnswer(
      questionId: state.currentQuestion!.id,
      text: answerText,
      inputType: inputType,
      answeredAt: DateTime.now(),
    );

    final updatedAnswers = [...state.answers, answer];

    if (state.isLastQuestion) {
      // Seansı tamamla ve kaydet
      await _saveSession(updatedAnswers);
      state = state.copyWith(
        status: SessionStatus.completed,
        answers: updatedAnswers,
      );
    } else {
      state = state.copyWith(
        answers: updatedAnswers,
        currentIndex: state.currentIndex + 1,
      );
    }
  }

  Future<void> _saveSession(List<SessionAnswer> answers) async {
    final entry = SessionEntry()
      ..createdAt = DateTime.now()
      ..status = 'completed'
      ..questionCount = answers.length
      ..answersJson = jsonEncode(answers.map((a) => a.toJson()).toList());

    await _repository.saveSession(entry);
  }

  void skipQuestion() {
    if (state.isLastQuestion) {
      state = state.copyWith(status: SessionStatus.completed);
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }
}

// --- Provider ---
final sessionProvider =
    StateNotifierProvider.autoDispose<SessionNotifier, SessionState>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return SessionNotifier(repo);
});
```
- **MIRROR**: STATE_NOTIFIER_PATTERN
- **GOTCHA**: `autoDispose` — seans bitince provider temizlenir, state sıfırlanır
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 8: VoiceInputButton widget
- **ACTION**: Mikrofon butonu — speech_to_text entegrasyonu

`lib/features/session/presentation/widgets/voice_input_button.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/theme/app_colors.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onResult,
  });

  final void Function(String text) onResult;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _liveText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
          if (_liveText.isNotEmpty) widget.onResult(_liveText);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() => _isAvailable = available);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _liveText = '';
      });
      await _speech.listen(
        onResult: (result) {
          setState(() => _liveText = result.recognizedWords);
        },
        localeId: 'tr_TR',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _isListening ? AppColors.accent : AppColors.primaryDim,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
```
- **GOTCHA**: `localeId: 'tr_TR'` — Türkçe ses tanıma, cihazda TR dil paketi olmalı; yoksa fallback otomatik
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 9: TextInputField widget
- **ACTION**: Yazı input fallback

`lib/features/session/presentation/widgets/text_input_field.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class TextInputField extends StatefulWidget {
  const TextInputField({
    super.key,
    required this.onSubmit,
    this.hint = 'Düşüncelerini yaz...',
  });

  final void Function(String text) onSubmit;
  final String hint;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            style: const TextStyle(color: AppColors.onSurface),
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AppColors.onSurfaceDim),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: _submit,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
```
- **MIRROR**: WIDGET_STYLE
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 10: QuestionCard widget
- **ACTION**: Soru gösterme kartı

`lib/features/session/presentation/widgets/question_card.dart`:
```dart
import 'package:flutter/material.dart';
import '../../domain/entities/session_question.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.progress,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final SessionQuestion question;
  final double progress;
  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İlerleme göstergesi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$questionNumber / $totalQuestions',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Soru metni
        Text(
          question.text,
          style: theme.textTheme.headlineMedium,
        ),
      ],
    );
  }
}
```
- **MIRROR**: WIDGET_STYLE, NAMING_CONVENTION
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 11: SessionScreen
- **ACTION**: Ana seans ekranı — tüm parçaları bir araya getirir

`lib/features/session/presentation/screens/session_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/text_input_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_routes.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);

    // Seans tamamlandıysa tamamlama ekranına geç
    ref.listen(sessionProvider, (_, next) {
      if (next.status == SessionStatus.completed) {
        context.go(AppRoutes.sessionComplete);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: switch (state.status) {
          SessionStatus.loading => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          SessionStatus.error => Center(
              child: Text(
                state.errorMessage ?? 'Bir hata oluştu',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          SessionStatus.completed => const SizedBox.shrink(),
          SessionStatus.active => _ActiveSession(
              state: state,
              onAnswer: (text, type) => notifier.submitAnswer(text, type),
              onSkip: notifier.skipQuestion,
            ),
        },
      ),
    );
  }
}

class _ActiveSession extends StatelessWidget {
  const _ActiveSession({
    required this.state,
    required this.onAnswer,
    required this.onSkip,
  });

  final SessionState state;
  final void Function(String text, String type) onAnswer;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionCard(
            question: question,
            progress: state.progress,
            questionNumber: state.currentIndex + 1,
            totalQuestions: state.questions.length,
          ),
          const Spacer(),
          // Ses input
          Center(
            child: VoiceInputButton(
              onResult: (text) => onAnswer(text, 'voice'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Yazı input
          TextInputField(
            onSubmit: (text) => onAnswer(text, 'text'),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Geç butonu
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Bu soruyu geç',
                style: TextStyle(color: AppColors.onSurfaceDim),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
```
- **MIRROR**: NAMING_CONVENTION, WIDGET_STYLE
- **GOTCHA**: `ref.listen` `build` içinde çağrılmalı, `initState`'te değil
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 12: SessionCompleteScreen
- **ACTION**: Seans tamamlama ekranı

`lib/features/session/presentation/screens/session_complete_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_routes.dart';

class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.accent,
                size: 64,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Seans tamamlandı', style: theme.textTheme.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kendine zaman ayırdın. Bu küçük ama önemli.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Ana Sayfaya Dön',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
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
- **MIRROR**: WIDGET_STYLE
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 13: Router güncellemesi
- **ACTION**: `/session` ve `/session/complete` route'larını ekle

`lib/core/router/app_routes.dart`:
```dart
class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const session = '/session';
  static const sessionComplete = '/session/complete';
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
import '../../features/session/presentation/screens/session_screen.dart';
import '../../features/session/presentation/screens/session_complete_screen.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionComplete,
        builder: (context, state) => const SessionCompleteScreen(),
      ),
    ],
  );
});
```
- **MIRROR**: NAMING_CONVENTION
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 14: HomeScreen güncelleme
- **ACTION**: "Seans Başlat" butonunu router'a bağla

`lib/features/home/presentation/screens/home_screen.dart` — sadece `onTap` güncellenir:
```dart
// GestureDetector onTap:
onTap: () => context.go(AppRoutes.session),
```
Import ekle:
```dart
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
```
- **VALIDATE**: `flutter analyze` sıfır hata

### Task 15: Unit testler
- **ACTION**: SessionNotifier state testleri yaz

`test/features/session/providers/session_provider_test.dart`:
```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dilos/features/session/data/models/session_entry.dart';
import 'package:dilos/features/session/domain/entities/session_question.dart';
import 'package:dilos/features/session/domain/repositories/session_repository.dart';
import 'package:dilos/features/session/presentation/providers/session_provider.dart';
import 'package:dilos/core/database/isar_provider.dart';

class FakeSessionRepository implements SessionRepository {
  @override
  Future<List<SessionQuestion>> getQuestions() async => [
        const SessionQuestion(
          id: 'q1', text: 'Test soru 1',
          type: 'open', category: 'mood',
        ),
        const SessionQuestion(
          id: 'q2', text: 'Test soru 2',
          type: 'open', category: 'reflection',
        ),
      ];

  final List<SessionEntry> saved = [];

  @override
  Future<void> saveSession(SessionEntry entry) async {
    saved.add(entry);
  }

  @override
  Future<List<SessionEntry>> getRecentSessions({int limit = 10}) async => saved;

  @override
  Stream<List<SessionEntry>> watchSessions() => Stream.value(saved);
}

void main() {
  group('SessionNotifier', () {
    late ProviderContainer container;
    late FakeSessionRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeSessionRepository();
      container = ProviderContainer(overrides: [
        sessionRepositoryProvider.overrideWithValue(fakeRepo),
      ]);
    });

    tearDown(() => container.dispose());

    test('yükleme sonrası active duruma geçer', () async {
      await container.read(sessionProvider.notifier).future.catchError((_) {});
      await Future.delayed(Duration.zero); // async yüklenme bekle
      final state = container.read(sessionProvider);
      expect(state.status, SessionStatus.active);
    });

    test('cevap sonrası sonraki soruya geçer', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final notifier = container.read(sessionProvider.notifier);
      await notifier.submitAnswer('Test cevap', 'text');
      final state = container.read(sessionProvider);
      expect(state.currentIndex, 1);
    });

    test('tüm sorular cevaplandığında completed olur', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final notifier = container.read(sessionProvider.notifier);
      await notifier.submitAnswer('Cevap 1', 'text');
      await notifier.submitAnswer('Cevap 2', 'text');
      final state = container.read(sessionProvider);
      expect(state.status, SessionStatus.completed);
    });

    test('tamamlanan seans repository\'e kaydedilir', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final notifier = container.read(sessionProvider.notifier);
      await notifier.submitAnswer('Cevap 1', 'text');
      await notifier.submitAnswer('Cevap 2', 'text');
      expect(fakeRepo.saved, hasLength(1));
      expect(fakeRepo.saved.first.status, 'completed');
    });
  });
}
```
- **MIRROR**: TEST_STRUCTURE
- **VALIDATE**: `flutter test test/features/` geçiyor

---

## Testing Strategy

### Unit Tests

| Test | Input | Beklenen Çıktı | Edge Case? |
|---|---|---|---|
| Loading → active | Fake repo | `status == active` | Hayır |
| Cevap → sonraki soru | Answer text | `currentIndex++` | Hayır |
| Son soru cevabı | Answer text | `status == completed` | Hayır |
| Repo'ya kayıt | Complete session | `saved.length == 1` | Hayır |
| Boş cevap | `''` | Soru geçilmez | Evet |

### Edge Cases Checklist
- [ ] Mikrofon izni verilmezse ses butonu görünmez (`SizedBox.shrink`)
- [ ] Seans esnasında uygulama arka plana giderse ses durur
- [ ] JSON soru dosyası yüklenemezse error state gösterilir
- [ ] Isar yazma hatası gracefully handle edilir

---

## Validation Commands

### Bağımlılık
```bash
flutter pub get
```
EXPECT: Sıfır hata

### Kod Üretimi
```bash
dart run build_runner build --delete-conflicting-outputs
```
EXPECT: `session_entry.g.dart` oluştu

### Statik Analiz
```bash
flutter analyze
```
EXPECT: Sıfır hata

### Unit Testler
```bash
flutter test test/features/
```
EXPECT: Tüm testler geçiyor

### Manuel Kontrol
- [ ] Ana sayfadan "Seans Başlat"a tıklayınca session ekranı açılıyor
- [ ] 4 soru sırasıyla gösteriliyor, ilerleme çubuğu ilerliyor
- [ ] Yazı girip gönder'e basınca sonraki soruya geçiyor
- [ ] Son soru cevaplandıktan sonra tamamlama ekranı çıkıyor
- [ ] "Ana Sayfaya Dön" butonu home'a gidiyor
- [ ] Tamamlanan seans Isar'a kaydediliyor

---

## Acceptance Criteria
- [ ] `flutter pub get` hatasız
- [ ] `build_runner` `session_entry.g.dart` üretiyor
- [ ] `flutter analyze` sıfır hata
- [ ] `flutter test test/features/` geçiyor
- [ ] Session akışı baştan sona çalışıyor (manuel test)
- [ ] Ses girişi çalışıyor (gerçek cihazda)
- [ ] Cevaplar Isar'a kaydediliyor

## Completion Checklist
- [ ] Tüm dosyalar snake_case
- [ ] `autoDispose` ile provider temizleniyor
- [ ] Hardcoded string yok (soru metinleri JSON'da)
- [ ] Ses durumu `dispose()`'da temizleniyor
- [ ] `build_runner` çıktısı commit'e dahil

## Risks

| Risk | Olasılık | Etki | Çözüm |
|---|---|---|---|
| TR ses tanıma kalitesi | Orta | Orta | Yazı input her zaman açık |
| Mikrofon izni reddedilirse | Orta | Düşük | `SizedBox.shrink()` ile gizle |
| Isar yazma hatası | Düşük | Orta | try/catch, kullanıcıya hata gösterme |
| `sessionRepositoryProvider` Isar hazır değilken | Düşük | Yüksek | `StateError` throw — FutureProvider guard |

## Notes
- `speech_to_text 7.3.0` `js` paketine bağımlı değil — Isar uyumlu
- `sessionProvider.autoDispose` ile seans bitince state temizlenir; yeni seans açılınca sıfırdan başlar
- Soru havuzunda 6 soru var, her seansta 4 rastgele seçilir — tekrar minimized
- Faz 4'te AI bu cevapları `answersJson` üzerinden okuyacak
