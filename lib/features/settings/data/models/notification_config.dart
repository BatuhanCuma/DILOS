import 'package:isar/isar.dart';

part 'notification_config.g.dart';

@collection
class NotificationConfig {
  Id id = 1; // Singleton — always upsert with id=1
  int hour = 9;
  int minute = 0;
  bool isEnabled = false;
}
