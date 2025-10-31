import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import '../config/bsc_config.dart';
import '../services/token_service.dart';
import '../services/web3_service.dart';

/// Screen for sending BEP-20 tokens
class BSCSendTokenScreen extends StatefulWidget {
  final Credentials credentials;
  final EthereumAddress fromAddress;
  
  const BSCSendTokenScreen({
    super.key,
    required this.credentials,
    required this.fromAddress,
  });

  @override
  State<BSCSendTokenScreen> createState() => _BSCSendTokenScreenState();
}

class _BSCSendTokenScreenState extends State<BSCSendTokenScreen> {
  final TokenService _tokenService = TokenService();
  final Web3Service _web3Service = Web3Service();
  
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _txHash;
  
  BigInt? _tokenBalance;
  int? _tokenDecimals;
  String? _tokenSymbol;
  EtherAmount? _nativeBalance;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load token info
      _tokenDecimals = await _tokenService.getTokenDecimals();
      _tokenSymbol = await _tokenService.getTokenSymbol();
      _tokenBalance = await _tokenService.getTokenBalance(widget.fromAddress);
      _nativeBalance = await _web3Service.getNativeBalance(widget.fromAddress);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Token'),
        backgroundColor: const Color(0xFF0098EA),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _txHash != null
              ? _buildSuccessView()
              : _buildForm(),
    );
  }
  
  Widget _buildForm() {
    final tokenBalanceFormatted = _tokenBalance != null && _tokenDecimals != null
        ? _tokenService.fromTokenUnits(_tokenBalance!, _tokenDecimals!)
        : 0.0;
    final nativeBalanceEth = _nativeBalance?.getValueInUnit(EtherUnit.ether) ?? 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Balance info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${tokenBalanceFormatted.toStringAsFixed(4)} ${_tokenSymbol ?? 'TOKEN'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gas available: ${nativeBalanceEth.toStringAsFixed(6)} ${BSCConfig.nativeSymbol}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recipient address
          TextField(
            controller: _recipientController,
            decoration: InputDecoration(
              labelText: 'Recipient Address',
              hintText: '0x...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Amount
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: '0.0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: _tokenSymbol ?? '',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          
          const SizedBox(height: 8),
          
          // Max button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (_tokenBalance != null && _tokenDecimals != null) {
                  final max = _tokenService.fromTokenUnits(_tokenBalance!, _tokenDecimals!);
                  _amountController.text = max.toString();
                }
              },
              child: const Text('MAX'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Send button
          ElevatedButton(
            onPressed: _isSending ? null : _handleSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0098EA),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Transaction Sent!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your transaction has been submitted to the network.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Hash:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _txHash ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openExplorer,
              icon: const Icon(Icons.open_in_new),
              label: const Text('View on BscScan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0098EA),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Wallet'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleSend() async {
    setState(() {
      _errorMessage = null;
      _isSending = true;
    });
    
    try {
      // Validate inputs
      final recipientText = _recipientController.text.trim();
      final amountText = _amountController.text.trim();
      
      if (recipientText.isEmpty) {
        throw Exception('Please enter a recipient address');
      }
      
      if (amountText.isEmpty) {
        throw Exception('Please enter an amount');
      }
      
      // Parse recipient address
      EthereumAddress recipient;
      try {
        recipient = EthereumAddress.fromHex(recipientText);
      } catch (e) {
        throw Exception('Invalid recipient address format');
      }
      
      // Parse amount
      double amount;
      try {
        amount = double.parse(amountText);
      } catch (e) {
        throw Exception('Invalid amount format');
      }
      
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      
      // Check if sufficient balance
      if (_tokenBalance != null && _tokenDecimals != null) {
        final maxAmount = _tokenService.fromTokenUnits(_tokenBalance!, _tokenDecimals!);
        if (amount > maxAmount) {
          throw Exception('Insufficient token balance');
        }
      }
      
      // Check if sufficient gas
      final nativeBalanceEth = _nativeBalance?.getValueInUnit(EtherUnit.ether) ?? 0.0;
      if (nativeBalanceEth < 0.0001) {
        throw Exception('Insufficient ${BSCConfig.nativeSymbol} for gas');
      }
      
      // Send transaction
      final txHash = await _tokenService.transfer(
        credentials: widget.credentials,
        recipient: recipient,
        amount: amount,
      );
      
      setState(() {
        _txHash = txHash;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
  
  void _openExplorer() {
    if (_txHash == null) return;
    
    final url = BSCConfig.getTxUrl(_txHash!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open in browser: $url'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
