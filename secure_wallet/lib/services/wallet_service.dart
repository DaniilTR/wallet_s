// import 'package:flutter/material.dart';
import 'package:secure_wallet/models/wallet.dart';
import 'package:secure_wallet/models/transaction.dart';
import 'package:secure_wallet/services/bsc_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_wallet/services/auth_service.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  late List<Wallet> _wallets;
  late List<Transaction> _transactions;

  Future<void> initialize() async {
    // Загружаем кошельки пользователя с бэкенда, используя Bearer-токен
    final auth = AuthService();
    _wallets = [];
    _transactions = [];

    if (!auth.isAuthenticated) {
      return; // без токена не можем загрузить кошельки
    }

    final baseUrl = auth.baseUrl;
    final headers = auth.authHeaders;
    try {
      final resp =
          await http.get(Uri.parse('$baseUrl/wallets'), headers: headers);
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        _wallets = data
            .whereType<Map<String, dynamic>>()
            .map((w) => Wallet.fromServerJson(w))
            .toList();
        return;
      }
    } catch (_) {
      // упадём в резерв ниже
    }

    // Резерв: если сервер недоступен, оставим список пустым, чтобы не подставлять локальные адреса
    _wallets = [];
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
    final resp = await http.get(
        Uri.parse('$baseUrl/wallets/$walletId/transactions'),
        headers: headers);
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data
          .map((t) => Transaction(
                id: t['id'],
                type: t['type'],
                amount: (t['amount'] as num).toDouble(),
                address: t['address'],
                status: t['status'],
                timestamp: DateTime.parse(t['timestamp']),
                currency: t['currency'],
              ))
          .toList();
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

    final resp = await http.post(Uri.parse('$baseUrl/wallets/import'),
        headers: headers, body: body);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      // Перезапросим список кошельков с сервера, чтобы отобразить реальные адреса
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
    final wallet = _wallets.firstWhere((w) => w.id == fromWalletId);

    // Если это наш BSC токен — отправляем через web3
    final bsc = BscService();
    if (wallet.id == 'bsc_token') {
      try {
        final txHash =
            await bsc.sendToken(toAddress: toAddress, amount: amount);
        _transactions.insert(
          0,
          Transaction(
            id: txHash,
            type: 'send',
            amount: amount,
            address: toAddress,
            status: 'submitted',
            timestamp: DateTime.now(),
            currency: wallet.symbol,
          ),
        );

        // Обновим баланс после отправки
        final newBalance = await bsc.getTokenBalance();
        final idx = _wallets.indexWhere((w) => w.id == 'bsc_token');
        if (idx >= 0) {
          _wallets[idx] = Wallet(
            id: _wallets[idx].id,
            name: _wallets[idx].name,
            currency: _wallets[idx].currency,
            symbol: _wallets[idx].symbol,
            balance: newBalance,
            address: _wallets[idx].address,
            iconUrl: _wallets[idx].iconUrl,
            color: _wallets[idx].color,
          );
        }
        return true;
      } catch (e) {
        throw Exception('Не удалось отправить транзакцию: $e');
      }
    }

    // Отправка нативного BNB
    if (wallet.id == 'bsc_native') {
      try {
        final txHash =
            await bsc.sendNativeBNB(toAddress: toAddress, amount: amount);
        _transactions.insert(
          0,
          Transaction(
            id: txHash,
            type: 'send',
            amount: amount,
            address: toAddress,
            status: 'submitted',
            timestamp: DateTime.now(),
            currency: wallet.symbol,
          ),
        );

        // Обновим баланс BNB
        final newBalance = await bsc.getNativeBalanceBNB();
        final idx = _wallets.indexWhere((w) => w.id == 'bsc_native');
        if (idx >= 0) {
          _wallets[idx] = Wallet(
            id: _wallets[idx].id,
            name: _wallets[idx].name,
            currency: _wallets[idx].currency,
            symbol: _wallets[idx].symbol,
            balance: newBalance,
            address: _wallets[idx].address,
            iconUrl: _wallets[idx].iconUrl,
            color: _wallets[idx].color,
          );
        }
        return true;
      } catch (e) {
        throw Exception('Не удалось отправить BNB: $e');
      }
    }

    // Иначе — мок транзакция
    await Future.delayed(const Duration(milliseconds: 500));
    _transactions.insert(
      0,
      Transaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: 'send',
        amount: amount,
        address: toAddress,
        status: 'completed',
        timestamp: DateTime.now(),
        currency: wallet.symbol,
      ),
    );
    return true;
  }

  double getTotalBalance() {
    return _wallets.fold(0.0, (sum, w) => sum + (w.balance));
  }

  String getShortAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}
