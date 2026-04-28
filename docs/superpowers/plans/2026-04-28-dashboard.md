# Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Home screen'i "Narrative First" dashboard'a dönüştür — AI cümlesi + 4 metrik satırı + activity sayıları + CTA butonlar.

**Architecture:** `DashboardCalculator` pure static class hesaplama mantığını barındırır (Isar bağımsız, test edilebilir). `IsarDashboardRepository` Isar'dan ham tarihleri çeker ve Calculator'a devreder. `dashboardMetricsProvider` (FutureProvider.autoDispose) provider'ı navigate edilince otomatik sıfırlanır.

**Tech Stack:** Flutter, Riverpod (FutureProvider), Isar 3, go_router

---

## File Map

| Dosya | İşlem | Sorumluluk |
|-------|-------|------------|
| `lib/features/dashboard/domain/entities/dashboard_metrics.dart` | CREATE | Immutable value object |
| `lib/features/dashboard/domain/services/dashboard_calculator.dart` | CREATE | Pure hesaplama mantığı |
| `lib/features/dashboard/domain/services/narrative_service.dart` | CREATE | Rule-based cümle seçimi |
| `lib/features/dashboard/domain/repositories/dashboard_repository.dart` | CREATE | Abstract interface |
| `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart` | CREATE | Isar implementasyonu |
| `lib/features/dashboard/presentation/providers/dashboard_provider.dart` | CREATE | FutureProvider + narrative string |
| `lib/features/dashboard/presentation/widgets/narrative_card.dart` | CREATE | AI cümlesini gösteren widget |
| `lib/features/dashboard/presentation/widgets/metric_row.dart` | CREATE | icon + label + progress bar |
| `lib/features/dashboard/presentation/widgets/activity_counts.dart` | CREATE | 3 sayı yan yana |
| `lib/core/database/isar_provider.dart` | MODIFY | `dashboardRepositoryProvider` ekle |
| `lib/features/home/presentation/screens/home_screen.dart` | MODIFY | Dashboard'a dönüştür |
| `test/features/dashboard/domain/services/dashboard_calculator_test.dart` | CREATE | Hesaplama unit testleri |
| `test/features/dashboard/domain/services/narrative_service_test.dart` | CREATE | Narrative kural testleri |
| `test/features/dashboard/presentation/providers/dashboard_provider_test.dart` | CREATE | Provider state testleri |

---

## Task 1: DashboardMetrics entity + DashboardCalculator

**Files:**
- Create: `lib/features/dashboard/domain/entities/dashboard_metrics.dart`
- Create: `lib/features/dashboard/domain/services/dashboard_calculator.dart`
- Create: `test/features/dashboard/domain/services/dashboard_calculator_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/dashboard/domain/services/dashboard_calculator_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dilos/features/dashboard/domain/entities/dashboard_metrics.dart';
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
        sessionDates: List.filled(5, now),   // 5 * 3 = 15
        journalDates: List.filled(5, now),   // 5 * 2 = 10
        brainDumpDates: List.filled(5, now), // 5 * 1 = 5
        // toplam = 30, 30/50 = 0.6
      );
      expect(metrics.clarityScore, closeTo(0.6, 0.01));
    });

    test('clarity skoru 1.0 üstüne çıkmaz', () {
      final now = DateTime.now();
      final metrics = DashboardCalculator.calculate(
        sessionDates: List.filled(20, now),
        journalDates: [],
        brainDumpDates: [],
        // 20*3=60, 60/50 > 1.0 → clamp 1.0
      );
      expect(metrics.clarityScore, 1.0);
    });

    test('stability: son 30 günde aktif gün sayısı / 30', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));
      final metrics = DashboardCalculator.calculate(
        sessionDates: [now, now], // aynı gün, 1 unique
        journalDates: [yesterday], // 1 unique gün
        brainDumpDates: [twoDaysAgo], // 1 unique gün
        // toplam 3 unique gün → 3/30 ≈ 0.1
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
```

