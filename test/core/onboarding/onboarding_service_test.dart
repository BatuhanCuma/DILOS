import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dilos/core/onboarding/onboarding_service.dart';

void main() {
  group('OnboardingService', () {
    late OnboardingService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = OnboardingService(prefs);
    });

    test('başlangıçta tamamlanmamış döner', () {
      expect(service.isCompleted(), false);
    });

    test('complete sonrası tamamlanmış döner', () async {
      await service.complete();
      expect(service.isCompleted(), true);
    });

    test('complete kalıcı: aynı prefs örneği ile doğrulanır', () async {
      await service.complete();
      final prefs2 = await SharedPreferences.getInstance();
      final service2 = OnboardingService(prefs2);
      expect(service2.isCompleted(), true);
    });
  });
}
