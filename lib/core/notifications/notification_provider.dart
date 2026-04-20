import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// true = a notification was tapped and the app should navigate to session
final notificationTappedProvider = StateProvider<bool>((ref) => false);