- [ ] **Step 2: Testi çalıştır — FAIL bekleniyor**

```bash
flutter test test/features/dashboard/domain/services/dashboard_calculator_test.dart
```
Beklenen: `Error: cannot find 'DashboardCalculator'`

- [ ] **Step 3: DashboardMetrics entity oluştur**

`lib/features/dashboard/domain/entities/dashboard_metrics.dart`:
```dart
class DashboardMetrics {
  const DashboardMetrics({
    required this.clarityScore,
    required this.stabilityScore,
    required this.explorationScore,
    required this.totalSessions,
    required this.totalJournals,
    required this.totalBrainDumps,
    required this.lastActivityDate,
  });

  final double clarityScore;
  final double stabilityScore;
  final double explorationScore;
  final int totalSessions;
  final int totalJournals;
  final int totalBrainDumps;
  final DateTime? lastActivityDate;

  static const empty = DashboardMetrics(
    clarityScore: 0,
    stabilityScore: 0,
    explorationScore: 0,
    totalSessions: 0,
    totalJournals: 0,
    totalBrainDumps: 0,
    lastActivityDate: null,
  );
}
```

- [ ] **Step 4: DashboardCalculator oluştur**

`lib/features/dashboard/domain/services/dashboard_calculator.dart`:
```dart
import '../entities/dashboard_metrics.dart';

class DashboardCalculator {
  DashboardCalculator._();

  static DashboardMetrics calculate({
    required List<DateTime> sessionDates,
    required List<DateTime> journalDates,
    required List<DateTime> brainDumpDates,
  }) {
    final totalSessions = sessionDates.length;
    final totalJournals = journalDates.length;
    final totalBrainDumps = brainDumpDates.length;

    final clarityRaw = totalSessions * 3 + totalJournals * 2 + totalBrainDumps;
    final clarityScore = (clarityRaw / 50).clamp(0.0, 1.0);

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentDates = [
      ...sessionDates,
      ...journalDates,
      ...brainDumpDates,
    ].where((d) => d.isAfter(thirtyDaysAgo));

    final uniqueDays = recentDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    final stabilityScore = (uniqueDays.length / 30).clamp(0.0, 1.0);

    final allDates = [...sessionDates, ...journalDates, ...brainDumpDates];
    final lastActivityDate =
        allDates.isEmpty ? null : (List.of(allDates)..sort()).last;

    return DashboardMetrics(
      clarityScore: clarityScore,
      stabilityScore: stabilityScore,
      explorationScore: 0,
      totalSessions: totalSessions,
      totalJournals: totalJournals,
      totalBrainDumps: totalBrainDumps,
      lastActivityDate: lastActivityDate,
    );
  }
}
```

- [ ] **Step 5: Testi çalıştır — PASS bekleniyor**

```bash
flutter test test/features/dashboard/domain/services/dashboard_calculator_test.dart
```
Beklenen: `All tests passed`

- [ ] **Step 6: Analiz**

```bash
flutter analyze lib/features/dashboard/domain/
```
Beklenen: sıfır hata

- [ ] **Step 7: Commit**

```bash
git add lib/features/dashboard/domain/entities/ lib/features/dashboard/domain/services/dashboard_calculator.dart test/features/dashboard/domain/services/dashboard_calculator_test.dart
git commit -m "feat: DashboardMetrics entity ve DashboardCalculator"
```

---

## Task 2: NarrativeService

