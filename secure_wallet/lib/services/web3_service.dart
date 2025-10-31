import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../config/bsc_config.dart';

/// Service for interacting with Web3/BSC network
class Web3Service {
  static final Web3Service _instance = Web3Service._internal();
  
  late Web3Client _client;
  
  factory Web3Service() {
    return _instance;
  }
  
  Web3Service._internal() {
    _initialize();
  }
  
  void _initialize() {
    _client = Web3Client(BSCConfig.rpcUrl, Client());
  }
  
  Web3Client get client => _client;
  
  /// Get native BNB balance for an address
  Future<EtherAmount> getNativeBalance(EthereumAddress address) async {
    return await _client.getBalance(address);
  }
  
  /// Get current gas price
  Future<EtherAmount> getGasPrice() async {
    return await _client.getGasPrice();
  }
  
  /// Estimate gas for a transaction
  Future<BigInt> estimateGas({
    required EthereumAddress sender,
    required EthereumAddress recipient,
    EtherAmount? value,
    Uint8List? data,
  }) async {
    return await _client.estimateGas(
      sender: sender,
      to: recipient,
      value: value,
      data: data,
    );
  }
  
  /// Get current block number
  Future<int> getBlockNumber() async {
    return await _client.getBlockNumber();
  }
  
  /// Dispose the client
  void dispose() {
    _client.dispose();
  }
}
