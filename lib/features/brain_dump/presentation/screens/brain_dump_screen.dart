import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/brain_dump_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(brainDumpProvider.notifier).save(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brainDumpProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Dump'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kafanda ne var? Yaz, döküver.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _controller,
                maxLines: 6,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Buraya yaz...',
                  hintStyle: TextStyle(color: AppColors.onSurfaceDim),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap:
                    state.status == BrainDumpStatus.saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: state.status == BrainDumpStatus.saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Kaydet',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              if (state.status == BrainDumpStatus.saved) ...[
                const SizedBox(height: AppSpacing.sm),
                const Center(
                  child: Text(
                    'Kaydedildi ✓',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (state.recentEntries.isNotEmpty) ...[
                Text('Geçmiş', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.recentEntries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final entry = state.recentEntries[i];
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('d MMM HH:mm', 'tr_TR')
                                  .format(entry.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceDim,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              entry.content,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.edit_note_outlined,
                        size: 48,
                        color: AppColors.onSurfaceDim,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Henüz bir şey yazmadın.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'İlk düşünceni döküver.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceDim.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
