import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/text_input_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_routes.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);

    ref.listen(sessionProvider, (_, next) {
      if (next.status == SessionStatus.completed) {
        context.go(AppRoutes.sessionComplete);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: switch (state.status) {
          SessionStatus.loading => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          SessionStatus.error => Center(
              child: Text(
                state.errorMessage ?? 'Bir hata oluştu',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          SessionStatus.completed => const SizedBox.shrink(),
          SessionStatus.active => _ActiveSession(
              state: state,
              onAnswer: notifier.submitAnswer,
              onSkip: notifier.skipQuestion,
            ),
        },
      ),
    );
  }
}

class _ActiveSession extends StatelessWidget {
  const _ActiveSession({
    required this.state,
    required this.onAnswer,
    required this.onSkip,
  });

  final SessionState state;
  final Future<void> Function(String text, String type) onAnswer;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionCard(
            question: question,
            progress: state.progress,
            questionNumber: state.currentIndex + 1,
            totalQuestions: state.questions.length,
          ),
          const Spacer(),
          Center(
            child: VoiceInputButton(
              onResult: (text) => onAnswer(text, 'voice'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextInputField(
            onSubmit: (text) => onAnswer(text, 'text'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: const Text(
                'Bu soruyu geç',
                style: TextStyle(color: AppColors.onSurfaceDim),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
