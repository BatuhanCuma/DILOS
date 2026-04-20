import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/session_history_provider.dart';
import '../../data/models/session_entry.dart';
import '../../../../core/ai/session_tags.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(sessionHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seans Geçmişi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: sessionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Hata: $e',
                style: const TextStyle(color: AppColors.error)),
          ),
          data: (sessions) {
            final completed =
                sessions.where((s) => s.isCompleted).toList();
            if (completed.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history_outlined,
                      size: 64,
                      color: AppColors.onSurfaceDim,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Henüz tamamlanmış seans yok.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'İlk seansını tamamla,\nburada görünecek.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceDim.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: completed.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _SessionCard(entry: completed[i]),
            );
          },
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.entry});
  final SessionEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('d MMM HH:mm', 'tr_TR').format(entry.createdAt);
    final tags = entry.isTagged
        ? SessionTags.fromJson(
            jsonDecode(entry.tagsJson!) as Map<String, dynamic>)
        : null;
    final answers = entry.answers;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$dateStr · ${entry.questionCount} soru',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceDim,
              ),
            ),
            if (tags != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  _TagChip(label: '${_moodEmoji(tags.mood)} ${tags.mood}'),
                  const SizedBox(width: AppSpacing.xs),
                  _TagChip(label: '⚡ ${tags.energy}'),
                  if (tags.topics.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _TagChip(label: tags.topics.first),
                  ],
                ],
              ),
            ],
          ],
        ),
        children: answers.map((a) {
          final text = a['text'] as String? ?? '';
          if (text.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text('• $text', style: theme.textTheme.bodyMedium),
          );
        }).toList(),
      ),
    );
  }

  String _moodEmoji(String mood) {
    return switch (mood) {
      'positive' => '😊',
      'negative' => '😞',
      'anxious' => '😰',
      'sad' => '😔',
      'excited' => '🤩',
      _ => '😌',
    };
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
