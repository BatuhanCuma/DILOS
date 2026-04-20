import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/session_question.dart';
import '../../domain/repositories/session_repository.dart';
import '../models/session_entry.dart';

class IsarSessionRepository implements SessionRepository {
  const IsarSessionRepository(this._isar);
  final Isar _isar;

  @override
  Future<List<SessionQuestion>> getQuestions() async {
    final String raw =
        await rootBundle.loadString('assets/data/session_questions.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = (data['questions'] as List).cast<Map<String, dynamic>>();
    return list.map(SessionQuestion.fromJson).toList();
  }

  @override
  Future<void> saveSession(SessionEntry entry) async {
    await _isar.writeTxn(() async {
      await _isar.sessionEntrys.put(entry);
    });
  }

  @override
  Future<List<SessionEntry>> getRecentSessions({int limit = 10}) {
    return _isar.sessionEntrys
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  @override
  Stream<List<SessionEntry>> watchSessions() {
    return _isar.sessionEntrys.where().watch(fireImmediately: true);
  }

  @override
  Future<void> updateTags(Id entryId, String tagsJson) async {
    await _isar.writeTxn(() async {
      final entry = await _isar.sessionEntrys.get(entryId);
      if (entry == null) return;
      entry.tagsJson = tagsJson;
      await _isar.sessionEntrys.put(entry);
    });
  }
}
