import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import '../config/bsc_config.dart';
import '../services/crypto_wallet_service.dart';
import '../services/web3_service.dart';
import '../services/token_service.dart';
import 'bsc_send_token_screen.dart';
import 'bsc_receive_screen.dart';

/// Home screen for BSC wallet showing balances
class BSCWalletHomeScreen extends StatefulWidget {
  const BSCWalletHomeScreen({super.key});

  @override
  State<BSCWalletHomeScreen> createState() => _BSCWalletHomeScreenState();
}

class _BSCWalletHomeScreenState extends State<BSCWalletHomeScreen> {
  final CryptoWalletService _walletService = CryptoWalletService();
  final Web3Service _web3Service = Web3Service();
  final TokenService _tokenService = TokenService();
  
  Credentials? _credentials;
  EthereumAddress? _address;
  
  EtherAmount? _nativeBalance;
  BigInt? _tokenBalance;
  String? _tokenSymbol;
  int? _tokenDecimals;
  
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }
  
  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Load credentials
      _credentials = await _walletService.loadWallet();
      if (_credentials == null) {
        throw Exception('No wallet found');
      }
      
      _address = _credentials!.address;
      
      // Initialize token service
      await _tokenService.initialize();
      
      // Load balances
      await _loadBalances();
      
      // Load token metadata
      _tokenSymbol = await _tokenService.getTokenSymbol();
      _tokenDecimals = await _tokenService.getTokenDecimals();
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadBalances() async {
    if (_address == null) return;
    
    try {
      // Get native balance
      _nativeBalance = await _web3Service.getNativeBalance(_address!);
      
      // Get token balance
      _tokenBalance = await _tokenService.getTokenBalance(_address!);
      
      setState(() {});
    } catch (e) {
      debugPrint('Error loading balances: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BSC Wallet'),
        backgroundColor: const Color(0xFFF0B90B),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBalances,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildContent(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadWalletData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAddressCard(),
          const SizedBox(height: 16),
          _buildBalanceCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildNetworkInfo(),
        ],
      ),
    );
  }
  
  Widget _buildAddressCard() {
    final addressString = _address?.hexEip55 ?? '';
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0B90B), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Address',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  addressString,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: Colors.black),
                onPressed: () => _copyToClipboard(addressString),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBalanceCard() {
    final nativeBalanceEth = _nativeBalance?.getValueInUnit(EtherUnit.ether) ?? 0.0;
    final tokenBalanceFormatted = _tokenBalance != null && _tokenDecimals != null
        ? _tokenService.fromTokenUnits(_tokenBalance!, _tokenDecimals!)
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBalanceRow(
            label: 'Native Balance',
            value: nativeBalanceEth.toStringAsFixed(6),
            symbol: BSCConfig.nativeSymbol,
            icon: Icons.account_balance,
          ),
          const Divider(height: 24),
          _buildBalanceRow(
            label: 'Token Balance',
            value: tokenBalanceFormatted.toStringAsFixed(4),
            symbol: _tokenSymbol ?? 'TOKEN',
            icon: Icons.token,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBalanceRow({
    required String label,
    required String value,
    required String symbol,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0098EA)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$value $symbol',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToReceive(),
              icon: const Icon(Icons.qr_code),
              label: const Text('Receive'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToSend(),
              icon: const Icon(Icons.send),
              label: const Text('Send'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0098EA),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNetworkInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Network', BSCConfig.networkName),
          _buildInfoRow('Chain ID', BSCConfig.chainId.toString()),
          _buildInfoRow('RPC', BSCConfig.rpcUrl),
          _buildInfoRow('Token Contract', BSCConfig.tokenContractAddress),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _navigateToReceive() {
    if (_address == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BSCReceiveScreen(address: _address!),
      ),
    );
  }
  
  void _navigateToSend() {
    if (_credentials == null || _address == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BSCSendTokenScreen(
          credentials: _credentials!,
          fromAddress: _address!,
        ),
      ),
    ).then((_) {
      // Refresh balances after returning from send screen
      _loadBalances();
    });
  }
}
