import 'package:isar/isar.dart';
import '../entities/session_question.dart';
import '../../data/models/session_entry.dart';

abstract interface class SessionRepository {
  Future<List<SessionQuestion>> getQuestions();
  Future<void> saveSession(SessionEntry entry);
  Future<List<SessionEntry>> getRecentSessions({int limit = 10});
  Stream<List<SessionEntry>> watchSessions();
  Future<void> updateTags(Id entryId, String tagsJson);
}
