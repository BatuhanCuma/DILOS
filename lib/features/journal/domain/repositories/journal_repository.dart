import '../../data/models/journal_entry.dart';

abstract interface class JournalRepository {
  Future<void> saveEntry(JournalEntry entry);
  Future<List<JournalEntry>> getRecentEntries({int limit = 20});
  Stream<List<JournalEntry>> watchEntries();
}
