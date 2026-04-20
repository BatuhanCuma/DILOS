import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dilos/features/brain_dump/data/models/brain_dump_entry.dart';
import 'package:dilos/features/brain_dump/domain/repositories/brain_dump_repository.dart';
import 'package:dilos/features/brain_dump/presentation/providers/brain_dump_provider.dart';
import 'package:dilos/core/database/isar_provider.dart';

class FakeBrainDumpRepository implements BrainDumpRepository {
  final List<BrainDumpEntry> entries = [];

  @override
  Future<void> saveEntry(BrainDumpEntry entry) async => entries.add(entry);

  @override
  Future<List<BrainDumpEntry>> getRecentEntries({int limit = 20}) async =>
      List.unmodifiable(entries);

  @override
  Stream<List<BrainDumpEntry>> watchEntries() =>
      Stream.value(List.unmodifiable(entries));
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
      expect(container.read(brainDumpProvider).recentEntries, isEmpty);
    });

    test('save sonrası status saved olur', () async {
      await container.read(brainDumpProvider.notifier).save('Test içerik');
      expect(container.read(brainDumpProvider).status, BrainDumpStatus.saved);
    });

    test("save sonrası entry repository'e kaydedilir", () async {
      await container.read(brainDumpProvider.notifier).save('Test içerik');
      expect(fakeRepo.entries, hasLength(1));
      expect(fakeRepo.entries.first.content, 'Test içerik');
    });

    test('boş içerik kaydedilmez', () async {
      await container.read(brainDumpProvider.notifier).save('   ');
      expect(fakeRepo.entries, isEmpty);
    });

    test('save sonrası recentEntries güncellenir', () async {
      await container.read(brainDumpProvider.notifier).save('Test içerik');
      expect(
          container.read(brainDumpProvider).recentEntries, hasLength(1));
    });

    test('reset idle duruma döner', () async {
      await container.read(brainDumpProvider.notifier).save('Test');
      container.read(brainDumpProvider.notifier).reset();
      expect(container.read(brainDumpProvider).status, BrainDumpStatus.idle);
    });
  });
}
