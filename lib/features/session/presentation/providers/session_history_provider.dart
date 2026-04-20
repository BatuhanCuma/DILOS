import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_entry.dart';
import '../../../../core/database/isar_provider.dart';

final sessionHistoryProvider = StreamProvider<List<SessionEntry>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchSessions();
});
