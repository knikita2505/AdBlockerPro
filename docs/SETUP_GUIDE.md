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

- `PaywallConstants.termsURL` — `https://safeguard-adblock.app/TermsConditions.html`
- `PaywallConstants.privacyURL` — `https://safeguard-adblock.app/PrivacyPolicy.html`
- `PaywallConstants.supportEmail` — `support@safeguard-adblock.app`
- Product IDs: `safeguard_premium_week`, `safeguard_premium_year`
- Interstitial всегда боевой unit ID, и в Debug, и в Release

## 4. Apphud Dashboard

1. Products: `safeguard_premium_week`, `safeguard_premium_year`
2. Paywalls: `safeguard_launch`, `safeguard_premium_features`
3. Placements с теми же идентификаторами: `safeguard_launch` (launch paywall), `safeguard_premium_features` (premium paywall)

## 5. Запуск

Первый запуск без подписки: онбординг. ATT — после предпоследнего экрана. Get Started открывает экран «Preparing the blocker» в стиле launch paywall: короткая анимация, пока `PaywallViewModel.preload()` забирает цену и trial из StoreKit. Затем галочка и тот же экран переходит в `PaywallView`. Следующие холодные старты без подписки: сразу пейволл, без экрана подготовки. С подпиской пейволл не показывается.

Онбординг показывается один раз. Премиум-функции (щит, фильтры, сохранённые пароли, плашка PRO) открывают `PremiumPaywallView`.

Инструкция Safari — один раз и только если content blocker выключен.

## 6. Реклама

Interstitial AdMob после: скана сети, каждого Generate и dismiss пейволла. Форма UMP запрашивается только после закрытия первого (launch) пейволла, внутри `InterstitialAdService.show()`. Premium — без рекламы.

## 7. Локализация

EN / ES / JA / pt-BR. UI: `Localizable.xcstrings`. Face ID и ATT: `InfoPlist.xcstrings`.

## 8. App Store Connect

1. Подписки с теми же product IDs. Trial и цена на пейволле берутся из StoreKit, не из текста в приложении.
2. Privacy Nutrition Labels по `PrivacyInfo.xcprivacy`
3. Review Notes: блокировка только в Safari после включения content blocker; реклама только внутри приложения
