# Интеграции SDK

Порядок init (`AdBlocker_ProApp`):

1. `Apphud.start(apiKey:)`
2. `AppsFlyerService.configure()` — `customerUserID = Apphud.userID()`, ATT wait 60s, conversion → `Apphud.setAttribution(.appsFlyer)`
3. `AppMetricaService.activate()` — `userProfileID = Apphud.userID()`, device_id → `Apphud.setAttribution(.custom)`

После ATT: `Apphud.setDeviceIdentifiers(idfa:idfv:)`.

UMP (`ConsentService`) запрашивается после закрытия первого launch-пейволла, затем `MobileAds.start` + `InterstitialAdService.preload`, только если `canRequestAds` и не premium.

## События рекламы

`InterstitialAdService.show()` из `AdPresentationService`:

- скан сети завершён
- каждый Generate пароля
- dismiss пейволла, если нет подписки

AppMetrica: только activate + связка с Apphud (без ad revenue и кастомных событий).

## Подписки

Плейсмент и пейволл с одним идентификатором:

- `safeguard_launch` — пейволл при запуске, продукт `safeguard_premium_week`
- `safeguard_premium_features` — премиум-пейволл, продукты `safeguard_premium_week` и `safeguard_premium_year`

`PaywallViewModel` берёт пейволл из `Apphud.fetchPlacements`, имена — из продукта Apphud, цену и trial — из StoreKit.
