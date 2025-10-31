import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  late List<Wallet> _wallets;
  late List<Transaction> _transactions;

  Future<void> initialize() async {
    final auth = AuthService();
    final baseUrl = auth.baseUrl;
    final headers = auth.authHeaders;

    final resp = await http.get(Uri.parse('$baseUrl/wallets'), headers: headers);
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      _wallets = data.map((w) {
        final symbol = (w['symbol'] ?? '').toString();
        final color = symbol.toUpperCase() == 'BNB'
            ? const Color(0xFFF3BA2F)
            : const Color(0xFF0098EA);
        return Wallet(
          id: w['id'],
          name: w['name'] ?? symbol,
          currency: w['currency'] ?? symbol,
          symbol: symbol,
          balance: (w['balance'] as num?)?.toDouble() ?? 0.0,
          address: w['address'] ?? '',
          iconUrl: symbol.toLowerCase(),
          color: color,
        );
      }).toList().cast<Wallet>();
    } else {
      _wallets = [];
    }

    _transactions = [];
  }

  Future<List<Wallet>> getWallets() async {
    return _wallets;
  }

  Future<Wallet?> getWallet(String id) async {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    return _transactions;
  }

  Future<List<Transaction>> getWalletTransactions(String walletId) async {
    final auth = AuthService();
    final baseUrl = auth.baseUrl;
    final headers = auth.authHeaders;
    final resp = await http.get(Uri.parse('$baseUrl/wallets/$walletId/transactions'), headers: headers);
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data.map((t) => Transaction(
        id: t['id'],
        type: t['type'],
        amount: (t['amount'] as num).toDouble(),
        address: t['address'],
        status: t['status'],
        timestamp: DateTime.parse(t['timestamp']),
        currency: t['currency'],
      )).toList();
    }
    return [];
  }

  Future<bool> createWallet({
    required String name,
    required String currency,
    String? address,
  }) async {
    final auth = AuthService();
    final baseUrl = auth.baseUrl;
    final headers = auth.authHeaders;

    // В качестве символа используем currency (например, BNB или T1PS)
    final body = json.encode({
      'name': name,
      'address': address,
      'currency': currency == 'BNB' ? 'Binance Coin' : currency,
      'symbol': currency,
    });

    final resp = await http.post(Uri.parse('$baseUrl/wallets/import'), headers: headers, body: body);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      // Перезапросим список кошельков
      await initialize();
      return true;
    }
    return false;
  }

  Future<bool> sendTransaction({
    required String fromWalletId,
    required String toAddress,
    required double amount,
  }) async {
    final auth = AuthService();
    final baseUrl = auth.baseUrl;
    final headers = auth.authHeaders;
    final body = json.encode({
      'fromWalletId': fromWalletId,
      'toAddress': toAddress,
      'amount': amount,
    });
    final resp = await http.post(Uri.parse('$baseUrl/transactions/send'), headers: headers, body: body);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return true;
    }
    throw Exception('Send failed: ${resp.statusCode}');
  }

  double getTotalBalance() {
    return _wallets.fold(0.0, (sum, w) => sum + w.balance);
  }

  String getShortAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}