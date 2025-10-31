// java
package com.cryptowallet.service;

import com.cryptowallet.dto.*;
import com.cryptowallet.entity.Transaction;
import com.cryptowallet.entity.Wallet;
import com.cryptowallet.repository.TransactionRepository;
import com.cryptowallet.repository.WalletRepository;
import com.cryptowallet.repository.UserRepository;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import java.math.BigDecimal;

@Service
public class TransactionService {
    private final TransactionRepository transactionRepository;
    private final WalletRepository walletRepository;
    private final UserRepository userRepository;
    private final BscService bscService;

    public TransactionService(TransactionRepository transactionRepository,
                              WalletRepository walletRepository,
                              UserRepository userRepository,
                              BscService bscService) {
        this.transactionRepository = transactionRepository;
        this.walletRepository = walletRepository;
        this.userRepository = userRepository;
        this.bscService = bscService;
    }

    public List<TransactionDTO> getUserTransactions(String userId) {
        return transactionRepository.findByWalletUserIdOrderByTimestampDesc(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TransactionDTO sendTransaction(String userId, SendTransactionRequest request) {
        userRepository.findById(userId).orElseThrow(
                () -> new RuntimeException("User not found"));

        Wallet wallet = walletRepository.findById(request.getFromWalletId())
                .orElseThrow(() -> new RuntimeException("Wallet not found"));

        if (!wallet.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized: Wallet does not belong to user");
        }

        BigDecimal amount = BigDecimal.valueOf(request.getAmount());
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Amount must be greater than 0");
        }

        // Проверяем баланс ончейн (а не локальный wallet.balance)
        BigDecimal onchainBalance;
        try {
            if (wallet.getSymbol() != null && wallet.getSymbol().equalsIgnoreCase("BNB")) {
                onchainBalance = bscService.getNativeBalanceBNB(wallet.getAddress());
            } else {
                onchainBalance = bscService.getTokenBalance(wallet.getAddress());
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to fetch on-chain balance: " + e.getMessage());
        }

        if (onchainBalance.compareTo(amount) < 0) {
            throw new RuntimeException("Insufficient balance");
        }

        Transaction transaction = Transaction.builder()
                .id(UUID.randomUUID().toString())
                .wallet(wallet)
                .type("send")
                .amount(request.getAmount())
                .toAddress(request.getToAddress())
                // Пока отправка ончейн не реализована, помечаем завершённой для демонстрации
                .status("completed")
                .timestamp(LocalDateTime.now())
                .currency(wallet.getSymbol())
                .build();

        Transaction savedTransaction = transactionRepository.save(transaction);
        return convertToDTO(savedTransaction);
    }

    private TransactionDTO convertToDTO(Transaction tx) {
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
