import 'package:flutter/material.dart';

// Модель данных для кошелька
class Wallet {
  final String id; // Уникальный идентификатор
  final String name; // Название кошелька
  final String currency; // Валюта
  final String symbol; // Символ валюты
  final double balance; // Баланс
  final String address; // Адрес кошелька
  final String iconUrl; // URL иконки
  final Color color; // Цвет для отображения

  // Конструктор
  Wallet({
    required this.id,
    required this.name,
    required this.currency,
    required this.symbol,
    required this.balance,
    required this.address,
    required this.iconUrl,
    required this.color,
  });

  // Фабричный метод для создания экземпляра из JSON
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      currency: json['currency'],
      symbol: json['symbol'],
      balance: (json['balance'] as num).toDouble(),
      address: json['address'],
      iconUrl: json['iconUrl'],
      color: Color(json['color']),
    );
  }
}

// Перечисление типов валют
enum CurrencyType { btc, eth, usdt, usdc }

// Расширение для CurrencyType
extension CurrencyTypeExtension on CurrencyType {
  // Получение символа валюты
  String get symbol {
    switch (this) {
      case CurrencyType.btc:
        return 'BTC';
      case CurrencyType.eth:
        return 'ETH';
      case CurrencyType.usdt:
        return 'USDT';
      case CurrencyType.usdc:
        return 'USDC';
    }
  }

  // Получение полного названия валюты
  String get fullName {
    switch (this) {
      case CurrencyType.btc:
        return 'Bitcoin';
      case CurrencyType.eth:
        return 'Ethereum';
      case CurrencyType.usdt:
        return 'Tether';
      case CurrencyType.usdc:
        return 'USD Coin';
    }
  }

  // Получение цвета для валюты
  Color get color {
    switch (this) {
      case CurrencyType.btc:
        return const Color(0xFFF7931A);
      case CurrencyType.eth:
        return const Color(0xFF627EEA);
      case CurrencyType.usdt:
        return const Color(0xFF26A17B);
      case CurrencyType.usdc:
        return const Color(0xFF2775CA);
    }
  }
}
