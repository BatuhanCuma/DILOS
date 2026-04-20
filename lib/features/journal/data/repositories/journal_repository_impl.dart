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
