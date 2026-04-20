import '../../data/models/brain_dump_entry.dart';

abstract interface class BrainDumpRepository {
  Future<void> saveEntry(BrainDumpEntry entry);
  Future<List<BrainDumpEntry>> getRecentEntries({int limit = 20});
  Stream<List<BrainDumpEntry>> watchEntries();
}
