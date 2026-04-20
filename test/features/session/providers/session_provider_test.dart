import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dilos/features/session/data/models/session_entry.dart';
import 'package:dilos/features/session/domain/entities/session_question.dart';
import 'package:dilos/features/session/domain/repositories/session_repository.dart';
import 'package:dilos/features/session/presentation/providers/session_provider.dart';
import 'package:dilos/core/database/isar_provider.dart';
import 'package:dilos/core/ai/ai_provider.dart';
import 'package:dilos/core/ai/ai_tagging_service.dart';
import 'package:dilos/core/ai/session_tags.dart';
import 'package:dilos/features/session/data/models/session_answer.dart';

class FakeSessionRepository implements SessionRepository {
  @override
  Future<List<SessionQuestion>> getQuestions() async => [
        const SessionQuestion(
          id: 'q1',
          text: 'Test soru 1',
          type: 'open',
          category: 'mood',
        ),
        const SessionQuestion(
          id: 'q2',
          text: 'Test soru 2',
          type: 'open',
          category: 'reflection',
        ),
      ];

  final List<SessionEntry> saved = [];

  @override
  Future<void> saveSession(SessionEntry entry) async => saved.add(entry);

  @override
  Future<List<SessionEntry>> getRecentSessions({int limit = 10}) async =>
      saved;

  @override
  Stream<List<SessionEntry>> watchSessions() => Stream.value(saved);

  @override
  Future<void> updateTags(Id entryId, String tagsJson) async {}
}

class FakeAiTaggingService extends AiTaggingService {
  FakeAiTaggingService() : super(apiKey: null);

  @override
  Future<SessionTags> tagSession(List<SessionAnswer> answers) async =>
      SessionTags.fallback;
}

/// Loading tamamlanana kadar bekler
Future<void> waitForActive(ProviderContainer container) async {
  if (container.read(sessionProvider).status != SessionStatus.loading) return;
  final completer = Completer<void>();
  final sub = container.listen(sessionProvider, (_, next) {
    if (next.status != SessionStatus.loading && !completer.isCompleted) {
      completer.complete();
    }
  });
  await completer.future.timeout(const Duration(seconds: 5));
  sub.close();
}

void main() {
  group('SessionNotifier', () {
    late ProviderContainer container;
    late FakeSessionRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeSessionRepository();
      container = ProviderContainer(
        overrides: [
          sessionRepositoryProvider.overrideWithValue(fakeRepo),
          aiTaggingServiceProvider.overrideWithValue(FakeAiTaggingService()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('yükleme sonrası active duruma geçer', () async {
      await waitForActive(container);
      expect(container.read(sessionProvider).status, SessionStatus.active);
      expect(container.read(sessionProvider).questions.length, 2);
    });

    test('başlangıçta ilk soru gösterilir', () async {
      await waitForActive(container);
      final state = container.read(sessionProvider);
      expect(state.currentIndex, 0);
      expect(state.currentQuestion, isNotNull);
    });

    test('cevap sonrası sonraki soruya geçer', () async {
      await waitForActive(container);
      await container
          .read(sessionProvider.notifier)
          .submitAnswer('Test cevap', 'text');
      expect(container.read(sessionProvider).currentIndex, 1);
    });

    test('tüm sorular cevaplandığında completed olur', () async {
      await waitForActive(container);
      final notifier = container.read(sessionProvider.notifier);
      await notifier.submitAnswer('Cevap 1', 'text');
      await notifier.submitAnswer('Cevap 2', 'text');
      expect(
        container.read(sessionProvider).status,
        SessionStatus.completed,
      );
    });

    test("tamamlanan seans repository'e kaydedilir", () async {
      await waitForActive(container);
      final notifier = container.read(sessionProvider.notifier);
      await notifier.submitAnswer('Cevap 1', 'text');
      await notifier.submitAnswer('Cevap 2', 'text');
      expect(fakeRepo.saved, hasLength(1));
      expect(fakeRepo.saved.first.status, 'completed');
      expect(fakeRepo.saved.first.questionCount, 2);
    });

    test('geç butonu sonraki soruya geçer', () async {
      await waitForActive(container);
      container.read(sessionProvider.notifier).skipQuestion();
      expect(container.read(sessionProvider).currentIndex, 1);
    });

    test('son soruda geç completed yapar', () async {
      await waitForActive(container);
      final notifier = container.read(sessionProvider.notifier);
      notifier.skipQuestion();
      notifier.skipQuestion();
      expect(
        container.read(sessionProvider).status,
        SessionStatus.completed,
      );
    });
  });
}
