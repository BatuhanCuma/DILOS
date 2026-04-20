import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/brain_dump_entry.dart';
import '../../domain/repositories/brain_dump_repository.dart';
import '../../../../core/database/isar_provider.dart';

enum BrainDumpStatus { idle, saving, saved, error }

class BrainDumpState {
  const BrainDumpState({
    required this.status,
    required this.recentEntries,
    this.errorMessage,
  });

  const BrainDumpState.initial()
      : status = BrainDumpStatus.idle,
        recentEntries = const [],
        errorMessage = null;

  final BrainDumpStatus status;
  final List<BrainDumpEntry> recentEntries;
  final String? errorMessage;

  BrainDumpState copyWith({
    BrainDumpStatus? status,
    List<BrainDumpEntry>? recentEntries,
    String? errorMessage,
  }) =>
      BrainDumpState(
        status: status ?? this.status,
        recentEntries: recentEntries ?? this.recentEntries,
        errorMessage: errorMessage,
      );
}

class BrainDumpNotifier extends StateNotifier<BrainDumpState> {
  BrainDumpNotifier(this._repository) : super(const BrainDumpState.initial()) {
    _loadRecent();
  }

  final BrainDumpRepository _repository;

  Future<void> _loadRecent() async {
    try {
      final entries = await _repository.getRecentEntries();
      state = state.copyWith(recentEntries: entries);
    } on Exception catch (e) {
      state = state.copyWith(
        status: BrainDumpStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> save(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(status: BrainDumpStatus.saving);
    try {
      final entry = BrainDumpEntry()
        ..createdAt = DateTime.now()
        ..content = trimmed;
      await _repository.saveEntry(entry);
      final updated = await _repository.getRecentEntries();
      state = state.copyWith(
        status: BrainDumpStatus.saved,
        recentEntries: updated,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        status: BrainDumpStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = state.copyWith(status: BrainDumpStatus.idle);
}

final brainDumpProvider =
    StateNotifierProvider.autoDispose<BrainDumpNotifier, BrainDumpState>((ref) {
  final repo = ref.watch(brainDumpRepositoryProvider);
  return BrainDumpNotifier(repo);
});
