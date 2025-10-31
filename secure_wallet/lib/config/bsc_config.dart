/// Configuration for BNB Smart Chain Testnet
class BSCConfig {
  // Network configuration
  static const String networkName = 'BNB Smart Chain Testnet';
  static const String rpcUrl = 'https://bsc-testnet.publicnode.com';
  static const int chainId = 97;
  static const String nativeSymbol = 'tBNB';
  static const String explorerUrl = 'https://testnet.bscscan.com';
  
  // Token configuration
  static const String tokenContractAddress = '0xf9Db015ae3D2B413FcA691022c610422FFab4368';
  
  // Explorer links
  static String getAddressUrl(String address) {
    return '$explorerUrl/address/$address';
  }
  
  static String getTxUrl(String txHash) {
    return '$explorerUrl/tx/$txHash';
  }
}
