# Гайд по фронтенду (папка `lib/`)

Этот файл помогает быстро понять, где лежат основные части приложения, как устроена навигация, где менять цвета/стили, и куда смотреть, если нужно править конкретный экран, виджет или сетевую логику.

## Структура

- `main.dart` — точка входа. Подключает тему (`AppTheme`) и стартовый виджет `AuthChecker`.
- `config/`
  - `theme.dart` — ГЛАВНОЕ место для цветов и темы. Здесь меняется основной цвет, кнопки, текста, фона и пр.
  - `bsc_config.dart` — конфигурация BSC Testnet (RPC, chainId, адрес токена, ABI).
- `models/` — простые модели данных:
  - `auth.dart` — пользователь и ответ аутентификации.
  - `wallet.dart` — кошелёк и удобные энумы по валютам.
  - `transaction.dart` — транзакция (отправлено/получено, сумма, адрес, статус, дата).
- `screens/` — экраны приложения:
  - `auth_screen.dart` — логин/регистрация.
  - `home_screen.dart` — главный экран (баланс, кошельки, последние транзакции).
  - `wallet_detail_screen.dart` — экран одного кошелька (баланс, адрес, список транзакций).
  - `send_screen.dart` — форма отправки.
- `services/` — работа с сетью/бэкендом:
  - `auth_service.dart` — аутентификация (login/register/logout).
  - `wallet_service.dart` — загрузка кошельков/транзакций, создание кошелька, отправка транзакций через бэкенд.
  - `bsc_service.dart` — работа с BSC Testnet и локальным EVM-кошельком (web3dart, хранение ключа в secure storage).
- `widgets/` — переиспользуемые элементы UI:
  - `auth_checker.dart` — выбирает между `HomeScreen` и `AuthScreen`.
  - `wallet_card.dart` — карточка кошелька в списке.
  - `transaction_tile.dart` — строка транзакции.

## Где менять цвета и стиль

99% случаев — файл `config/theme.dart` (класс `AppTheme`).

- Основные цвета:
  - `AppTheme.primary` — главный цвет бренда (кнопки, акценты).
  - `AppTheme.secondary`, `warning`, `danger`, `success` — вторичные и статусные цвета.
- Светлая/тёмная тема: `AppTheme.lightTheme` и `AppTheme.darkTheme` — здесь задаются фон, AppBar, Card, кнопки, текст.

Если на экране всё ещё есть «жёстко» заданный цвет (например, был `Color(0xFF...)`) — я заменил такие места на `AppTheme.primary`. Теперь достаточно поменять один цвет в `theme.dart`, чтобы обновились кнопки/акценты по всему приложению.

Примеры того, что теперь тянется из темы:
- Цвет кнопок и выделений в:
  - `screens/auth_screen.dart`
  - `screens/home_screen.dart` (кнопки Add/Send)
  - `screens/send_screen.dart` (бордер/заливка выбранного кошелька, кнопка Send, «Max»)
  - `screens/wallet_detail_screen.dart` (иконки действий)
  - `widgets/transaction_tile.dart` (статусы: success/warning/danger)
  - `services/wallet_service.dart` (цвет по умолчанию для «не BNB»)

## Быстрые рецепты

- Поменять основной цвет всего приложения:
  - Открыть `config/theme.dart` → заменить `AppTheme.primary` на нужный.
- Поменять фон (светлая тема):
  - `scaffoldBackgroundColor` в `AppTheme.lightTheme`.
- Поменять фон (тёмная тема):
  - `scaffoldBackgroundColor` в `AppTheme.darkTheme`.
- Поменять стиль AppBar:
  - `appBarTheme` внутри соответствующей темы.
- Поменять стиль всех ElevatedButton:
  - `elevatedButtonTheme` внутри темы.
- Цвета статусов транзакций:
  - `widgets/transaction_tile.dart` → использует `AppTheme.success/warning/danger`.
- Градиенты карточек кошельков:
  - `widgets/wallet_card.dart` → берут `wallet.color` (цвет зависит от валюты/кошелька).

## Навигация

- Старт в `main.dart` → `AuthChecker`.
- Если пользователь залогинен → `HomeScreen`, иначе → `AuthScreen`.
- Из `HomeScreen` можно перейти:
  - в `SendScreen` (кнопка Send),
  - в `WalletDetailScreen` (тап по кошельку).

## Где логика данных

- Бэкенд (HTTP): `AuthService` и `WalletService`.
- BSC Testnet и локальный кошелёк (web3): `BscService`.
- Все ключи EVM сохраняются только локально в `flutter_secure_storage`.

## Советы по правкам

- Ищите по проекту `AppTheme.primary` — так найдёте все акценты.
- Для единообразия старайтесь не использовать «жёстко» заданные `Color(0xFF...)` в экранах — лучше брать из `AppTheme`.
- Чтобы править отдельный экран, откройте соответствующий файл в `screens/` — там добавлены понятные комментарии по блокам UI.

---
Если что-то ещё хочется упростить или централизовать — напишите, добавлю хелперы/стили или вынесу повторяющиеся куски в виджеты.
