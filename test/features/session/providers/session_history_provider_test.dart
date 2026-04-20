import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dilos/features/session/data/models/session_entry.dart';
import 'package:dilos/features/session/domain/repositories/session_repository.dart';
import 'package:dilos/features/session/domain/entities/session_question.dart';
import 'package:dilos/features/session/presentation/providers/session_history_provider.dart';
import 'package:dilos/core/database/isar_provider.dart';

class FakeSessionRepository implements SessionRepository {
  final List<SessionEntry> _sessions = [];

  @override
  Stream<List<SessionEntry>> watchSessions() =>
      Stream.value(List.unmodifiable(_sessions));

  @override
  Future<List<SessionEntry>> getRecentSessions({int limit = 10}) async =>
      _sessions.take(limit).toList();

  @override
  Future<void> saveSession(SessionEntry entry) async =>
      _sessions.add(entry);

  @override
  Future<void> updateTags(Id entryId, String tagsJson) async {}

  @override
  Future<List<SessionQuestion>> getQuestions() async => [];

  void addSession(SessionEntry entry) => _sessions.add(entry);
}

SessionEntry _makeEntry({String status = 'completed'}) {
  final e = SessionEntry()
    ..createdAt = DateTime.now()
    ..status = status
    ..questionCount = 3
    ..answersJson =
        '[{"questionId":"q1","text":"Test cevap","inputType":"text","answeredAt":"${DateTime.now().toIso8601String()}"}]';
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

    test('boş liste ile data döner', () async {
      final result = await container.read(sessionHistoryProvider.future);
      expect(result, isEmpty);
    });

    test('eklenen seans listede görünür', () async {
      fakeRepo.addSession(_makeEntry());
      final result = await container.read(sessionHistoryProvider.future);
      expect(result.length, 1);
    });

    test('tüm status türleri listelenir (filtreleme ekranda yapılır)', () async {
      fakeRepo.addSession(_makeEntry(status: 'completed'));
      fakeRepo.addSession(_makeEntry(status: 'abandoned'));
      final result = await container.read(sessionHistoryProvider.future);
      expect(result.length, 2);
    });
  });
}
