import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/database/isar_provider.dart';
import 'core/database/isar_service.dart';
import 'core/notifications/notification_provider.dart';
import 'core/onboarding/onboarding_provider.dart';
import 'core/onboarding/onboarding_service.dart';
import 'features/session/data/models/session_entry.dart';
import 'features/brain_dump/data/models/brain_dump_entry.dart';
import 'features/journal/data/models/journal_entry.dart';
import 'features/settings/data/models/notification_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.getInstance([
    SessionEntrySchema,
    BrainDumpEntrySchema,
    JournalEntrySchema,
    NotificationConfigSchema,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final onboardingService = OnboardingService(prefs);

  final container = ProviderContainer(
    overrides: [
      isarProvider.overrideWith((ref) => isar),
      onboardingServiceProvider.overrideWithValue(onboardingService),
    ],
  );

  container.read(onboardingCompletedProvider.notifier).state =
      onboardingService.isCompleted();

  final notificationService = container.read(notificationServiceProvider);
  await notificationService.initialize(
    onTap: () {
      container.read(notificationTappedProvider.notifier).state = true;
    },
  );

  final launchedFromNotification =
      await notificationService.wasLaunchedFromNotification();
  if (launchedFromNotification) {
    container.read(notificationTappedProvider.notifier).state = true;
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DilosApp(),
    ),
  );
}
