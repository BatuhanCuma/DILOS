import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dilos/core/notifications/notification_provider.dart';
import 'package:dilos/core/router/app_routes.dart';
import 'package:dilos/core/theme/app_colors.dart';
import 'package:dilos/core/theme/app_spacing.dart';
import 'package:dilos/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dilos/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dilos/features/dashboard/presentation/widgets/activity_counts.dart';
import 'package:dilos/features/dashboard/presentation/widgets/metric_row.dart';
import 'package:dilos/features/dashboard/presentation/widgets/narrative_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    ref.listen<bool>(notificationTappedProvider, (_, tapped) {
      if (tapped) {
        ref.read(notificationTappedProvider.notifier).state = false;
        context.go(AppRoutes.session);
      }
    });

    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final narrative = ref.watch(narrativeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('DILOS', style: theme.textTheme.displayLarge),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.onSurfaceDim,
            ),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: metricsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => const Center(
            child: Text(
              'Veriler yüklenemedi.',
              style: TextStyle(color: AppColors.error),
            ),
          ),
          data: (metrics) => _DashboardBody(
            narrative: narrative,
            metrics: metrics,
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.narrative,
    required this.metrics,
  });

  final String narrative;
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NarrativeCard(text: narrative),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.surfaceElevated),
          const SizedBox(height: AppSpacing.md),
          MetricRow(
            icon: Icons.psychology_outlined,
            label: 'Clarity',
            value: metrics.clarityScore,
          ),
          MetricRow(
            icon: Icons.anchor_outlined,
            label: 'Stability',
            value: metrics.stabilityScore,
          ),
          MetricRow(
            icon: Icons.explore_outlined,
            label: 'Exploration',
            value: metrics.explorationScore,
            isPlaceholder: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          ActivityCounts(
            sessions: metrics.totalSessions,
            journals: metrics.totalJournals,
            brainDumps: metrics.totalBrainDumps,
          ),
          const SizedBox(height: AppSpacing.xl),
          _ActionButton(
            label: 'Seans Başlat',
            color: AppColors.primary,
            onTap: () => context.go(AppRoutes.session),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Brain Dump',
                  color: AppColors.surfaceElevated,
                  onTap: () => context.push(AppRoutes.brainDump),
                  bordered: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  label: 'Journal',
                  color: AppColors.surfaceElevated,
                  onTap: () => context.push(AppRoutes.journal),
                  bordered: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.bordered = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: bordered
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
