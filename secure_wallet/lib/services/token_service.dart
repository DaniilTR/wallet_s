import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import '../config/bsc_config.dart';
import 'web3_service.dart';

/// Service for interacting with ERC-20 tokens
class TokenService {
  static final TokenService _instance = TokenService._internal();
  
  final Web3Service _web3Service = Web3Service();
  DeployedContract? _tokenContract;
  
  // Cached token metadata
  String? _tokenName;
  String? _tokenSymbol;
  int? _tokenDecimals;
  
  factory TokenService() {
    return _instance;
  }
  
  TokenService._internal();
  
  /// Initialize the token contract
  Future<void> initialize() async {
    if (_tokenContract != null) return;
    
    // Load ERC-20 ABI
    final abiString = await rootBundle.loadString('assets/abi/erc20.json');
    final abiJson = jsonDecode(abiString) as List<dynamic>;
    final abi = ContractAbi.fromJson(jsonEncode(abiJson), 'ERC20');
    
    // Create contract instance
    final contractAddress = EthereumAddress.fromHex(BSCConfig.tokenContractAddress);
    _tokenContract = DeployedContract(abi, contractAddress);
    
    // Load metadata
    await _loadMetadata();
  }
  
  /// Load token metadata (name, symbol, decimals)
  Future<void> _loadMetadata() async {
    if (_tokenContract == null) {
      await initialize();
    }
    
    try {
      // Get name
      final nameFunction = _tokenContract!.function('name');
      final nameResult = await _web3Service.client.call(
        contract: _tokenContract!,
        function: nameFunction,
        params: [],
      );
      _tokenName = nameResult.first as String;
      
      // Get symbol
      final symbolFunction = _tokenContract!.function('symbol');
      final symbolResult = await _web3Service.client.call(
        contract: _tokenContract!,
        function: symbolFunction,
        params: [],
      );
      _tokenSymbol = symbolResult.first as String;
      
      // Get decimals
      final decimalsFunction = _tokenContract!.function('decimals');
      final decimalsResult = await _web3Service.client.call(
        contract: _tokenContract!,
        function: decimalsFunction,
        params: [],
      );
      _tokenDecimals = (decimalsResult.first as BigInt).toInt();
    } catch (e) {
      print('Error loading token metadata: $e');
      // Use defaults if metadata loading fails
      _tokenName = 'Unknown Token';
      _tokenSymbol = 'TOKEN';
      _tokenDecimals = 18;
    }
  }
  
  /// Get token name
  Future<String> getTokenName() async {
    if (_tokenName == null) {
      await _loadMetadata();
    }
    return _tokenName ?? 'Unknown Token';
  }
  
  /// Get token symbol
  Future<String> getTokenSymbol() async {
    if (_tokenSymbol == null) {
      await _loadMetadata();
    }
    return _tokenSymbol ?? 'TOKEN';
  }
  
  /// Get token decimals
  Future<int> getTokenDecimals() async {
    if (_tokenDecimals == null) {
      await _loadMetadata();
    }
    return _tokenDecimals ?? 18;
  }
  
  /// Get token balance for an address
  Future<BigInt> getTokenBalance(EthereumAddress address) async {
    if (_tokenContract == null) {
      await initialize();
    }
    
    final balanceOfFunction = _tokenContract!.function('balanceOf');
    final result = await _web3Service.client.call(
      contract: _tokenContract!,
      function: balanceOfFunction,
      params: [address],
    );
    
    return result.first as BigInt;
  }
  
  /// Convert token amount from human-readable to raw units
  BigInt toTokenUnits(double amount, int decimals) {
    final multiplier = BigInt.from(10).pow(decimals);
    // Use string conversion to maintain precision for large numbers
    final amountString = amount.toStringAsFixed(decimals);
    final parts = amountString.split('.');
    final wholePart = BigInt.parse(parts[0]);
    final fractionalPart = parts.length > 1 ? parts[1].padRight(decimals, '0') : '0' * decimals;
    final fractionBigInt = BigInt.parse(fractionalPart.substring(0, decimals));
    return wholePart * multiplier + fractionBigInt;
  }
  
  /// Convert token amount from raw units to human-readable
  double fromTokenUnits(BigInt amount, int decimals) {
    final divisor = BigInt.from(10).pow(decimals);
    return amount.toDouble() / divisor.toDouble();
  }
  
  /// Transfer tokens
  Future<String> transfer({
    required Credentials credentials,
    required EthereumAddress recipient,
    required double amount,
  }) async {
    if (_tokenContract == null) {
      await initialize();
    }
    
    final decimals = await getTokenDecimals();
    final amountInUnits = toTokenUnits(amount, decimals);
    
    // Get transfer function
    final transferFunction = _tokenContract!.function('transfer');
    
    // Estimate gas
    final gasEstimate = await _web3Service.client.estimateGas(
      sender: credentials.address,
      to: _tokenContract!.address,
      data: transferFunction.encodeCall([recipient, amountInUnits]),
    );
    
    // Add 20% buffer to gas estimate
    final gasLimit = (gasEstimate * BigInt.from(120)) ~/ BigInt.from(100);
    
    // Get gas price
    final gasPrice = await _web3Service.getGasPrice();
    
    // Send transaction
    final txHash = await _web3Service.client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _tokenContract!,
        function: transferFunction,
        parameters: [recipient, amountInUnits],
        maxGas: gasLimit.toInt(),
        gasPrice: gasPrice,
      ),
      chainId: BSCConfig.chainId,
    );
    
    return txHash;
  }
}
