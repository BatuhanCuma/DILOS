import '../../data/models/notification_config.dart';

abstract interface class SettingsRepository {
  Future<NotificationConfig> getNotificationConfig();
  Future<void> saveNotificationConfig(NotificationConfig config);
}
