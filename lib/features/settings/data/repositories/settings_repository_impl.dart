import 'package:isar/isar.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/notification_config.dart';

class IsarSettingsRepository implements SettingsRepository {
  const IsarSettingsRepository(this._isar);
  final Isar _isar;

  @override
  Future<NotificationConfig> getNotificationConfig() async {
    return await _isar.notificationConfigs.get(1) ?? NotificationConfig();
  }

  @override
  Future<void> saveNotificationConfig(NotificationConfig config) async {
    await _isar.writeTxn(() async {
      await _isar.notificationConfigs.put(config);
    });
  }
}
