# Чеклист App Review

## Блокеры перед отправкой

- [ ] Убран вечный Premium (`Apphud.hasActiveSubscription()` без `true ||`) — уже в коде
- [ ] Живые Terms / Privacy / support в `PaywallConstants` (сейчас заглушки `adblockerpro.app`)
- [ ] Боевые ключи AppsFlyer, AppMetrica, AdMob в `SDKConfig` / `AdMobConfig` / Info.plist
- [ ] Trial 3 дня на weekly совпадает с App Store Connect и текстом «First 3d free» / таймлайном premium-пейволла
- [ ] Restore: launch paywall, «Already Purchase?» на premium, Settings

## Guideline 3.1.2

Premium-пейволл: цена, Weekly/Annual, Today / One day before / In 3 days (списание, cancel anytime). Launch: цена/trial над START.

## Guideline 2.1 / 2.3

В Review Notes: защита Safari работает только после включения расширения AdBlocker Pro в Settings → Apps → Safari → Extensions. Реклама AdMob показывается только внутри приложения, не в Safari.

## Guideline 5.1.1

ATT запрашивается после онбординга и до рекламы/IDFA. Строка: `NSUserTrackingUsageDescription` (локализована).

## Guideline 5.1.2

Privacy Policy обязательна и должна описывать AppsFlyer, AppMetrica, AdMob, Apphud, Face ID.

## Прочее

- `PrivacyInfo.xcprivacy` в таргете
- Nutrition Labels в ASC
- Нет аккаунта → account deletion не нужен
- Password vault — premium; генератор и скан сети — free
- `tracker_rules.json` блокирует трекеры в Safari, не in-app SDK
