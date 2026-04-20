import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _hour;
  late int _minute;
  late bool _isEnabled;
  bool _initialized = false;

  void _initFromState(SettingsState s) {
    if (_initialized) return;
    _hour = s.hour;
    _minute = s.minute;
    _isEnabled = s.isEnabled;
    _initialized = true;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  Future<void> _save() async {
    await ref.read(settingsProvider.notifier).save(
          hour: _hour,
          minute: _minute,
          isEnabled: _isEnabled,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    if (state.status == SettingsStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _initFromState(state);

    final timeLabel =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
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
                'Günlük hatırlatıcı',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Her gün belirlediğin saatte bir bildirim alırsın.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceDim,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bildirimleri aç', style: theme.textTheme.bodyLarge),
                    Switch(
                      value: _isEnabled,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primaryDim,
                      onChanged: (val) => setState(() => _isEnabled = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saat', style: theme.textTheme.bodyLarge),
                      Row(
                        children: [
                          Text(
                            timeLabel,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.onSurfaceDim,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: state.status == SettingsStatus.saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: state.status == SettingsStatus.saving
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
              if (state.status == SettingsStatus.saved) ...[
                const SizedBox(height: AppSpacing.sm),
                const Center(
                  child: Text(
                    'Kaydedildi ✓',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
              if (state.status == SettingsStatus.error) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    state.errorMessage ?? 'Hata oluştu',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
