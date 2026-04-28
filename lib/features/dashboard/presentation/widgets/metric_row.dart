import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class MetricRow extends StatelessWidget {
  const MetricRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final double value; // 0.0 to 1.0
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (value * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            color: isPlaceholder ? AppColors.onSurfaceDim : AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isPlaceholder
                    ? AppColors.onSurfaceDim
                    : AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation(
                  isPlaceholder ? AppColors.onSurfaceDim : AppColors.accent,
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 32,
            child: Text(
              isPlaceholder ? '--' : '$percentage%',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
