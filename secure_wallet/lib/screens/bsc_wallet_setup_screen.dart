import 'package:flutter/material.dart';
import '../services/crypto_wallet_service.dart';
import 'bsc_wallet_home_screen.dart';

/// Screen for creating or importing a BSC wallet
class BSCWalletSetupScreen extends StatefulWidget {
  const BSCWalletSetupScreen({super.key});

  @override
  State<BSCWalletSetupScreen> createState() => _BSCWalletSetupScreenState();
}

class _BSCWalletSetupScreenState extends State<BSCWalletSetupScreen> {
  final CryptoWalletService _walletService = CryptoWalletService();
  final TextEditingController _privateKeyController = TextEditingController();
  
  bool _isCreating = true;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BSC Wallet Setup'),
        backgroundColor: const Color(0xFF0098EA),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildTabButtons(),
              const SizedBox(height: 24),
              if (_isCreating) _buildCreateSection() else _buildImportSection(),
              const SizedBox(height: 16),
              if (_errorMessage != null) _buildErrorMessage(),
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF0B90B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            size: 40,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'BNB Smart Chain',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Testnet Wallet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildTabButton(
            label: 'Create New',
            isSelected: _isCreating,
            onTap: () => setState(() {
              _isCreating = true;
              _errorMessage = null;
            }),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTabButton(
            label: 'Import',
            isSelected: !_isCreating,
            onTap: () => setState(() {
              _isCreating = false;
              _errorMessage = null;
            }),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0098EA) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCreateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a New Wallet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'A new wallet will be created with a random private key. Make sure to back up your private key securely.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Import Existing Wallet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _privateKeyController,
          decoration: InputDecoration(
            labelText: 'Private Key (0x...)',
            hintText: '0x followed by 64 hex characters',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.vpn_key),
          ),
          obscureText: true,
          maxLines: 1,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Never share your private key with anyone. We will store it securely on your device.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorMessage() {
    return Container(
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
    );
  }
  
  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0098EA),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              _isCreating ? 'Create Wallet' : 'Import Wallet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
  
  Future<void> _handleAction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (_isCreating) {
        await _walletService.createWallet();
      } else {
        final privateKey = _privateKeyController.text.trim();
        if (privateKey.isEmpty) {
          throw Exception('Please enter a private key');
        }
        await _walletService.importWallet(privateKey);
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BSCWalletHomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
