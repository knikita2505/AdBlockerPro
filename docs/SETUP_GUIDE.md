# AdBlocker Pro — Инструкция по настройке

## 1. Safari Content Blocker

Таргет `ContentBlockerExtension`, bundle `nikita.ka.AdBlocker-Pro.ContentBlockerExtension`, App Group `group.nikita.ka.AdBlocker-Pro.ContentBlockerExt`. Display name расширения: **AdBlocker Pro**.

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

Ключи SDK и AdMob App ID заданы в `SDKConfig.swift` / `AdMobConfig` и `Info.plist`.

Перед релизом проверь:

- `PaywallConstants.termsURL`, `privacyURL`, `supportEmail` — живые страницы, не заглушки
- Product IDs: `safeguard_premium_week`, `safeguard_premium_year`
- Interstitial всегда боевой unit ID, и в Debug, и в Release

## 4. Apphud Dashboard

1. Products: `safeguard_premium_week`, `safeguard_premium_year`
2. Paywalls: `safeguard_launch`, `safeguard_premium_features`
3. Placements с теми же идентификаторами: `safeguard_launch` (launch paywall), `safeguard_premium_features` (premium paywall)

## 5. Запуск

Каждый холодный старт без подписки: анимация настройки → ATT (если ещё не решён) → UMP → launch paywall (`PaywallView`). С подпиской анимация и пейволл не показываются.

Онбординга нет. Премиум-функции (щит, фильтры, вкладка Passwords, плашка PRO) открывают `PremiumPaywallView`.

Инструкция Safari — один раз и только если content blocker выключен.

## 6. Реклама

Interstitial AdMob после: скана сети, каждого Generate и dismiss пейволла. Premium — без рекламы.

## 7. Локализация

EN / ES / JA / pt-BR. UI: `Localizable.xcstrings`. Face ID и ATT: `InfoPlist.xcstrings`.

## 8. App Store Connect

1. Подписки с теми же product IDs, trial weekly 3 дня — как на пейволле
2. Privacy Nutrition Labels по `PrivacyInfo.xcprivacy`
3. Review Notes: блокировка только в Safari после включения content blocker; реклама только внутри приложения
