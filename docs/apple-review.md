# Чеклист App Review

## Блокеры перед отправкой

- [ ] Убран вечный Premium (`Apphud.hasActiveSubscription()` без `true ||`) — уже в коде
- [ ] Живые Terms / Privacy / support в `PaywallConstants` (сейчас заглушки `adblockerpro.app`)
- [x] Боевые ключи AppsFlyer, AppMetrica, AdMob в `SDKConfig` / `AdMobConfig` / Info.plist
- [ ] Trial на weekly совпадает с introductory offer в App Store Connect. На пейволле срок и цена берутся из Apphud / StoreKit, не зашиты в текст
- [ ] Restore: launch paywall, «Already Purchase?» на premium, Settings

## Guideline 3.1.2

Premium-пейволл: название продукта из Apphud, цена и период из StoreKit, trial из introductory offer, кнопка Continue. Launch: та же цена и trial над START.

## Guideline 2.1 / 2.3

В Review Notes: защита Safari работает только после включения расширения AdBlocker Pro в Settings → Apps → Safari → Extensions. Реклама AdMob показывается только внутри приложения, не в Safari.

## Guideline 5.1.1

ATT запрашивается на экране настройки при запуске, до рекламы и IDFA. Строка: `NSUserTrackingUsageDescription` (локализована).

## Guideline 5.1.2

Privacy Policy обязательна и должна описывать AppsFlyer, AppMetrica, AdMob, Apphud, Face ID.

## Прочее

- `PrivacyInfo.xcprivacy` в таргете
- Nutrition Labels в ASC
- Нет аккаунта → account deletion не нужен
- Password vault — premium; генератор и скан сети — free
- `tracker_rules.json` блокирует трекеры в Safari, не in-app SDK
