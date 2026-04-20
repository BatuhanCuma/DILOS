import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_service.dart';

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  throw UnimplementedError('onboardingServiceProvider must be overridden in main');
});

/// Initialized in main.dart before runApp
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);
