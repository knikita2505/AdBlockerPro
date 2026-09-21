# AdBlocker Pro — Инструкция по настройке

## 1. Safari Content Blocker

Таргет `ContentBlockerExtension`, bundle `nikita.ka.AdBlocker-Pro.ContentBlockerExtension`, App Group `group.nikita.ka.AdBlocker-Pro`. Display name расширения: **AdBlocker Pro**.

## 2. SDK (SPM)

Уже добавлены в проект:

| SDK | URL | Product |
|-----|-----|---------|
| Apphud | https://github.com/apphud/ApphudSDK | ApphudSDK |
| AppsFlyer | https://github.com/AppsFlyerSDK/AppsFlyerFramework-Dynamic | AppsFlyerLib-Dynamic |
| AdMob | https://github.com/googleads/swift-package-manager-google-mobile-ads.git | GoogleMobileAds |
| AppMetrica | https://github.com/appmetrica/appmetrica-sdk-ios | AppMetricaCore, AppMetricaAnalytics, AppMetricaAdSupport |

Порядок старта в `AdBlocker_ProApp.init`: **Apphud → AppsFlyer.configure → AppMetrica.activate**.

## 3. Ключи — `SDKConfig.swift` и `PaywallConstants`

Перед релизом замени плейсхолдеры:

- `SDKConfig.appsFlyerDevKey`, `appsFlyerAppleAppID` (без префикса `id`)
- `SDKConfig.appMetricaAPIKey`
- `AdMobConfig.applicationID` и `productionRewardedAdUnitID` (сейчас Google test IDs)
- `GADApplicationIdentifier` в `AdBlocker Pro/Info.plist` — тот же AdMob App ID
- `PaywallConstants.termsURL`, `privacyURL`, `supportEmail` — живые страницы, не заглушки
- Product IDs: `adblocker.premium.week1`, `adblocker.premium.year1`

Пока ключи-плейсхолдеры, AppsFlyer и AppMetrica **не стартуют** (чтобы не падать).

## 4. Apphud Dashboard

1. Products: `adblocker.premium.week1`, `adblocker.premium.year1`
2. Paywalls с этими products
3. Placements: `onboarding` (launch paywall), `premium_feature` (premium paywall)

## 5. Первый запуск

Онбординг → ATT → UMP (если нужно) → launch paywall (`PaywallView`) → rewarded (если не premium) → инструкция Safari.

Повторно launch paywall не показывается. Премиум-функции открывают `PremiumPaywallView`.

## 6. Реклама

Rewarded AdMob после: скана сети, Generate (1 раз за сессию), dismiss любого пейволла. Premium — без рекламы.

## 7. Локализация

EN / ES / JA / pt-BR. UI: `Localizable.xcstrings`. Face ID и ATT: `InfoPlist.xcstrings`.

## 8. App Store Connect

1. Подписки с теми же product IDs, trial weekly 3 дня — как на пейволле
2. Privacy Nutrition Labels по `PrivacyInfo.xcprivacy`
3. Review Notes: блокировка только в Safari после включения content blocker; реклама только внутри приложения
