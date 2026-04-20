import 'package:flutter/material.dart';
import '../../domain/entities/session_question.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.progress,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final SessionQuestion question;
  final double progress;
  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$questionNumber / $totalQuestions',
                style: theme.textTheme.bodyMedium),
            Text('${(progress * 100).toInt()}%',
                style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(question.text, style: theme.textTheme.headlineMedium),
      ],
    );
  }
}
