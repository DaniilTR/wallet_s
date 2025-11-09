class BscConfig {
  // Публичные RPC-ноды тестнета BSC (chainId = 97).
  // Можно переключать при необходимости.
  static const List<String> rpcUrls = [
    'https://data-seed-prebsc-1-s1.binance.org:8545/',
    'https://data-seed-prebsc-2-s1.binance.org:8545/',
    'https://bsc-testnet.publicnode.com',
  ];

  // Chain ID тестовой сети BSC
  static const int chainId = 97;

  // Адрес контракта токена (BEP-20) из задачи
  static const String tokenContractAddress =
      '0xf9Db015ae3D2B413FcA691022c610422FFab4368';

  // Минимальный ABI для ERC20/BEP20 (symbol, decimals, balanceOf, transfer)
  static const String erc20Abi = '''
  [
    {"constant": true, "inputs": [], "name": "symbol", "outputs": [{"name": "", "type": "string"}], "type": "function"},
    {"constant": true, "inputs": [], "name": "decimals", "outputs": [{"name": "", "type": "uint8"}], "type": "function"},
    {"constant": true, "inputs": [{"name": "_owner", "type": "address"}], "name": "balanceOf", "outputs": [{"name": "balance", "type": "uint256"}], "type": "function"},
    {"constant": false, "inputs": [{"name": "_to", "type": "address"}, {"name": "_value", "type": "uint256"}], "name": "transfer", "outputs": [{"name": "", "type": "bool"}], "type": "function"}
  ]
  ''';
}
