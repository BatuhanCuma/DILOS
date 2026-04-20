# DILOS — Digital Intelligence Life Operating System (MVP)

## Problem Statement

Burnout, yalnızlık ve anhedoni yaşayan insanlar kendilerini tanımak ve hayatlarıyla yeniden bağ kurmak istiyorlar ancak disiplin gerektiren araçları (journal uygulamaları, meditasyon, alışkanlık takipçileri) sürdüremiyorlar. Mevcut uygulamalar "sen başla, biz cevap veririz" modeline dayanıyor — kullanıcı zaten ne yapacağını bilmediği için bunlar işe yaramıyor.

## Evidence

- Proje sahibinin kendi deneyimi: burnout, yalnızlık, hayattan zevk alamama
- Hedef kitle şu an YouTube izleyerek vakit geçiriyor — ne yapacağını bilmiyor, bir şeyler deniyor ama sürdüremiyor
- Rosebud $6M seed aldı (2025) — AI journaling pazarının gerçek olduğunu kanıtlıyor
- App Store'da "AI journal" etiketli uygulama sayısı: Ocak 2024'te 12, Mart 2026'da 40+

## Proposed Solution

Kullanıcı uygulamayı açtığında sistem otomatik kısa bir seans başlatır (2–5 dk). Kullanıcı düşünmez, sadece akışa girer. Ses veya yazıyla cevaplar. AI arka planda kategorize eder, pattern bulur — ama bunu kullanıcıya göstermez, sadece sessizce yönlendirir.

## Key Hypothesis

DILOS kullanan bir kullanıcının haftalık düzenli seans yapması, uygulamanın gerçek bir zihinsel destek sağladığını kanıtlar.
Bunu bileceğiz: **Kullanıcı 7 gün içinde en az 3 seans tamamladıysa başarılı.**

## What We're NOT Building

- Sosyal özellikler (paylaşım, arkadaş sistemi) — core değil, distraksiyon
- Gamification (streak, rozet, puan) — bağımlılık değil bağ istiyoruz
- Monetizasyon / premium katman — MVP çıksın, sonra bakılır
- Karmaşık dashboard — V1'de basit tutuyoruz

## Success Metrics

| Metrik | Hedef | Nasıl Ölçülür |
|--------|-------|---------------|
| 7 günde 3+ seans tamamlama | %40 kullanıcı | Seans kayıtları |
| Seans tamamlama oranı | %70 başlayan bitirir | Seans start/end events |
| D7 retention | %30 | Aktif kullanıcı sayısı |

## Open Questions

- [ ] Bildirim zamanlaması kullanıcı mı seçsin, sistem mi öğrensin?
- [ ] İlk seans onboarding'de mi yapılsın, yoksa kullanıcı "hazırım" deyince mi?
- [ ] Ses transkripsiyonu on-device mi (gizlilik) yoksa cloud mi (doğruluk)?

---

## Users & Context

**Primary User**
- **Kim**: 18–30 yaş, burnout/yalnızlık hisseden, dijital tükenmişlik yaşayan
- **Şu an ne yapıyor**: YouTube izliyor, ne yapacağını bilmiyor, birşeyler deniyor ama bırakıyor
- **Tetikleyici**: Kötü hissedince veya rutin bildirimle
- **Başarı hali**: Haftalık seans yapıyor, yeni şeyler denemek istiyor

**Job to Be Done**
Kendimi kötü hissedip ne yapacağımı bilmediğimde, beni yönlendirecek ve dinleyecek bir sistem istiyorum, böylece hayatımla yeniden bağ kurabilirim.

**Non-Users**
- Terapist arayan klinisyenler — bu bir terapi uygulaması değil
- Productivity maximizer tipler — bu bir GTD/task manager değil
- Sosyal paylaşım isteyen içerik üreticiler

---

## Solution Detail

### Core Capabilities (MoSCoW)

| Öncelik | Özellik | Gerekçe |
|---------|---------|---------|
| Must | Auto Session System | Uygulamanın kalbi — kullanıcı düşünmeden başlar |
| Must | Brain Dump (ses + yazı) | Zihin temizliği, friction sıfır |
| Must | Journal (gratitude/reflection) | Pozitif bakış açısı |
| Must | Bildirim (rutin tetikleyici) | Alışkanlık oluşturmanın anahtarı |
| Should | Thought Catalog | Kendini tanıma patternleri |
| Should | Temel AI tagging | Arka planda kategorileme |
| Could | Life Log | Deneyimleri kayıt altına alma |
| Could | Anchor System | Bozulma pattern tespiti |
| Won't | Sosyal özellikler | V1 dışı |
| Won't | Gamification | V1 dışı |
| Won't | Monetizasyon | V1 dışı |

### MVP Scope

Auto Session + Brain Dump + Journal + Bildirim. Bu dört şey çalışıyorsa hipotezi test edebiliriz.

### User Flow (kritik yol)

```
Bildirim gelir
  → Kullanıcı açar
  → Sistem otomatik seans başlatır
  → "Bugün kafanda ne var?" (ses veya yazı)
  → 2-3 soru daha (akışa göre)
  → Seans tamamlandı
  → AI sessizce kategorize eder
```

---

## Technical Approach

**Fizibilite**: YÜKSEK