**Files:**
- Create: `lib/features/dashboard/domain/services/narrative_service.dart`
- Create: `test/features/dashboard/domain/services/narrative_service_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/dashboard/domain/services/narrative_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dilos/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dilos/features/dashboard/domain/services/narrative_service.dart';

DashboardMetrics _metrics({
  double clarity = 0.5,
  double stability = 0.5,
  int sessions = 5,
  DateTime? lastActivity,
}) =>
    DashboardMetrics(
      clarityScore: clarity,
      stabilityScore: stability,
      explorationScore: 0,
      totalSessions: sessions,
      totalJournals: 0,
      totalBrainDumps: 0,
      lastActivityDate: lastActivity,
    );

void main() {
  group('NarrativeService', () {
    test('lastActivityDate null → "Bir süredir ortalıkta yoksun"', () {
      final result = NarrativeService.getNarrative(
        _metrics(lastActivity: null),
      );
      expect(result, 'Bir süredir ortalıkta yoksun, nasılsın?');
    });

    test('7 günden eski aktivite → "Bir süredir ortalıkta yoksun"', () {
      final old = DateTime.now().subtract(const Duration(days: 8));
      final result = NarrativeService.getNarrative(
        _metrics(lastActivity: old),
      );
      expect(result, 'Bir süredir ortalıkta yoksun, nasılsın?');
    });

    test('bugün aktivite var → "Bugün de kendinle vakit geçirdin"', () {
      final result = NarrativeService.getNarrative(
        _metrics(lastActivity: DateTime.now()),
      );
      expect(result, 'Bugün de kendinle vakit geçirdin.');
    });

    test('stability > 0.6 → "Düzenli bir ritim yakalamışsın"', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = NarrativeService.getNarrative(
        _metrics(stability: 0.65, lastActivity: yesterday),
      );
      expect(result, 'Düzenli bir ritim yakalamışsın.');
    });

    test('clarity > 0.7 → "Zihnin son zamanlarda oldukça aktif"', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = NarrativeService.getNarrative(
        _metrics(clarity: 0.75, stability: 0.3, lastActivity: yesterday),
      );
      expect(result, 'Zihnin son zamanlarda oldukça aktif.');
    });

    test('totalSessions < 3 → "Henüz başlangıçtasın"', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = NarrativeService.getNarrative(
        _metrics(sessions: 2, clarity: 0.1, stability: 0.1, lastActivity: yesterday),
      );
      expect(result, 'Henüz başlangıçtasın, devam et.');
    });

    test('hiçbir koşul yok → default cümle', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = NarrativeService.getNarrative(
        _metrics(clarity: 0.4, stability: 0.3, sessions: 5, lastActivity: yesterday),
      );
      expect(result, 'Hayatın zaten güzel.');
    });
  });
}
```

- [ ] **Step 2: Testi çalıştır — FAIL bekleniyor**

```bash
flutter test test/features/dashboard/domain/services/narrative_service_test.dart
```
Beklenen: `Error: cannot find 'NarrativeService'`

- [ ] **Step 3: NarrativeService oluştur**

`lib/features/dashboard/domain/services/narrative_service.dart`:
```dart
import '../entities/dashboard_metrics.dart';

class NarrativeService {
  NarrativeService._();

  static String getNarrative(DashboardMetrics metrics) {
    final now = DateTime.now();

    if (metrics.lastActivityDate == null ||
        now.difference(metrics.lastActivityDate!).inDays > 7) {
      return 'Bir süredir ortalıkta yoksun, nasılsın?';
    }

    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      metrics.lastActivityDate!.year,
      metrics.lastActivityDate!.month,
      metrics.lastActivityDate!.day,
    );
    if (lastDay == today) {
      return 'Bugün de kendinle vakit geçirdin.';
    }

    if (metrics.stabilityScore > 0.6) {
      return 'Düzenli bir ritim yakalamışsın.';
    }

    if (metrics.clarityScore > 0.7) {
      return 'Zihnin son zamanlarda oldukça aktif.';
    }

    if (metrics.totalSessions < 3) {
      return 'Henüz başlangıçtasın, devam et.';
    }

    return 'Hayatın zaten güzel.';
  }
}
```

- [ ] **Step 4: Testi çalıştır — PASS bekleniyor**

