package com.cryptowallet.service;

import com.cryptowallet.dto.*;
import com.cryptowallet.entity.Wallet;
import com.cryptowallet.entity.User;
import com.cryptowallet.entity.Transaction;
import com.cryptowallet.repository.WalletRepository;
import com.cryptowallet.repository.UserRepository;
import com.cryptowallet.repository.TransactionRepository;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import java.security.SecureRandom; // Импортируем SecureRandom
import java.util.HexFormat; // Импортируем HexFormat для Java 17+
import java.math.BigDecimal;

@Service
public class WalletService {
    private final WalletRepository walletRepository;
    private final UserRepository userRepository;
    private final TransactionRepository transactionRepository;

    public WalletService(WalletRepository walletRepository,
                         UserRepository userRepository,
                         TransactionRepository transactionRepository) {
        this.walletRepository = walletRepository;
        this.userRepository = userRepository;
        this.transactionRepository = transactionRepository;
    }

    public void createDefaultWallets(User user) {
        // Создание USDT кошелька
        createWalletInternal(user, "My USDT", "USDT", "USDT", BigDecimal.ZERO);

        // Создание ETH кошелька
        createWalletInternal(user, "My EDA", "EDA", "EDA", BigDecimal.ZERO);
    }

    public List<WalletDTO> getUserWallets(String userId) {
        User user = userRepository.findById(userId).orElseThrow();
        return walletRepository.findByUser(user).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public WalletDTO getWallet(String walletId, String userId) {
        User user = userRepository.findById(userId).orElseThrow();
        Wallet wallet = walletRepository.findByIdAndUser(walletId, user)
                .orElseThrow(() -> new RuntimeException("Wallet not found"));
        return convertToDTO(wallet);
    }

    public WalletDTO createWallet(String userId, CreateWalletRequest request) {
        User user = userRepository.findById(userId).orElseThrow();
        Wallet wallet = createWalletInternal(user, request.getName(),
                request.getCurrency(), request.getCurrency(), BigDecimal.ZERO);
        return convertToDTO(wallet);
    }

    private Wallet createWalletInternal(User user, String name, String currency, String symbol, BigDecimal balance) {
        Wallet wallet = Wallet.builder()
                .id(UUID.randomUUID().toString())
                .name(name)
                .currency(currency)
                .symbol(symbol)
                .balance(balance)
                .address(generateWalletAddress())
                .user(user)
                .userId(user.getId())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        return walletRepository.save(wallet);
    }

    public List<TransactionDTO> getWalletTransactions(String walletId, String userId) {
        User user = userRepository.findById(userId).orElseThrow();
        Wallet wallet = walletRepository.findByIdAndUser(walletId, user)
                .orElseThrow(() -> new RuntimeException("Wallet not found"));

        return transactionRepository.findByWallet(wallet).stream()
                .map(this::convertTransactionToDTO)
                .collect(Collectors.toList());
    }

    // Исправленный метод для генерации адреса кошелька
    private String generateWalletAddress() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[20]; // 20 байт = 40 шестнадцатеричных символов
        random.nextBytes(bytes);
        return "0x" + HexFormat.of().formatHex(bytes); // Преобразуем байты в шестнадцатеричную строку
    }

    private WalletDTO convertToDTO(Wallet wallet) {
        return WalletDTO.builder()
                .id(wallet.getId())
                .name(wallet.getName())
                .currency(wallet.getCurrency())
                .symbol(wallet.getSymbol())
                .balance(wallet.getBalance() != null ? wallet.getBalance().doubleValue() : 0.0)
                .address(wallet.getAddress())
                .build();
    }

    private TransactionDTO convertTransactionToDTO(Transaction tx) {
        DateTimeFormatter formatter = DateTimeFormatter.ISO_DATE_TIME;
        return TransactionDTO.builder()
                .id(tx.getId())
                .type(tx.getType())
                .amount(tx.getAmount())
                .address(tx.getToAddress())
                .status(tx.getStatus())
                .timestamp(tx.getTimestamp().format(formatter))
                .currency(tx.getCurrency())
                .build();
    }
}
