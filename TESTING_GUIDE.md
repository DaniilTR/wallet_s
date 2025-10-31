# BSC Testnet Wallet - Testing Guide

## Prerequisites

1. **Flutter SDK**: Version 3.0.0 or higher
2. **Device/Emulator**: Android or iOS device/emulator
3. **Internet Connection**: Required for BSC Testnet RPC access

## Installation Steps

### Step 1: Install Dependencies

```bash
cd secure_wallet
flutter pub get
```

This will install:
- web3dart: ^2.7.3
- flutter_secure_storage: ^9.0.0
- qr_flutter: ^4.1.0

### Step 2: Build and Run

```bash
# For development
flutter run

# For Android APK
flutter build apk

# For iOS
flutter build ios
```

## Testing Workflow

### 1. Access BSC Wallet

1. Launch the app
2. Complete authentication (if required)
3. On the home screen, locate the **BSC Testnet Wallet** card (golden/yellow gradient)
4. Tap the BSC Testnet Wallet card

### 2. Wallet Setup

#### Option A: Create New Wallet

1. Select "Create New" tab
2. Read the information about private key backup
3. Tap "Create Wallet"
4. Wallet is created with a random private key
5. **Important**: Back up your private key (access via settings if implemented)

#### Option B: Import Existing Wallet

1. Select "Import" tab
2. Enter a private key in hex format:
   - Format: `0x` followed by 64 hex characters
   - Example: `0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef`
3. Tap "Import Wallet"
4. If valid, wallet is imported and stored securely

**Test Private Key (for testing only):**
```
0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```
**Address:** `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`

### 3. Receive Tokens

#### Get Test tBNB (for gas):
1. In BSC wallet home, copy your address
2. Visit a BSC Testnet faucet:
   - https://testnet.bnbchain.org/faucet-smart
   - https://www.bnbchain.org/en/testnet-faucet
3. Paste your address and request tBNB
4. Wait a few minutes for the transaction to confirm
5. Refresh wallet to see balance updated

#### Get Test Tokens:
Since the token contract is already deployed, you need tokens sent to your address.
If you have access to the token contract owner, mint tokens to your address.

#### Test Receive Flow:
1. Tap "Receive" button
2. Verify QR code displays your address
3. Verify address is shown correctly
4. Test "Copy Address" button
5. Share QR code/address with another wallet for testing

### 4. Check Balances

1. On BSC Wallet Home screen, verify:
   - Your address is displayed correctly
   - Native Balance shows tBNB amount (should be > 0 after faucet)
   - Token Balance shows token amount (initially 0)
2. Tap refresh icon to reload balances

### 5. Send Tokens

**Prerequisites:**
- Have tBNB for gas (get from faucet)
- Have tokens to send (need to receive first)

**Test Send Flow:**

