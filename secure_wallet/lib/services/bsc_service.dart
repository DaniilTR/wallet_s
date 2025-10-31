import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../config/bsc_config.dart';

/// Сервис работы с сетью BSC Testnet и локальным EVM-кошельком.
///
/// ВАЖНО: приватный ключ создаётся и хранится ТОЛЬКО на устройстве
/// в безопасном хранилище (`flutter_secure_storage`). Никаких отправок
/// ключа на сервер не происходит. Адрес EVM вычисляется из приватного ключа.
class BscService {
  BscService._internal();
  static final BscService _instance = BscService._internal();
  factory BscService() => _instance;

  // Ключ для записи приватного ключа в защищённое хранилище устройства
  static const _pkStorageKey = 'bsc_evm_private_key_hex';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Web3Client? _client;
  DeployedContract? _tokenContract;
  ContractFunction? _balanceOfFn;
  ContractFunction? _transferFn;
  ContractFunction? _decimalsFn;
  ContractFunction? _symbolFn;

  String? _rpcUrl;
  int _decimals = 18; // значение по умолчанию, будет считано из контракта
  String _symbol = 'TOKEN';

  /// Инициализация клиента Web3 и контракта токена.
  /// Подключается к первому доступному RPC из списка и читает
  /// метаданные токена (symbol/decimals).
  Future<void> init() async {
    // Инициализация клиента с первой доступной RPC нодой из списка
    for (final url in BscConfig.rpcUrls) {
      try {
  final client = Web3Client(url, http.Client());
        // быстрый запрос для проверки
        await client.getGasPrice();
        _client = client;
        _rpcUrl = url;
        break;
      } catch (_) {
        continue;
      }
    }
    if (_client == null) {
      throw Exception('Не удалось подключиться к RPC BSC Testnet.');
    }

    // Подготовка контракта токена
    final contractAddr = EthereumAddress.fromHex(BscConfig.tokenContractAddress);
    _tokenContract = DeployedContract(
      ContractAbi.fromJson(BscConfig.erc20Abi, 'BEP20'),
      contractAddr,
    );
    _balanceOfFn = _tokenContract!.function('balanceOf');
    _transferFn = _tokenContract!.function('transfer');
    _decimalsFn = _tokenContract!.function('decimals');
    _symbolFn = _tokenContract!.function('symbol');

    // Читаем метаданные токена
    try {
      final sym = await _client!.call(
        contract: _tokenContract!,
        function: _symbolFn!,
        params: const [],
      );
      _symbol = (sym.first as String?) ?? _symbol;
    } catch (_) {}

    try {
      final dec = await _client!.call(
        contract: _tokenContract!,
        function: _decimalsFn!,
        params: const [],
      );
      _decimals = (dec.first as BigInt?)?.toInt() ?? _decimals;
    } catch (_) {}
  }

  String get rpcUrl => _rpcUrl ?? BscConfig.rpcUrls.first;
  int get decimals => _decimals;
  String get symbol => _symbol;

  // Баланс нативного BNB для текущего адреса
  Future<double> getNativeBalanceBNB() async {
    if (_client == null) {
      await init();
    }
    final address = await getOrCreateAddress();
    final balance = await _client!.getBalance(address);
    // Перевод из wei в BNB
    final inWei = balance.getInWei;
    final denom = BigInt.from(10).pow(18);
    return inWei / denom;
  }

  /// Создать или получить EVM-адрес кошелька.
  ///
  /// 1) Проверяем, есть ли приватный ключ в secure storage.
  /// 2) Если нет — генерируем 32 случайных байта (криптографически
  ///    безопасный `Random.secure()`), интерпретируем как приватный
  ///    ключ в hex и сохраняем в `flutter_secure_storage`.
  /// 3) Возвращаем адрес, вычисленный из приватного ключа.
  Future<EthereumAddress> getOrCreateAddress() async {
    final pkHex = await _secureStorage.read(key: _pkStorageKey);
    if (pkHex == null) {
      // Генерируем 32 байта приватного ключа (ECDSA secp256k1)
      final rnd = Random.secure();
      final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  final newKey = EthPrivateKey.fromHex(hex);
  await _secureStorage.write(key: _pkStorageKey, value: hex);
      // Адрес = keccak(publicKey)[12..] с префиксом 0x
      return newKey.address;
    } else {
  final key = EthPrivateKey.fromHex(pkHex);
  return key.address;
    }
  }

  /// Возвращает адрес в форматe EIP-55 (checksum) для удобной визуальной проверки.
  Future<String> getAddressHex() async {
    final addr = await getOrCreateAddress();
    return addr.hexEip55;
  }

  /// Баланс токена BEP-20 для текущего адреса (в единицах токена, не в wei)
  Future<double> getTokenBalance() async {
    if (_client == null || _tokenContract == null || _balanceOfFn == null) {
      await init();
    }
    final address = await getOrCreateAddress();
    final result = await _client!.call(
      contract: _tokenContract!,
      function: _balanceOfFn!,
      params: [address],
    );
    final raw = result.first as BigInt;
    final denom = BigInt.from(10).pow(_decimals);
    return raw / denom;
  }

  /// Отправить amount токена на toAddress. Возвращает txHash.
  Future<String> sendToken({
    required String toAddress,
    required double amount,
    int? gasPriceGwei,
    int? gasLimit,
  }) async {
    if (_client == null || _tokenContract == null || _transferFn == null) {
      await init();
    }
    final pkHex = await _secureStorage.read(key: _pkStorageKey);
    if (pkHex == null) {
      throw Exception('Кошелек не создан. Сначала создайте кошелек.');
    }
    final creds = EthPrivateKey.fromHex(pkHex);
    final to = EthereumAddress.fromHex(toAddress);

    final denom = BigInt.from(10).pow(_decimals);
    final value = BigInt.from((amount * denom.toDouble()).round());

    final tx = Transaction.callContract(
      contract: _tokenContract!,
      function: _transferFn!,
      parameters: [to, value],
      maxGas: gasLimit, // может быть null — клиент сам оценит
      // gasPrice — в wei, если указан gwei — конвертим ниже
      gasPrice: gasPriceGwei != null
          ? EtherAmount.inWei(BigInt.from(gasPriceGwei) * BigInt.from(1000000000))
          : null,
    );

    final txHash = await _client!.sendTransaction(
      creds,
      tx,
      chainId: BscConfig.chainId,
    );
    return txHash;
  }

  /// Отправка нативного BNB (тестовая сеть). Возвращает txHash.
  Future<String> sendNativeBNB({
    required String toAddress,
    required double amount,
    int? gasPriceGwei,
    int? gasLimit,
  }) async {
    if (_client == null) {
      await init();
    }
    final pkHex = await _secureStorage.read(key: _pkStorageKey);
    if (pkHex == null) {
      throw Exception('Кошелек не создан. Сначала создайте кошелек.');
    }

    final creds = EthPrivateKey.fromHex(pkHex);
    final to = EthereumAddress.fromHex(toAddress);

    final valueWei = BigInt.from((amount * pow(10, 18)).round());

    final tx = Transaction(
      to: to,
      value: EtherAmount.inWei(valueWei),
      maxGas: gasLimit,
      gasPrice: gasPriceGwei != null
          ? EtherAmount.inWei(BigInt.from(gasPriceGwei) * BigInt.from(1000000000))
          : null,
    );

    final txHash = await _client!.sendTransaction(
      creds,
      tx,
      chainId: BscConfig.chainId,
    );
    return txHash;
  }
}
