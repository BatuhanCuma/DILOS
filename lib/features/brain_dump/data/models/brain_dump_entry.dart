import 'package:isar/isar.dart';

part 'brain_dump_entry.g.dart';

@collection
class BrainDumpEntry {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;
  late String content;

  @ignore
  bool get isEmpty => content.trim().isEmpty;
}
