# BSC Wallet Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Flutter Application                          │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                         UI Layer                                │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │ │
│  │  │ BSCWalletSetup  │  │ BSCWalletHome   │  │ BSCSendToken    │ │ │
│  │  │     Screen      │→ │     Screen      │→ │    Screen       │ │ │
│  │  │                 │  │                 │  │                 │ │ │
│  │  │ • Create        │  │ • Address       │  │ • Recipient     │ │ │
│  │  │ • Import        │  │ • tBNB balance  │  │ • Amount        │ │ │
│  │  │                 │  │ • Token balance │  │ • Gas check     │ │ │
│  │  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘ │ │
│  │           │                    │                     │          │ │
│  │  ┌────────┴────────┐  ┌────────┴────────┐           │          │ │
│  │  │  BSCReceive     │  │   Home Screen   │←──────────┘          │ │
│  │  │    Screen       │  │   (Modified)    │                      │ │
│  │  │                 │  │                 │                      │ │
│  │  │ • QR Code       │  │ • BSC Card      │                      │ │
│  │  │ • Address Copy  │  │ • Navigation    │                      │ │
│  │  └─────────────────┘  └─────────────────┘                      │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                    │                                 │
│  ┌────────────────────────────────┴─────────────────────────────┐  │
│  │                      Service Layer                            │  │
│  │  ┌───────────────┐  ┌──────────────┐  ┌──────────────────┐  │  │
│  │  │ CryptoWallet  │  │    Token     │  │      Web3        │  │  │
│  │  │   Service     │  │   Service    │  │    Service       │  │  │
│  │  │               │  │              │  │                  │  │  │
│  │  │ • Create      │  │ • Metadata   │  │ • RPC Client     │  │  │
│  │  │ • Import      │  │ • Balance    │  │ • Gas Price      │  │  │
│  │  │ • Load        │  │ • Transfer   │  │ • Estimate Gas   │  │  │
│  │  │ • Validate    │  │ • Convert    │  │ • Get Balance    │  │  │
│  │  └───────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │  │
│  └──────────┼──────────────────┼──────────────────┼────────────┘  │
│             │                  │                  │                │
│  ┌──────────┴──────────────────┴──────────────────┴────────────┐  │
│  │                    Configuration Layer                       │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │                 BSC Config                            │   │  │
│  │  │  • Network: BSC Testnet                               │   │  │
│  │  │  • Chain ID: 97                                       │   │  │
│  │  │  • RPC: https://bsc-testnet.publicnode.com           │   │  │
│  │  │  • Token: 0xf9Db015ae3D2B413FcA691022c610422FFab4368 │   │  │
│  │  │  • Explorer: https://testnet.bscscan.com             │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                    │                                │
│  ┌────────────────────────────────┴─────────────────────────────┐  │
│  │                      Storage & Assets                         │  │
│  │  ┌───────────────────┐        ┌──────────────────────┐       │  │
│  │  │ Secure Storage    │        │   ERC-20 ABI         │       │  │
│  │  │ (Private Keys)    │        │ (assets/abi/)        │       │  │
│  │  └───────────────────┘        └──────────────────────┘       │  │
│  └──────────────────────────────────────────────────────────────┘  │
└───────────────────────────────┬───────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
         ┌──────────▼─────────┐  ┌─────────▼──────────┐
         │   BSC Testnet      │  │    BscScan API     │
         │   RPC Endpoint     │  │    (Explorer)      │
         │                    │  │                    │
         │ • Native Balance   │  │ • Tx Verification  │
         │ • Token Contract   │  │ • Address Info     │
         │ • Gas Estimation   │  │ • Deep Links       │
         │ • Send Tx          │  │                    │
         └────────────────────┘  └────────────────────┘

═══════════════════════════════════════════════════════════════════

                         Data Flow Diagram

┌─────────────┐
│    User     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│                     USER ACTIONS                                 │
├─────────────────────────────────────────────────────────────────┤
│  Create/Import  │  View Balance  │  Send Token  │  Receive      │
└────────┬────────┴───────┬────────┴──────┬───────┴───────┬───────┘
         │                │               │               │
         ▼                ▼               ▼               ▼
    ┌────────┐      ┌─────────┐     ┌────────┐     ┌──────────┐
    │Crypto  │      │ Token   │     │Token   │     │QR Code   │
    │Wallet  │      │ Service │     │Service │     │Generator │
    │Service │      └────┬────┘     └───┬────┘     └──────────┘
    └───┬────┘           │              │
        │                │              │
        ▼                ▼              ▼
    ┌────────────────────────────────────────┐
    │          Web3 Service                  │
    │  (Web3Client + BSC RPC)               │
    └───────────────┬────────────────────────┘
                    │
                    ▼
    ┌────────────────────────────────────────┐
    │      BSC Testnet Blockchain            │
    │  • Smart Contracts                     │
    │  • Token Contract                      │
    │  • Transaction Pool                    │
    └────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════

                      Transaction Flow

1. CREATE/IMPORT WALLET
   User Input → CryptoWalletService → Generate/Parse Key
   → Store in SecureStorage → Return Credentials

2. LOAD BALANCE
   Address → TokenService.getTokenBalance() → Web3Service
   → RPC Call (balanceOf) → Parse Response → Display

3. SEND TOKEN
   User Input (To, Amount) → Validation → TokenService.transfer()
   → Encode Transaction → Estimate Gas → Sign with Private Key
   → Send via RPC → Return Tx Hash → Show Success + BscScan Link

4. RECEIVE
   Get Address → Generate QR Code → Display → User Shares

═══════════════════════════════════════════════════════════════════

                     Security Architecture

┌─────────────────────────────────────────────────────────────────┐
│                    Security Layers                               │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1: Input Validation                                       │
│  • Address format (0x + 40 hex)                                  │
│  • Private key format (64 hex)                                   │
│  • Amount validation (> 0, <= balance)                           │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2: Secure Storage                                         │
│  • flutter_secure_storage (OS keychain/keystore)                │
│  • Encrypted at rest                                             │
│  • No logging of sensitive data                                  │
├─────────────────────────────────────────────────────────────────┤
│  Layer 3: Transaction Security                                   │
│  • Gas estimation + 20% buffer                                   │
│  • Balance checks before send                                    │
│  • ChainId 97 prevents replay attacks                           │
│  • Signed transactions with private key                          │
├─────────────────────────────────────────────────────────────────┤
│  Layer 4: Network Security                                       │
│  • HTTPS RPC endpoint                                            │
│  • Public RPC (no API keys in code)                              │
│  • Error handling for network issues                             │
└─────────────────────────────────────────────────────────────────┘

```
