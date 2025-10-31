import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import 'bsc_service.dart';

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
    // Инициализируем BSC сервис.
    // Он создаёт/подхватывает локальный приватный ключ из secure storage
    // и вычисляет из него EVM-адрес. Этот адрес один и тот же для
    // нативного BNB и для токена на BSC Testnet.
    final bsc = BscService();
    try {
      await bsc.init();
    } catch (_) {
      // Идем дальше; кошелек будет без ончейн-обновления, но UI не упадёт
    }

    // Создаем список кошельков (можно оставить моковые как примеры)
    _wallets = [];

    // Добавляем кошелек токена в BSC Testnet (адрес берём из bsc.getAddressHex())
    try {
      final address = await bsc.getAddressHex();
      final balance = await bsc.getTokenBalance();
      _wallets.add(
        Wallet(
          id: 'bsc_token',
          name: 'BSC Testnet Token',
          currency: bsc.symbol,
          symbol: bsc.symbol,
          balance: balance,
          address: address,
          iconUrl: 'bsc',
          color: const Color(0xFFF3BA2F), // BNB жёлтый
        ),
      );
    } catch (_) {
      // Если не смогли получить баланс — добавим кошелек с нулевым балансом
      final address = await bsc.getAddressHex();
      _wallets.add(
        Wallet(
          id: 'bsc_token',
          name: 'BSC Testnet Token',
          currency: bsc.symbol,
          symbol: bsc.symbol,
          balance: 0.0,
          address: address,
          iconUrl: 'bsc',
          color: const Color(0xFFF3BA2F),
        ),
      );
    }

    // Добавляем кошелек нативного BNB (для отображения баланса газа)
    // Адрес — тот же самый, что и для токена (один приватный ключ).
    try {
      final address = await bsc.getAddressHex();
      final bnbBalance = await bsc.getNativeBalanceBNB();
      _wallets.insert(
        0,
        Wallet(
          id: 'bsc_native',
          name: 'BNB Testnet',
          currency: 'Binance Coin',
          symbol: 'BNB',
          balance: bnbBalance,
          address: address,
          iconUrl: 'bnb',
          color: const Color(0xFFF3BA2F),
        ),
      );
    } catch (_) {
      final address = await bsc.getAddressHex();
      _wallets.insert(
        0,
        Wallet(
          id: 'bsc_native',
          name: 'BNB Testnet',
          currency: 'Binance Coin',
          symbol: 'BNB',
          balance: 0.0,
          address: address,
          iconUrl: 'bnb',
          color: const Color(0xFFF3BA2F),
        ),
      );
    }

    // Начинаем без истории — будем добавлять реальные отправки
    _transactions = [];
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
    final wallet = _wallets.firstWhere((w) => w.id == fromWalletId);

    // Если это наш BSC токен — отправляем через web3
    final bsc = BscService();
    if (wallet.id == 'bsc_token') {
      try {
        final txHash = await bsc.sendToken(toAddress: toAddress, amount: amount);
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
        final txHash = await bsc.sendNativeBNB(toAddress: toAddress, amount: amount);
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
    return _wallets.fold(0, (sum, w) => sum + (w.balance));
  }

  String getShortAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}