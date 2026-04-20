import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_routes.dart';

class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.accent,
                size: 64,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Seans tamamlandı', style: theme.textTheme.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kendine zaman ayırdın. Bu küçük ama önemli.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: AppColors.onSurfaceDim),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Ana Sayfaya Dön',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
