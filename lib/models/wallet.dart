// lib/models/wallet.dart

import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final String currency;
  final String symbol;
  final double balance;
  final String address;
  final String iconUrl;
  final Color color;

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