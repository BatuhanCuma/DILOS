import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class ActivityCounts extends StatelessWidget {
  const ActivityCounts({
    super.key,
    required this.sessions,
    required this.journals,
    required this.brainDumps,
  });

  final int sessions;
  final int journals;
  final int brainDumps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _CountCell(value: sessions, label: 'Seans')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _CountCell(value: journals, label: 'Journal')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _CountCell(value: brainDumps, label: 'Dump')),
      ],
    );
  }
}

class _CountCell extends StatelessWidget {
  const _CountCell({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
