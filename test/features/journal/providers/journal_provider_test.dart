import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dilos/features/journal/data/models/journal_entry.dart';
import 'package:dilos/features/journal/domain/repositories/journal_repository.dart';
import 'package:dilos/features/journal/presentation/providers/journal_provider.dart';
import 'package:dilos/core/database/isar_provider.dart';

class FakeJournalRepository implements JournalRepository {
  final List<JournalEntry> entries = [];

  @override
  Future<void> saveEntry(JournalEntry entry) async => entries.add(entry);

  @override
  Future<List<JournalEntry>> getRecentEntries({int limit = 20}) async =>
      List.unmodifiable(entries);

  @override
  Stream<List<JournalEntry>> watchEntries() =>
      Stream.value(List.unmodifiable(entries));
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

    test("save sonrası entry repository'e kaydedilir", () async {
      await container.read(journalProvider.notifier).save('Minnet A', 'Yansıma B');
      expect(fakeRepo.entries, hasLength(1));
      expect(fakeRepo.entries.first.gratitude, 'Minnet A');
      expect(fakeRepo.entries.first.reflection, 'Yansıma B');
    });

    test('iki alan da boşsa kaydedilmez', () async {
      await container.read(journalProvider.notifier).save('  ', '  ');
      expect(fakeRepo.entries, isEmpty);
    });

    test('sadece gratitude dolu olsa kaydedilir', () async {
      await container.read(journalProvider.notifier).save('Minnet var', '');
      expect(fakeRepo.entries, hasLength(1));
    });

    test('save sonrası recentEntries güncellenir', () async {
      await container.read(journalProvider.notifier).save('Minnet', 'Yansıma');
      expect(container.read(journalProvider).recentEntries, hasLength(1));
    });
  });
}