```bash
flutter test test/features/dashboard/domain/services/narrative_service_test.dart
```
Beklenen: `All tests passed`

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/domain/services/narrative_service.dart test/features/dashboard/domain/services/narrative_service_test.dart
git commit -m "feat: NarrativeService — rule-based dashboard cümlesi"
```

---

## Task 3: DashboardRepository + Isar implementasyonu

**Files:**
- Create: `lib/features/dashboard/domain/repositories/dashboard_repository.dart`
- Create: `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`
- Modify: `lib/core/database/isar_provider.dart`

- [ ] **Step 1: Abstract interface oluştur**

`lib/features/dashboard/domain/repositories/dashboard_repository.dart`:
```dart
import '../entities/dashboard_metrics.dart';

abstract interface class DashboardRepository {
  Future<DashboardMetrics> getMetrics();
}
```

- [ ] **Step 2: Isar implementasyonu oluştur**

`lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`:
```dart
import 'package:isar/isar.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/services/dashboard_calculator.dart';
import '../../../../features/session/data/models/session_entry.dart';
import '../../../../features/journal/data/models/journal_entry.dart';
import '../../../../features/brain_dump/data/models/brain_dump_entry.dart';

class IsarDashboardRepository implements DashboardRepository {
  const IsarDashboardRepository(this._isar);
  final Isar _isar;

  @override
  Future<DashboardMetrics> getMetrics() async {
    final sessions = await _isar.sessionEntrys
        .filter()
        .statusEqualTo('completed')
        .findAll();

    final journals = await _isar.journalEntrys.where().findAll();
    final brainDumps = await _isar.brainDumpEntrys.where().findAll();

    return DashboardCalculator.calculate(
      sessionDates: sessions.map((e) => e.createdAt).toList(),
      journalDates: journals.map((e) => e.createdAt).toList(),
      brainDumpDates: brainDumps.map((e) => e.createdAt).toList(),
    );
  }
}
```

- [ ] **Step 3: isar_provider.dart'a dashboardRepositoryProvider ekle**

`lib/core/database/isar_provider.dart` — dosyanın sonuna ekle (mevcut kodun ardından):
```dart
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';

// ... mevcut provider'ların sonuna ekle:

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => IsarDashboardRepository(isar),
    loading: () => throw StateError('Isar henüz hazır değil'),
    error: (e, _) => throw StateError('Isar hatası: $e'),
  );
});
```

- [ ] **Step 4: Analiz**

```bash
flutter analyze lib/features/dashboard/data/ lib/core/database/isar_provider.dart
```
Beklenen: sıfır hata

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/domain/repositories/ lib/features/dashboard/data/ lib/core/database/isar_provider.dart
git commit -m "feat: DashboardRepository — Isar implementasyonu ve provider"
```

---

## Task 4: DashboardProvider

**Files:**
- Create: `lib/features/dashboard/presentation/providers/dashboard_provider.dart`
- Create: `test/features/dashboard/presentation/providers/dashboard_provider_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/features/dashboard/presentation/providers/dashboard_provider_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dilos/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:dilos/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dilos/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dilos/core/database/isar_provider.dart';

class FakeDashboardRepository implements DashboardRepository {
  final DashboardMetrics _metrics;
  FakeDashboardRepository(this._metrics);

  @override
  Future<DashboardMetrics> getMetrics() async => _metrics;
}

void main() {
  group('dashboardMetricsProvider', () {
    test('FakeRepository verisini yükler', () async {
      final fakeMetrics = DashboardMetrics(
        clarityScore: 0.6,
        stabilityScore: 0.4,
        explorationScore: 0,
        totalSessions: 10,
        totalJournals: 5,
        totalBrainDumps: 3,
        lastActivityDate: DateTime.now(),
      );

      final container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWithValue(
          FakeDashboardRepository(fakeMetrics),
        ),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(dashboardMetricsProvider.future);
      expect(result.totalSessions, 10);
      expect(result.clarityScore, 0.6);
    });

    test('narrativeProvider doğru cümleyi döner', () async {
      final fakeMetrics = DashboardMetrics(
        clarityScore: 0.5,
        stabilityScore: 0.5,
        explorationScore: 0,
        totalSessions: 5,
        totalJournals: 0,
        totalBrainDumps: 0,
        lastActivityDate: DateTime.now(),
      );

      final container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWithValue(
          FakeDashboardRepository(fakeMetrics),
        ),
      ]);
      addTearDown(container.dispose);

      await container.read(dashboardMetricsProvider.future);
      final narrative = container.read(narrativeProvider);
      expect(narrative, 'Bugün de kendinle vakit geçirdin.');
    });
  });
}
```

