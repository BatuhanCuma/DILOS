import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/onboarding/onboarding_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.nights_stay_outlined,
      title: 'DILOS Nedir?',
      body: 'Kısa seanslarda kendini yeniden keşfet. '
          'Burnout ve yalnızlıkla başa çıkmak için '
          'tasarlanmış bir zihin alanı.',
    ),
    _OnboardingPage(
      icon: Icons.bubble_chart_outlined,
      title: 'Nasıl Çalışır?',
      body: 'Her gün 2–5 dakika. Uygulama sana sorular sorar, '
          'sen sadece cevaplarsın. AI arka planda çalışır, '
          'sen sadece akışa girersin.',
    ),
    _OnboardingPage(
      icon: Icons.notifications_none_outlined,
      title: 'Hazır Mısın?',
      body: 'Bildirim ayarlayarak günlük hatırlatıcı ekleyebilirsin. '
          'Ya da direkt başlayabilirsin — seçim senindir.',
    ),
  ];

  Future<void> _complete() async {
    final service = ref.read(onboardingServiceProvider);
    await service.complete();
    ref.read(onboardingCompletedProvider.notifier).state = true;
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: const Text(
                  'Geç',
                  style: TextStyle(color: AppColors.onSurfaceDim),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPageWidget(page: _pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? AppColors.primary
                        : AppColors.onSurfaceDim.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GestureDetector(
                onTap: isLast
                    ? _complete
                    : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isLast ? 'Başla' : 'Sonraki',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.icon, size: 80, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xl),
          Text(
            page.title,
            style: theme.textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceDim,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
