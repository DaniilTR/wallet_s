# BSC Testnet Wallet Integration

This document describes the BNB Smart Chain Testnet wallet implementation added to the Secure Wallet app.

## Overview

The wallet supports:
- BNB Smart Chain Testnet (chainId 97)
- Native tBNB balance display
- BEP-20 token integration (contract: 0xf9Db015ae3D2B413FcA691022c610422FFab4368)
- Create/import wallet by private key (no mnemonic support)
- Send/receive tokens with QR code support

## Architecture

### Configuration
- **lib/config/bsc_config.dart**: Network constants
  - RPC: https://bsc-testnet.publicnode.com
  - Chain ID: 97
  - Token contract address
  - Explorer URLs for BscScan

### Services
- **lib/services/web3_service.dart**: Web3 client wrapper
  - Manages Web3Client instance
  - Provides helpers for gas price, balance queries
  
- **lib/services/crypto_wallet_service.dart**: Private key management
  - Create new wallet (random private key)
  - Import wallet from hex private key
  - Secure storage via flutter_secure_storage
  - Address validation
  
- **lib/services/token_service.dart**: ERC-20 token operations
  - Load token metadata (name, symbol, decimals)
  - Get token balance
  - Transfer tokens with gas estimation
  - Unit conversion helpers

### UI Screens
- **lib/screens/bsc_wallet_setup_screen.dart**: Create or import wallet
  - Tab interface for Create/Import
  - Private key input with validation
  - Error handling and user feedback
  
- **lib/screens/bsc_wallet_home_screen.dart**: Main wallet view
  - Address display with copy function
  - Native tBNB balance
  - Token balance
  - Navigation to Send/Receive
  
- **lib/screens/bsc_send_token_screen.dart**: Token transfer
  - Recipient address input
  - Amount input with MAX button
  - Balance validation
  - Gas estimation with 20% buffer
  - Transaction hash display with BscScan link
  
- **lib/screens/bsc_receive_screen.dart**: Receive tokens
  - QR code generation
  - Address display
  - Copy to clipboard
  - Network warnings

### Integration
- Modified **lib/screens/home_screen.dart** to add BSC wallet card
- Automatic detection of existing wallet
- Navigation to setup or home based on wallet state

## Assets
- **assets/abi/erc20.json**: Standard ERC-20 ABI
  - name(), symbol(), decimals()
  - balanceOf(address)
  - transfer(address, uint256)

## Dependencies
Added to pubspec.yaml:
- `web3dart: ^2.7.3` - Ethereum/BSC blockchain interaction
- `flutter_secure_storage: ^9.0.0` - Secure private key storage
- `qr_flutter: ^4.1.0` - QR code generation

## Security Features
- Private keys stored securely using flutter_secure_storage
- Private keys never logged or displayed in UI
- Address format validation (0x + 40 hex chars)
- Private key format validation (64 hex chars)
- Transaction validation before sending

## Usage Flow

### First Time Setup
1. User taps "BSC Testnet Wallet" card on home screen
2. Redirected to setup screen
3. Choose "Create New" or "Import"
4. If importing, enter private key (0x-prefixed hex)
5. Wallet created/imported and stored securely

### Receiving Tokens
1. Navigate to BSC wallet home
2. Tap "Receive" button
3. Share address or QR code
4. Tokens sent to this address appear in balance

### Sending Tokens
1. Navigate to BSC wallet home
2. Tap "Send" button
3. Enter recipient address (0x...)
4. Enter amount in human units
5. Review and confirm
6. Transaction submitted with chainId 97
7. View transaction on BscScan

## Network Configuration
- Network: BNB Smart Chain Testnet
- Chain ID: 97
- RPC URL: https://bsc-testnet.publicnode.com
- Native Token: tBNB (for gas)
- Explorer: https://testnet.bscscan.com
- Token Contract: 0xf9Db015ae3D2B413FcA691022c610422FFab4368

## Testing
To test this implementation:
1. Run `flutter pub get` to install dependencies
2. Build the app: `flutter run` or `flutter build apk/ios`
3. Create or import a wallet
4. Get testnet tBNB from a faucet (for gas)
5. Test token transfers on BSC Testnet

## Notes
- No mnemonic/BIP-39 support (as per requirements)
- Testnet only (no mainnet support)
- Gas estimation includes 20% buffer for reliability
- Token metadata cached after first load
- All transactions use chainId 97 to prevent replay attacks

## Future Enhancements
If needed, potential additions could include:
- Transaction history
- Multiple token support
- Gas price customization
- Account deletion/reset
- Biometric authentication