- [ ] **Step 2: Testi çalıştır — FAIL bekleniyor**

```bash
flutter test test/features/dashboard/presentation/providers/dashboard_provider_test.dart
```
Beklenen: `Error: cannot find 'dashboardMetricsProvider'`

- [ ] **Step 3: DashboardProvider oluştur**

`lib/features/dashboard/presentation/providers/dashboard_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/dashboard_metrics.dart';
import '../../../domain/services/narrative_service.dart';
import '../../../../core/database/isar_provider.dart';

final dashboardMetricsProvider =
    FutureProvider.autoDispose<DashboardMetrics>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getMetrics();
});

final narrativeProvider = Provider.autoDispose<String>((ref) {
  final metricsAsync = ref.watch(dashboardMetricsProvider);
  return metricsAsync.when(
    data: NarrativeService.getNarrative,
    loading: () => '',
    error: (_, __) => 'Hayatın zaten güzel.',
  );
});
```

- [ ] **Step 4: Testi çalıştır — PASS bekleniyor**

```bash
flutter test test/features/dashboard/presentation/providers/dashboard_provider_test.dart
```
Beklenen: `All tests passed`

- [ ] **Step 5: Tüm testleri çalıştır**

```bash
flutter test test/features/dashboard/
```
Beklenen: tüm testler geçiyor

- [ ] **Step 6: Commit**

```bash
git add lib/features/dashboard/presentation/providers/ test/features/dashboard/presentation/
git commit -m "feat: dashboardMetricsProvider ve narrativeProvider"
```

---

## Task 5: Dashboard Widgets

**Files:**
- Create: `lib/features/dashboard/presentation/widgets/narrative_card.dart`
- Create: `lib/features/dashboard/presentation/widgets/metric_row.dart`
- Create: `lib/features/dashboard/presentation/widgets/activity_counts.dart`

- [ ] **Step 1: NarrativeCard oluştur**

