# AdBlocker Pro — Инструкция по настройке

## 1. Добавление Safari Content Blocker Extension в Xcode

Cursor не может создать extension target — это нужно сделать вручную:

### Шаги:

1. Открой проект в **Xcode**
2. **File → New → Target...**
3. Выбери **Content Blocker Extension**
4. Назови: `ContentBlockerExtension`
5. Bundle Identifier: `nikita.ka.AdBlocker-Pro.ContentBlocker`
6. Language: Swift
7. **Finish**

### После создания:

8. **Удали** автоматически созданный `blockerList.json` из extension target
9. **Удали** автоматически созданный `ContentBlockerRequestHandler.swift` из extension target
10. **Подключи** файл `ContentBlockerExtension/ContentBlockerRequestHandler.swift` из проекта к extension target

## 2. Настройка App Groups

### Для обоих таргетов (AdBlocker Pro и ContentBlockerExtension):

1. Выбери таргет в **Signing & Capabilities**
2. Нажми **+ Capability**
3. Добавь **App Groups**
4. Создай группу: `group.nikita.ka.AdBlocker-Pro`
5. Убедись, что группа включена для **обоих** таргетов

## 3. Добавление ApphudSDK через SPM

1. **File → Add Package Dependencies...**
2. URL: `https://github.com/apphud/ApphudSDK`
3. Version: **Up to Next Major** (минимум 4.0.2)
4. Добавь к таргету **AdBlocker Pro**

## 4. Настройка API ключей

### Apphud:
Открой `AdBlocker_ProApp.swift` и замени `YOUR_APPHUD_API_KEY` на свой ключ из Apphud Dashboard.

### Подписки:
Открой `PaywallView.swift` и замени product IDs в `PaywallConstants`:
- `adblocker.premium.week1` — недельная подписка
- `adblocker.premium.year1` — годовая подписка

### Ссылки:
Замени URLs в `PaywallConstants`:
- `termsURL` — ссылка на Terms of Use
- `privacyURL` — ссылка на Privacy Policy

## 5. Настройка Info.plist

Добавь ключ `NSFaceIDUsageDescription` в Info.plist (через Build Settings → Info):
```
NSFaceIDUsageDescription: "AdBlocker Pro uses Face ID to protect your saved passwords"
```

## 6. Локализация

Проект поддерживает: EN (базовый), ES, DE, FR, JA.

В настройках проекта:
1. **Project → Info → Localizations**
2. Добавь: Spanish, German, French, Japanese
3. `Localizable.xcstrings` уже содержит переводы

## 7. Apphud Dashboard

Создай в Apphud:
1. **Products**: `adblocker.premium.week1`, `adblocker.premium.year1`
2. **Paywalls**: настрой paywall с этими products
3. **Placements**: `onboarding`, `premium_feature`

## 8. App Store Connect

1. Создай подписки в App Store Connect с теми же product IDs
2. Настрой Trial period для weekly если нужно
3. Заполни описания подписок
