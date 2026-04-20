import 'package:isar/isar.dart';

part 'journal_entry.g.dart';

@collection
class JournalEntry {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;
  late String gratitude;
  late String reflection;

  @ignore
  bool get isEmpty => gratitude.trim().isEmpty && reflection.trim().isEmpty;
}
