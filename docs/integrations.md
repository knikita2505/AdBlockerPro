# Интеграции SDK

Порядок init (`AdBlocker_ProApp`):

1. `Apphud.start(apiKey:)`
2. `AppsFlyerService.configure()` — `customerUserID = Apphud.userID()`, ATT wait 60s, conversion → `Apphud.setAttribution(.appsFlyer)`
3. `AppMetricaService.activate()` — `userProfileID = Apphud.userID()`, device_id → `Apphud.setAttribution(.custom)`

После ATT: `Apphud.setDeviceIdentifiers(idfa:idfv:)`.

UMP (`ConsentService`) → `MobileAds.start` + `RewardedAdService.preload`, только если `canRequestAds` и не premium.

## События рекламы

`RewardedAdService.show()` из `AdPresentationService`:

- скан сети завершён
- Generate пароля (не чаще одного раза за сессию)
- dismiss пейволла, если нет подписки

AppMetrica: только activate + связка с Apphud (без ad revenue и кастомных событий).