1. Tap "Send" button
2. Enter recipient address:
   - Format: 0x... (42 characters total)
   - Test address: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`
3. Enter amount:
   - Use small amount for testing (e.g., 0.001)
   - Tap "MAX" to test maximum amount calculation
4. Review:
   - Available balance is shown
   - Gas available (tBNB) is shown
5. Tap "Send"
6. Wait for transaction to process
7. On success:
   - Transaction hash is displayed
   - Tap "View on BscScan" to see transaction details
   - Note: The app shows a snackbar with the URL
8. Return to wallet home and verify balance decreased

### 6. Verify on BscScan

1. Copy your address from wallet
2. Visit: https://testnet.bscscan.com
3. Search for your address
4. Verify:
   - tBNB balance matches app
   - Token balance matches app
   - Transactions appear correctly

## Common Test Scenarios

### Test Case 1: Create and Fund Wallet
1. Create new wallet
2. Copy address
3. Get tBNB from faucet
4. Verify balance updates

### Test Case 2: Import and Check Balance
1. Import test private key (provided above)
2. Verify address is correct
3. Check balances
4. Verify matches BscScan

### Test Case 3: Send with Insufficient Gas
1. Ensure tBNB balance is very low (< 0.0001)
2. Try to send tokens
3. Verify error message about insufficient gas

### Test Case 4: Send Invalid Address
1. Tap Send
2. Enter invalid address (e.g., "invalid")
3. Verify error message

### Test Case 5: Send More Than Balance
1. Tap Send
2. Enter amount > available balance
3. Verify error message

### Test Case 6: QR Code
1. Tap Receive
2. Verify QR code generates
3. Scan with QR reader to verify it contains correct address

## Expected Behavior

### Successful Scenarios
- ✅ Wallet creation generates valid Ethereum address
- ✅ Private key import accepts valid 64-char hex
- ✅ Balances display correctly with proper decimals
- ✅ QR code generates scannable address
- ✅ Token transfer succeeds with sufficient balance and gas
- ✅ Transaction hash is valid and viewable on BscScan

### Error Scenarios
- ❌ Import invalid private key → Error message displayed
- ❌ Send with insufficient balance → Error message displayed
- ❌ Send with insufficient gas → Error message displayed
- ❌ Send to invalid address → Error message displayed
- ❌ Network error → Error message with retry option

## Troubleshooting

### Issue: "No wallet found" error
**Solution**: Create or import a wallet first

### Issue: Balance shows 0 after funding
**Solution**: 
- Tap refresh icon
- Check transaction on BscScan
- Ensure enough confirmations

### Issue: "Insufficient gas" when sending
**Solution**: Get more tBNB from faucet

### Issue: Network timeout
**Solution**: 
- Check internet connection
- RPC endpoint may be slow, retry
- Public RPC has rate limits

### Issue: App crashes on wallet operations
**Solution**:
- Check Flutter version (needs 3.0+)
- Run `flutter clean && flutter pub get`
- Check device permissions for secure storage

## Security Testing

### Test Private Key Storage
1. Create/import wallet
2. Close app completely
3. Reopen app
4. Navigate to BSC wallet
5. Verify it loads without requiring re-import

### Test Address Validation
1. Try to send to these addresses:
   - Empty string → Error
   - "invalid" → Error
   - "0x123" (too short) → Error
   - Valid address → Success

### Test Amount Validation
1. Try to send these amounts:
   - Empty → Error
   - "abc" → Error
   - "-1" → Error
   - "0" → Error
   - Valid amount → Success

## Performance Testing

1. **Load Time**: Wallet home should load in < 3 seconds
2. **Balance Refresh**: Should complete in < 5 seconds
3. **Transaction Submit**: Should return tx hash in < 10 seconds
4. **QR Generation**: Should be instant

## Network Information Verification

On wallet home, scroll down to "Network Information" section and verify:
- Network: BNB Smart Chain Testnet
- Chain ID: 97
- RPC: https://bsc-testnet.publicnode.com
- Token Contract: 0xf9Db015ae3D2B413FcA691022c610422FFab4368

## Testing Checklist

- [ ] Install dependencies successfully
- [ ] App builds without errors
- [ ] BSC wallet card appears on home screen
- [ ] Create new wallet works
- [ ] Import wallet works with valid key
- [ ] Import wallet rejects invalid key
- [ ] Address displays correctly
- [ ] Copy address to clipboard works
- [ ] QR code generates correctly
- [ ] tBNB balance displays after faucet
- [ ] Token balance displays correctly
- [ ] Send validates recipient address
- [ ] Send validates amount
- [ ] Send checks for sufficient balance
- [ ] Send checks for sufficient gas
- [ ] Transaction completes successfully
- [ ] Transaction hash is valid
- [ ] Balance updates after send
- [ ] BscScan link works
- [ ] Wallet persists after app restart
- [ ] All error messages are user-friendly

## Notes

- Use small amounts for testing
- Public RPC may be slow or rate-limited
- Keep test private keys safe (use only for testing)
- Token contract must have tokens minted for testing
- BscScan updates may take a few seconds

## Support

If you encounter issues:
1. Check Flutter doctor: `flutter doctor`
2. Clear build cache: `flutter clean`
3. Reinstall dependencies: `flutter pub get`
4. Check device/emulator logs
5. Verify network connectivity
6. Check BscScan for transaction status
