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
