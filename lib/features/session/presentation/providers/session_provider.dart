import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../data/models/session_answer.dart';
import '../../data/models/session_entry.dart';
import '../../domain/entities/session_question.dart';
import '../../domain/repositories/session_repository.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/ai/ai_tagging_service.dart';

enum SessionStatus { loading, active, completed, error }

class SessionState {
  const SessionState({
    required this.status,
    required this.questions,
    required this.answers,
    required this.currentIndex,
    this.errorMessage,
  });

  const SessionState.initial()
      : status = SessionStatus.loading,
        questions = const [],
        answers = const [],
        currentIndex = 0,
        errorMessage = null;

  final SessionStatus status;
  final List<SessionQuestion> questions;
  final List<SessionAnswer> answers;
  final int currentIndex;
  final String? errorMessage;

  bool get isLastQuestion =>
      questions.isNotEmpty && currentIndex >= questions.length - 1;

  SessionQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  SessionState copyWith({
    SessionStatus? status,
    List<SessionQuestion>? questions,
    List<SessionAnswer>? answers,
    int? currentIndex,
    String? errorMessage,
  }) =>
      SessionState(
        status: status ?? this.status,
        questions: questions ?? this.questions,
        answers: answers ?? this.answers,
        currentIndex: currentIndex ?? this.currentIndex,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._repository, this._aiService)
      : super(const SessionState.initial()) {
    _loadQuestions();
  }

  final SessionRepository _repository;
  final AiTaggingService _aiService;

  Future<void> _loadQuestions() async {
    try {
      final questions = await _repository.getQuestions();
      final shuffled = List<SessionQuestion>.from(questions)..shuffle();
      state = state.copyWith(
        status: SessionStatus.active,
        questions: shuffled.take(4).toList(),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> submitAnswer(String answerText, String inputType) async {
    if (state.currentQuestion == null) return;

    final answer = SessionAnswer(
      questionId: state.currentQuestion!.id,
      text: answerText,
      inputType: inputType,
      answeredAt: DateTime.now(),
    );

    final updatedAnswers = [...state.answers, answer];

    if (state.isLastQuestion) {
      await _saveSession(updatedAnswers);
      state = state.copyWith(
        status: SessionStatus.completed,
        answers: updatedAnswers,
      );
    } else {
      state = state.copyWith(
        answers: updatedAnswers,
        currentIndex: state.currentIndex + 1,
      );
    }
  }

  Future<void> _saveSession(List<SessionAnswer> answers) async {
    final entry = SessionEntry()
      ..createdAt = DateTime.now()
      ..status = 'completed'
      ..questionCount = answers.length
      ..answersJson = jsonEncode(answers.map((a) => a.toJson()).toList());

    await _repository.saveSession(entry);
    // Fire-and-forget: kullanıcı beklemez, hata olsa session etkilenmez
    unawaited(_tagSession(entry.id, answers));
  }

  Future<void> _tagSession(Id entryId, List<SessionAnswer> answers) async {
    try {
      final tags = await _aiService.tagSession(answers);
      await _repository.updateTags(
        entryId,
        jsonEncode(tags.toJson()),
      );
    } on Exception {
      // Tagging sessizce başarısız olabilir — session zaten kaydedildi
    }
  }

  void skipQuestion() {
    if (state.isLastQuestion) {
      state = state.copyWith(status: SessionStatus.completed);
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }
}

final sessionProvider =
    StateNotifierProvider.autoDispose<SessionNotifier, SessionState>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  final aiService = ref.watch(aiTaggingServiceProvider);
  return SessionNotifier(repo, aiService);
});
