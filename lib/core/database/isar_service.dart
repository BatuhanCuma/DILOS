import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> getInstance(
    List<CollectionSchema<dynamic>> schemas,
  ) async {
    if (_instance != null && _instance!.isOpen) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      schemas,
      directory: dir.path,
      name: 'dilos_db',
    );
    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
