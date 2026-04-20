import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../../../core/database/isar_provider.dart';

enum JournalStatus { idle, saving, saved, error }

class JournalState {
  const JournalState({
    required this.status,
    required this.recentEntries,
    this.errorMessage,
  });

  const JournalState.initial()
      : status = JournalStatus.idle,
        recentEntries = const [],
        errorMessage = null;

  final JournalStatus status;
  final List<JournalEntry> recentEntries;
  final String? errorMessage;

  JournalState copyWith({
    JournalStatus? status,
    List<JournalEntry>? recentEntries,
    String? errorMessage,
  }) =>
      JournalState(
        status: status ?? this.status,
        recentEntries: recentEntries ?? this.recentEntries,
        errorMessage: errorMessage,
      );
}

class JournalNotifier extends StateNotifier<JournalState> {
  JournalNotifier(this._repository) : super(const JournalState.initial()) {
    _loadRecent();
  }

  final JournalRepository _repository;

  Future<void> _loadRecent() async {
    try {
      final entries = await _repository.getRecentEntries();
      state = state.copyWith(recentEntries: entries);
    } on Exception catch (e) {
      state = state.copyWith(
        status: JournalStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> save(String gratitude, String reflection) async {
    final trimmedGratitude = gratitude.trim();
    final trimmedReflection = reflection.trim();
    if (trimmedGratitude.isEmpty && trimmedReflection.isEmpty) return;

    state = state.copyWith(status: JournalStatus.saving);
    try {
      final entry = JournalEntry()
        ..createdAt = DateTime.now()
        ..gratitude = trimmedGratitude
        ..reflection = trimmedReflection;
      await _repository.saveEntry(entry);
      final updated = await _repository.getRecentEntries();
      state = state.copyWith(
        status: JournalStatus.saved,
        recentEntries: updated,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        status: JournalStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = state.copyWith(status: JournalStatus.idle);
}

final journalProvider =
    StateNotifierProvider.autoDispose<JournalNotifier, JournalState>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return JournalNotifier(repo);
});
