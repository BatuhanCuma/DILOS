import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/onboarding/onboarding_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/session/presentation/screens/session_screen.dart';
import '../../features/session/presentation/screens/session_complete_screen.dart';
import '../../features/brain_dump/presentation/screens/brain_dump_screen.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/session/presentation/screens/session_history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.read(onboardingCompletedProvider);
  return GoRouter(
    initialLocation:
        onboardingCompleted ? AppRoutes.home : AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionComplete,
        builder: (context, state) => const SessionCompleteScreen(),
      ),
      GoRoute(
        path: AppRoutes.brainDump,
        builder: (context, state) => const BrainDumpScreen(),
      ),
      GoRoute(
        path: AppRoutes.journal,
        builder: (context, state) => const JournalScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionHistory,
        builder: (context, state) => const SessionHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