`lib/features/dashboard/presentation/widgets/narrative_card.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class NarrativeCard extends StatelessWidget {
  const NarrativeCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.accent,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: MetricRow oluştur**

`lib/features/dashboard/presentation/widgets/metric_row.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class MetricRow extends StatelessWidget {
  const MetricRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final double value; // 0.0 to 1.0
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (value * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            color: isPlaceholder ? AppColors.onSurfaceDim : AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isPlaceholder
                    ? AppColors.onSurfaceDim
                    : AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation(
                  isPlaceholder ? AppColors.onSurfaceDim : AppColors.accent,
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 32,
            child: Text(
              isPlaceholder ? '--' : '$percentage%',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: ActivityCounts oluştur**

`lib/features/dashboard/presentation/widgets/activity_counts.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class ActivityCounts extends StatelessWidget {
  const ActivityCounts({
    super.key,
    required this.sessions,
    required this.journals,
    required this.brainDumps,
  });

  final int sessions;
  final int journals;
  final int brainDumps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _CountCell(value: sessions, label: 'Seans')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _CountCell(value: journals, label: 'Journal')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _CountCell(value: brainDumps, label: 'Dump')),
      ],
    );
  }
}

class _CountCell extends StatelessWidget {
  const _CountCell({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Analiz**

```bash
flutter analyze lib/features/dashboard/presentation/widgets/
```
Beklenen: sıfır hata

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard/presentation/widgets/
git commit -m "feat: dashboard widget'ları — NarrativeCard, MetricRow, ActivityCounts"
```

---

## Task 6: HomeScreen Refactor

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

- [ ] **Step 1: home_screen.dart'ı oku**

Mevcut dosyayı oku, import listesini ve mevcut yapıyı anla.

- [ ] **Step 2: HomeScreen'i tamamen yeniden yaz**

`lib/features/home/presentation/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/notifications/notification_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../dashboard/domain/entities/dashboard_metrics.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../dashboard/presentation/widgets/activity_counts.dart';
import '../../../dashboard/presentation/widgets/metric_row.dart';
import '../../../dashboard/presentation/widgets/narrative_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    ref.listen<bool>(notificationTappedProvider, (_, tapped) {
      if (tapped) {
        ref.read(notificationTappedProvider.notifier).state = false;
        context.go(AppRoutes.session);
      }
    });

    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final narrative = ref.watch(narrativeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('DILOS', style: theme.textTheme.displayLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceDim),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: metricsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
            child: Text('$e', style: const TextStyle(color: AppColors.error)),
          ),
          data: (metrics) => _DashboardBody(
            narrative: narrative,
            metrics: metrics,
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.narrative,
    required this.metrics,
  });

  final String narrative;
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NarrativeCard(text: narrative),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.surfaceElevated),
          const SizedBox(height: AppSpacing.md),
          MetricRow(
            icon: Icons.psychology_outlined,
            label: 'Clarity',
            value: metrics.clarityScore,
          ),
          MetricRow(
            icon: Icons.anchor_outlined,
            label: 'Stability',
            value: metrics.stabilityScore,
          ),
          MetricRow(
            icon: Icons.explore_outlined,
            label: 'Exploration',
            value: metrics.explorationScore,
            isPlaceholder: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          ActivityCounts(
            sessions: metrics.totalSessions,
            journals: metrics.totalJournals,
            brainDumps: metrics.totalBrainDumps,
          ),
          const SizedBox(height: AppSpacing.xl),
          _ActionButton(
            label: 'Seans Başlat',
            color: AppColors.primary,
            onTap: () => context.go(AppRoutes.session),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Brain Dump',
                  color: AppColors.surfaceElevated,
                  onTap: () => context.push(AppRoutes.brainDump),
                  bordered: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  label: 'Journal',
                  color: AppColors.surfaceElevated,
                  onTap: () => context.push(AppRoutes.journal),
                  bordered: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.bordered = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: bordered
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Analiz**

```bash
flutter analyze lib/features/home/
```
Beklenen: sıfır hata

- [ ] **Step 4: Tüm testleri çalıştır**

```bash
flutter test
```
Beklenen: tüm testler geçiyor

- [ ] **Step 5: Web'de test et**

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```
iPhone Safari'de `http://<windows-ip>:8080` aç.

Manuel kontrol:
- [ ] Narrative cümle görünüyor
- [ ] Clarity ve Stability progress bar'lar dolu (veri varsa)
- [ ] Exploration bar `--` gösteriyor (placeholder)
- [ ] 3 sayı kart görünüyor
- [ ] Seans Başlat çalışıyor
- [ ] Brain Dump ve Journal butonları çalışıyor

- [ ] **Step 6: Commit**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat: HomeScreen → dashboard — narrative first tasarım"
```

---

## Acceptance Criteria

- [ ] `flutter analyze` sıfır hata
- [ ] `flutter test test/features/dashboard/` — tüm testler geçiyor
- [ ] Narrative cümle doğru koşulda gösteriliyor
- [ ] Clarity ve Stability skorları hesaplanıyor
- [ ] Exploration bar sabit `--` gösteriyor
- [ ] Activity count'lar doğru sayıyı gösteriyor
- [ ] Seans Başlat, Brain Dump, Journal navigasyonu çalışıyor
