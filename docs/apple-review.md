# Чеклист App Review

## Блокеры перед отправкой

- [ ] Убран вечный Premium (`Apphud.hasActiveSubscription()` без `true ||`) — уже в коде
- [x] Живые Terms / Privacy / support в `PaywallConstants`: `https://safeguard-adblock.app/TermsConditions.html`, `https://safeguard-adblock.app/PrivacyPolicy.html`, `support@safeguard-adblock.app`
- [x] Боевые ключи AppsFlyer, AppMetrica, AdMob в `SDKConfig` / `AdMobConfig` / Info.plist
- [x] Trial на weekly берётся из introductory offer StoreKit. Срок и цена не зашиты в текст
- [ ] Restore: launch paywall, «Already Purchase?» на premium, Settings

## Guideline 3.1.2

Premium-пейволл: название продукта из Apphud, цена и период из StoreKit, trial из introductory offer, кнопка Continue. Launch: та же цена и trial над START.

## Guideline 2.1 / 2.3

В Review Notes: защита Safari работает только после включения расширения AdBlocker Pro в Settings → Apps → Safari → Extensions. Реклама AdMob показывается только внутри приложения, не в Safari.

## Guideline 5.1.1

ATT запрашивается после предпоследнего экрана онбординга. Если пользователь нажал Skip до ATT, запрос идёт на экране подготовки. Форма Google Ads (UMP) — только после закрытия первого launch-пейволла. Строка ATT: `NSUserTrackingUsageDescription` (локализована, текст не менять).

## Guideline 5.1.2

Privacy Policy обязательна и должна описывать AppsFlyer, AppMetrica, AdMob, Apphud, Face ID.

## Прочее

- `PrivacyInfo.xcprivacy` в таргете
- Nutrition Labels в ASC
- Нет аккаунта → account deletion не нужен
- Password vault — premium; генератор и скан сети — free
- `tracker_rules.json` блокирует трекеры в Safari, не in-app SDK
