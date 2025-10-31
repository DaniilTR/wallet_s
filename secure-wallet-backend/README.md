# Secure Wallet Backend (MongoDB)

Проект переведён с PostgreSQL/JPA на MongoDB с использованием Spring Data MongoDB.

## Подключение к БД
- URI настраивается в `src/main/resources/application.yml`
- Текущее значение:
  ```
  spring:
    data:
      mongodb:
        uri: mongodb://secure:wallet_1945@localhost:27017/secure_wallet?authSource=secure_wallet
  ```

## JWT
- В `subject` токена теперь кладётся `userId`.
- Это позволяет контроллерам продолжать использовать `Authentication.getName()` как идентификатор пользователя.
- Для обратной совместимости аутентификация поддерживает и старые токены, где в subject был `email`.

## Сборка и запуск
```powershell
# Сборка
mvn -f d:\Wallet\App\secure-wallet-backend\pom.xml -DskipTests package

# Запуск
mvn -f d:\Wallet\App\secure-wallet-backend\pom.xml spring-boot:run
```

## Примечания
- Сущности переведены на `@Document`/`@DBRef`.
- Репозитории переведены на `MongoRepository`.
- Если нужно перейти на хранение только идентификаторов вместо `@DBRef`, это можно сделать отдельно.
