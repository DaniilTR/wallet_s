import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';

/// Service for managing cryptocurrency wallet private keys
class CryptoWalletService {
  static final CryptoWalletService _instance = CryptoWalletService._internal();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _privateKeyStorageKey = 'bsc_wallet_private_key';
  
  factory CryptoWalletService() {
    return _instance;
  }
  
  CryptoWalletService._internal();
  
  /// Create a new wallet with a random private key
  Future<Credentials> createWallet() async {
    final random = Random.secure();
    final privateKey = EthPrivateKey.createRandom(random);
    
    // Store the private key
    await _secureStorage.write(
      key: _privateKeyStorageKey,
      value: privateKey.privateKey.toRadixString(16).padLeft(64, '0'),
    );
    
    return privateKey;
  }
  
  /// Import wallet from a hex private key (with or without 0x prefix)
  Future<Credentials> importWallet(String privateKeyHex) async {
    // Remove 0x prefix if present
    String cleanKey = privateKeyHex.trim();
    if (cleanKey.startsWith('0x') || cleanKey.startsWith('0X')) {
      cleanKey = cleanKey.substring(2);
    }
    
    // Validate hex format and length
    if (cleanKey.length != 64 || !_isValidHex(cleanKey)) {
      throw Exception('Invalid private key format. Expected 64 hex characters.');
    }
    
    // Parse the private key
    final privateKey = EthPrivateKey.fromHex(cleanKey);
    
    // Store the private key
    await _secureStorage.write(
      key: _privateKeyStorageKey,
      value: cleanKey,
    );
    
    return privateKey;
  }
  
  /// Load existing wallet from secure storage
  Future<Credentials?> loadWallet() async {
    final privateKeyHex = await _secureStorage.read(key: _privateKeyStorageKey);
    
    if (privateKeyHex == null || privateKeyHex.isEmpty) {
      return null;
    }
    
    try {
      return EthPrivateKey.fromHex(privateKeyHex);
    } catch (e) {
      debugPrint('Error loading wallet: $e');
      return null;
    }
  }
  
  /// Check if a wallet exists
  Future<bool> hasWallet() async {
    final privateKeyHex = await _secureStorage.read(key: _privateKeyStorageKey);
    return privateKeyHex != null && privateKeyHex.isNotEmpty;
  }
  
  /// Delete the wallet (remove private key from storage)
  Future<void> deleteWallet() async {
    await _secureStorage.delete(key: _privateKeyStorageKey);
  }
  
  /// Get the address from credentials
  EthereumAddress getAddress(Credentials credentials) {
    return credentials.address;
  }
  
  /// Validate if a string is a valid Ethereum address
  bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Helper to validate hex string
  bool _isValidHex(String hex) {
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex);
  }
}