**Stack (tamamen ücretsiz MVP)**
| Katman | Teknoloji |
|--------|-----------|
| Mobil | Flutter (iOS + Android) |
| Ses → Metin | `speech_to_text` (on-device, ücretsiz) |
| AI analiz | Gemini Flash API (ücretsiz tier) |
| Yerel depolama | Isar veya Hive |
| Backend/sync | Supabase free tier |
| Bildirimler | `flutter_local_notifications` |

**Mimari Notlar**
- Offline-first: tüm veriler önce lokalda, sonra sync
- AI katmanı görünmez olmalı — kullanıcı prompt görmez, sadece sonuç hisseder
- Ses transkripsiyonu V1'de on-device (gizlilik + maliyet)

**Teknik Riskler**

| Risk | Olasılık | Çözüm |
|------|----------|-------|
| Gemini free tier limitleri | Düşük (MVP trafiğinde) | Groq fallback |
| Ses kalitesi / transkripsyon hataları | Orta | Yazı alternatifi her zaman açık |
| Auto session flow'u sıkıcı hale gelmesi | Orta | Soru havuzu + rotasyon |

---

## Implementation Phases

| # | Faz | Açıklama | Durum | Paralel | Bağımlı |
|---|-----|----------|-------|---------|---------|
| 1 | Foundation | Flutter proje kurulumu, navigasyon, Isar, temel UI sistemi | complete | - | - | `.claude/PRPs/plans/completed/phase-1-foundation.plan.md` |
| 2 | Session Engine | Auto Session akışı, soru sistemi, ses+yazı input | complete | - | 1 | `.claude/PRPs/plans/completed/phase-2-session-engine.plan.md` |
| 3 | Writing System | Brain Dump, Journal ekranları | complete | 3 ile | 2 | `.claude/PRPs/plans/completed/phase-3-writing-system.plan.md` |
| 4 | AI Layer | Gemini entegrasyonu, sessiz tagging | complete | 3 ile | 2 | `.claude/PRPs/plans/completed/phase-4-ai-layer.plan.md` |
| 5 | Notifications | Rutin bildirim, tetikleyici sistem | complete | - | 3, 4 | `.claude/PRPs/plans/completed/phase-5-notifications.plan.md` |
| 6 | Polish & Test | UX iyileştirme, edge case, beta test | complete | - | 5 | `.claude/PRPs/plans/completed/phase-6-polish-and-test.plan.md` |

### Faz Detayları

**Faz 1: Foundation**
- Flutter clean architecture kurulumu (feature-first klasör yapısı)
- Routing (go_router)
- Isar local DB kurulumu
- Temel design system (renkler, tipografi, spacing)
- **Tamamlanma sinyali**: Boş app çalışıyor, DB okuma/yazma testi geçiyor

**Faz 2: Session Engine**
- Auto Session state machine
- Soru havuzu sistemi (JSON tabanlı)
- Ses input (`speech_to_text`) + yazı fallback
- Seans tamamlama/kaydetme
- **Tamamlanma sinyali**: Kullanıcı seansı baştan sona tamamlayabiliyor

**Faz 3: Writing System**
- Brain Dump ekranı (friction sıfır, hızlı açılış)
- Journal ekranı (gratitude + reflection prompts)
- **Tamamlanma sinyali**: İki ekran da veri kaydedip listeleyebiliyor

**Faz 4: AI Layer**
- Gemini Flash API entegrasyonu
- Seans cevaplarını arka planda tagging
- Kategoriler: mood, topic, energy level
- **Tamamlanma sinyali**: Bir seans sonrası tag'ler DB'ye yazılıyor

**Faz 5: Notifications**
- Kullanıcı bildirim zamanı seçiyor
- Günlük rutin bildirim
- "Acil seans" shortcut (widget veya bildirim aksiyonu)
- **Tamamlanma sinyali**: Bildirime tıklayınca direkt seans başlıyor

**Faz 6: Polish & Test**
- Onboarding akışı
- Empty state'ler
- Hata mesajları
- Beta kullanıcı testi (küçük grup)

### Paralellik Notları

Faz 3 ve 4 bağımsız — AI entegrasyonu Writing System bitmeden paralel geliştirilebilir.

---

## Decisions Log

| Karar | Seçim | Alternatifler | Gerekçe |
|-------|-------|---------------|---------|
| AI servisi | Gemini Flash | GPT-4o, Claude | Ücretsiz tier + Flutter AI Toolkit entegrasyonu |
| Ses transkripsiyonu | On-device | Whisper/Groq | Gizlilik + sıfır maliyet |
| Local DB | Isar | Hive, SQLite | Flutter-native, hızlı, tip güvenli |
| Backend | Supabase | Firebase | Generous free tier, open source |
| Sosyal özellik | V1 dışı | - | Core'a odaklan |

---

## Research Summary

**Pazar Durumu**
- AI journaling pazarı hızla büyüyor (40+ uygulama, Rosebud $6M seed)
- Mevcut uygulamaların tamamı "reactive" — kullanıcı başlatır, AI cevaplar
- DILOS'un "proactive session" yaklaşımı pazarda yok

**Teknik Durum**
- Flutter AI Toolkit Gemini'yi native destekliyor
- `speech_to_text` paketi production-ready, on-device çalışıyor
- Ücretsiz stack MVP için fazlasıyla yeterli

---

*Oluşturulma: 2026-04-18*
*Durum: DRAFT — validasyon gerekiyor*
