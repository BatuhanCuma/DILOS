import 'package:flutter_test/flutter_test.dart';
import 'package:dilos/features/dashboard/domain/services/dashboard_calculator.dart';

void main() {
  group('DashboardCalculator', () {
    test('tüm boş girdi → sıfır metrikler', () {
      final metrics = DashboardCalculator.calculate(
        sessionDates: [],
        journalDates: [],
        brainDumpDates: [],
      );
      expect(metrics.clarityScore, 0.0);
      expect(metrics.stabilityScore, 0.0);
      expect(metrics.explorationScore, 0.0);
      expect(metrics.totalSessions, 0);
      expect(metrics.totalJournals, 0);
      expect(metrics.totalBrainDumps, 0);
      expect(metrics.lastActivityDate, isNull);
    });

    test('clarity skoru: (sessions*3 + journals*2 + dumps*1) / 50, max 1.0', () {
      final now = DateTime.now();
      final metrics = DashboardCalculator.calculate(
        sessionDates: List.filled(5, now),
        journalDates: List.filled(5, now),
        brainDumpDates: List.filled(5, now),
      );
      expect(metrics.clarityScore, closeTo(0.6, 0.01));
    });

    test('clarity skoru 1.0 üstüne çıkmaz', () {
      final now = DateTime.now();
      final metrics = DashboardCalculator.calculate(
        sessionDates: List.filled(20, now),
        journalDates: [],
        brainDumpDates: [],
      );
      expect(metrics.clarityScore, 1.0);
    });

    test('stability: son 30 günde aktif gün sayısı / 30', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));
      final metrics = DashboardCalculator.calculate(
        sessionDates: [now, now],
        journalDates: [yesterday],
        brainDumpDates: [twoDaysAgo],
      );
      expect(metrics.stabilityScore, closeTo(3 / 30, 0.01));
    });

    test('stability: 30 günden eski aktiviteler sayılmaz', () {
      final old = DateTime.now().subtract(const Duration(days: 31));
      final metrics = DashboardCalculator.calculate(
        sessionDates: [old],
        journalDates: [],
        brainDumpDates: [],
      );
      expect(metrics.stabilityScore, 0.0);
    });

    test('explorationScore her zaman 0.0', () {
      final now = DateTime.now();
      final metrics = DashboardCalculator.calculate(
        sessionDates: [now],
        journalDates: [now],
        brainDumpDates: [now],
      );
      expect(metrics.explorationScore, 0.0);
    });

    test('lastActivityDate en son tarih döner', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final metrics = DashboardCalculator.calculate(
        sessionDates: [yesterday],
        journalDates: [now],
        brainDumpDates: [],
      );
      expect(metrics.lastActivityDate, now);
    });
  });
}
