import 'package:flutter_test/flutter_test.dart';
import 'package:dilos/core/ai/ai_tagging_service.dart';
import 'package:dilos/core/ai/session_tags.dart';
import 'package:dilos/features/session/data/models/session_answer.dart';

void main() {
  group('AiTaggingService', () {
    late AiTaggingService service;

    setUp(() {
      service = AiTaggingService(apiKey: null); // disabled — no API key
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
      expect(result.topics, isEmpty);
    });

    test('boş answers listesi fallback döner', () async {
      final result = await service.tagSession([]);
      expect(result.mood, SessionTags.fallback.mood);
      expect(result.energy, SessionTags.fallback.energy);
    });

    test('isEnabled API key olmadan false döner', () {
      expect(service.isEnabled, false);
    });

    test('isEnabled API key ile true döner', () {
      final enabledService = AiTaggingService(apiKey: 'fake-key-123');
      expect(enabledService.isEnabled, true);
    });
  });

  group('SessionTags', () {
    test('fromJson tam veri doğru parse eder', () {
      final tags = SessionTags.fromJson({
        'mood': 'positive',
        'topics': ['work', 'health'],
        'energy': 'high',
      });
      expect(tags.mood, 'positive');
      expect(tags.topics, ['work', 'health']);
      expect(tags.energy, 'high');
    });

    test('fromJson eksik alanlar için fallback değerler kullanır', () {
      final tags = SessionTags.fromJson({});
      expect(tags.mood, 'neutral');
      expect(tags.topics, isEmpty);
      expect(tags.energy, 'medium');
    });

    test('toJson roundtrip çalışır', () {
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

    test('fallback sabit değerleri doğru', () {
      expect(SessionTags.fallback.mood, 'neutral');
      expect(SessionTags.fallback.energy, 'medium');
      expect(SessionTags.fallback.topics, isEmpty);
    });
  });
}
