import 'package:flutter/material.dart';

// lib/models/wallet.dart
class Wallet {
  final String id;
  final String name;
  final String currency;
  final String symbol;
  final double balance;
  final String address;
  final String iconUrl; // UI-атрибут: может вычисляться из symbol
  final Color color; // UI-атрибут: может вычисляться из symbol

  Wallet({
    required this.id,
    required this.name,
    required this.currency,
    required this.symbol,
    required this.balance,
    required this.address,
    String? iconUrl,
    Color? color,
  })  : iconUrl = iconUrl ?? _iconForSymbol(symbol),
        color = color ?? _colorForSymbol(symbol);

  // Универсальный парсер (ожидает все поля, включая UI, если они есть)
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      currency: json['currency'],
      symbol: json['symbol'],
      balance: (json['balance'] as num).toDouble(),
      address: json['address'],
      iconUrl: json['iconUrl'], // может быть null — будет подставлен дефолт
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }

  // Парсер данных, приходящих с бэкенда (WalletDTO)
  factory Wallet.fromServerJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      name: json['name'] as String,
      currency: json['currency'] as String,
      symbol: json['symbol'] as String,
      balance: (json['balance'] as num).toDouble(),
      address: json['address'] as String,
    );
  }

  static String _iconForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BNB':
        return 'bnb';
      case 'T1PS':
        return 'bsc';
      default:
        return 'generic';
    }
  }

  static Color _colorForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BNB':
        return const Color(0xFFF3BA2F);
      case 'T1PS':
        return const Color(0xFF0098EA);
      default:
        return const Color(0xFF627EEA);
    }
  }
}

enum CurrencyType { btc, eth, usdt, usdc }

extension CurrencyTypeExtension on CurrencyType {
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
