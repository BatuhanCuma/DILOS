import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  late final TextEditingController _gratitudeController;
  late final TextEditingController _reflectionController;

  @override
  void initState() {
    super.initState();
    _gratitudeController = TextEditingController();
    _reflectionController = TextEditingController();
  }

  @override
  void dispose() {
    _gratitudeController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(journalProvider.notifier).save(
          _gratitudeController.text,
          _reflectionController.text,
        );
    _gratitudeController.clear();
    _reflectionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PromptField(
                label: 'Minnet',
                hint: 'Bugün minnettar olduğun şeyler...',
                controller: _gratitudeController,
                theme: theme,
              ),
              const SizedBox(height: AppSpacing.md),
              _PromptField(
                label: 'Yansıma',
                hint: 'Bugün nasıl geçti?',
                controller: _reflectionController,
                theme: theme,
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: state.status == JournalStatus.saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: state.status == JournalStatus.saving
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
              if (state.status == JournalStatus.saved) ...[
                const SizedBox(height: AppSpacing.sm),
                const Center(
                  child: Text(
                    'Kaydedildi ✓',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
              if (state.recentEntries.isEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_stories_outlined,
                        size: 48,
                        color: AppColors.onSurfaceDim,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Henüz bir giriş yok.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Bugün nasıldı?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceDim.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              if (state.recentEntries.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Geçmiş', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                ...state.recentEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
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
                          if (entry.gratitude.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Minnet: ${entry.gratitude}',
                              style: theme.textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (entry.reflection.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Yansıma: ${entry.reflection}',
                              style: theme.textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
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

class _PromptField extends StatelessWidget {
  const _PromptField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.theme,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          maxLines: 4,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.onSurfaceDim),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
