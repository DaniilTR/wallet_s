import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();

  factory WalletService() {
    return _instance;
  }

  WalletService._internal();

  // Mock данные
  late List<Wallet> _wallets;
  late List<Transaction> _transactions;

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _wallets = [
      Wallet(
        id: '1',
        name: 'My Bitcoin',
        currency: 'Bitcoin',
        symbol: 'BTC',
        balance: 0.5432,
        address: '1A1z7agoat2FYAC...xyz',
        iconUrl: 'btc',
        color: const Color(0xFFF7931A),
      ),
      Wallet(
        id: '2',
        name: 'Ethereum Wallet',
        currency: 'Ethereum',
        symbol: 'ETH',
        balance: 2.1547,
        address: '0x742d35Cc6634C0532925a3b844Bc4e7595f...abc',
        iconUrl: 'eth',
        color: const Color(0xFF627EEA),
      ),
      Wallet(
        id: '3',
        name: 'Stables',
        currency: 'USDT',
        symbol: 'USDT',
        balance: 5000.0,
        address: '0x000000000000000000000000...def',
        iconUrl: 'usdt',
        color: const Color(0xFF26A17B),
      ),
    ];

    _transactions = [
      Transaction(
        id: 'tx_1',
        type: 'send',
        amount: 0.05,
        address: '1A1z7agoat2FYAC...xyz',
        status: 'completed',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        currency: 'BTC',
      ),
      Transaction(
        id: 'tx_2',
        type: 'receive',
        amount: 0.1234,
        address: '1Lbz...abc',
        status: 'completed',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        currency: 'BTC',
      ),
      Transaction(
        id: 'tx_3',
        type: 'send',
        amount: 1.5,
        address: '0x742d...def',
        status: 'completed',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        currency: 'ETH',
      ),
      Transaction(
        id: 'tx_4',
        type: 'receive',
        amount: 500.0,
        address: '0x000...ghi',
        status: 'pending',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        currency: 'USDT',
      ),
      Transaction(
        id: 'tx_5',
        type: 'send',
        amount: 2500.0,
        address: '0x111...jkl',
        status: 'completed',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        currency: 'USDT',
      ),
    ];
  }

  Future<List<Wallet>> getWallets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _wallets;
  }

  Future<Wallet?> getWallet(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions;
  }

  Future<List<Transaction>> getWalletTransactions(String walletId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions;
  }

  Future<bool> createWallet({
    required String name,
    required String currency,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newWallet = Wallet(
      id: DateTime.now().toString(),
      name: name,
      currency: currency,
      symbol: currency,
      balance: 0.0,
      address: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      iconUrl: currency.toLowerCase(),
      color: const Color(0xFF627EEA),
    );

    _wallets.add(newWallet);
    return true;
  }

  Future<bool> sendTransaction({
    required String fromWalletId,
    required String toAddress,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final wallet = _wallets.firstWhere((w) => w.id == fromWalletId);
    final newTransaction = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      type: 'send',
      amount: amount,
      address: toAddress,
      status: 'completed',
      timestamp: DateTime.now(),
      currency: wallet.symbol,
    );

    _transactions.insert(0, newTransaction);
    return true;
  }

  double getTotalBalance() {
    return _wallets.fold(0, (sum, w) => sum + (w.balance * 1000));
  }

  String getShortAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}
