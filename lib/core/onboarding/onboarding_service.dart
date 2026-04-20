import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  OnboardingService(this._prefs);
  final SharedPreferences _prefs;

  static const _key = 'onboarding_completed';

  bool isCompleted() => _prefs.getBool(_key) ?? false;

  Future<void> complete() => _prefs.setBool(_key, true);
}
