# Dashboard Design Spec
**Date:** 2026-04-28  
**Feature:** Home Screen → Dashboard (Narrative First)

---

## Problem

Home screen şu an sadece 4 buton. Kullanıcı uygulamayı açtığında hiçbir şey görmüyor — ne kadar ilerlediğini, ne durumda olduğunu bilmiyor.

## Solution

Home screen'i dashboard'a dönüştür. Kullanıcı uygulamayı açınca direkt kendi durumunu görür.

---

## Screen Layout

```
┌─────────────────────────────────┐
│  DILOS               ⚙️         │
│                                 │
│  "Son zamanlarda düzenli        │
│   yazıyorsun."                  │  ← Narrative cümlesi (rule-based)
│                                 │
│  ──────────────────────────     │
│  🧠 Clarity        ████░░  68%  │
│  ⚓ Stability      ███░░░  52%  │  ← 4 metrik satırı
│  🎲 Exploration   ░░░░░░   0%  │    (placeholder)
│                                 │
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │  12  │ │   7  │ │   3  │   │  ← Activity counts
│  │Seans │ │Journ.│ │ Dump │   │
│  └──────┘ └──────┘ └──────┘   │
│                                 │
│  [       Seans Başlat        ]  │  ← Primary CTA
│  [Brain Dump] [Journal]         │
└─────────────────────────────────┘
```

---

## Metrics

### Clarity Level (0–100)
Writing aktivitesini ölçer.

```
score = (sessions × 3 + journals × 2 + brainDumps × 1)
normalized = min(score / 50, 1.0) × 100
```

### Stability (0–100)
Düzenlilik — son 30 günde kaç farklı günde aktivite var?

```
score = activeDaysInLast30 / 30 × 100
```

### Exploration (0–100)
Placeholder — şimdilik sabit 0. Hobby Engine ve Experiment Mode gelince bağlanır.

### Activity Counts
- Toplam tamamlanan seans sayısı
- Toplam journal entry sayısı
- Toplam brain dump entry sayısı

---

## Narrative Logic (Rule-Based)

Öncelik sırası (ilk eşleşen gösterilir):

| Koşul | Cümle |
|-------|-------|
| Son 7 günde hiç aktivite yok | "Bir süredir ortalıkta yoksun, nasılsın?" |
| Bugün aktivite var | "Bugün de kendinle vakit geçirdin." |
| Stability > 60 | "Düzenli bir ritim yakalamışsın." |
| Clarity > 70 | "Zihnin son zamanlarda oldukça aktif." |
| Toplam seans < 3 | "Henüz başlangıçtasın, devam et." |
| Default | "Hayatın zaten güzel." |

---

## Architecture

### New Files

```
lib/features/dashboard/
  domain/
    entities/dashboard_metrics.dart
  data/
    repositories/dashboard_repository_impl.dart
  presentation/
    providers/dashboard_provider.dart
    widgets/narrative_card.dart
    widgets/metric_row.dart
    widgets/activity_counts.dart
```

### Modified Files

```
lib/features/home/presentation/screens/home_screen.dart  # Dashboard'a dönüşür
```

### Data Sources (read-only)
- `SessionRepository` — tamamlanan seans sayısı + son aktivite tarihleri
- `JournalRepository` — journal entry sayısı + tarihleri
- `BrainDumpRepository` — brain dump sayısı + tarihleri

---

## What's NOT Built

- Exploration metriği gerçek verisi (Hobby/Experiment sistemi yok)
- Stability için seans dışı aktivite günleri (journal + brain dump günleri de sayılabilir — V2)
- Tıklanabilir metrik detay sayfaları
- Zaman aralığı filtresi

---

## Acceptance Criteria

- [ ] Home screen açılınca dashboard görünüyor
- [ ] Narrative cümle doğru koşulda gösteriliyor
- [ ] Clarity ve Stability progress bar'lar hesaplanıyor
- [ ] Exploration bar sabit 0 gösteriyor
- [ ] 3 activity count doğru sayıyı gösteriyor
- [ ] Seans Başlat, Brain Dump, Journal butonları çalışıyor
- [ ] `flutter analyze` sıfır hata
- [ ] Dashboard provider unit test var
