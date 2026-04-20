import 'dart:convert';
import 'package:isar/isar.dart';

part 'session_entry.g.dart';

@collection
class SessionEntry {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;
  late String status; // 'pending' | 'completed' | 'abandoned'
  late int questionCount;
  late String answersJson;
  String? tagsJson; // null until AI tagging completes

  @ignore
  bool get isCompleted => status == 'completed';

  @ignore
  bool get isTagged => tagsJson != null;

  @ignore
  List<Map<String, dynamic>> get answers =>
      (jsonDecode(answersJson) as List).cast<Map<String, dynamic>>();
}
