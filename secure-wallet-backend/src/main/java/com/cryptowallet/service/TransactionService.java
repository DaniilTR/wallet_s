// src/main/java/com/cryptowallet/service/TransactionService.java
package com.cryptowallet.service;

import com.cryptowallet.dto.*;
import com.cryptowallet.entity.Transaction;
import com.cryptowallet.entity.Wallet;
import com.cryptowallet.entity.User;
import com.cryptowallet.repository.TransactionRepository;
import com.cryptowallet.repository.WalletRepository;
import com.cryptowallet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TransactionService {
    private final TransactionRepository transactionRepository;
    private final WalletRepository walletRepository;
    private final UserRepository userRepository;

    public List<TransactionDTO> getUserTransactions(String userId) {
        return transactionRepository.findByWalletUserIdOrderByTimestampDesc(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TransactionDTO sendTransaction(String userId, SendTransactionRequest request) {
        User user = userRepository.findById(userId).orElseThrow(
                () -> new RuntimeException("User not found"));
        
        Wallet wallet = walletRepository.findById(request.getFromWalletId())
                .orElseThrow(() -> new RuntimeException("Wallet not found"));

        if (!wallet.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized: Wallet does not belong to user");
        }

        if (wallet.getBalance() < request.getAmount()) {
            throw new RuntimeException("Insufficient balance");
        }

        if (request.getAmount() <= 0) {
            throw new RuntimeException("Amount must be greater than 0");
        }

        // Создание транзакции
        Transaction transaction = Transaction.builder()
                .id(UUID.randomUUID().toString())
                .wallet(wallet)
                .type("send")
                .amount(request.getAmount())
                .toAddress(request.getToAddress())
                .status("completed")
                .timestamp(LocalDateTime.now())
                .currency(wallet.getSymbol())
                .build();

        // Обновление баланса кошелька
        wallet.setBalance(wallet.getBalance() - request.getAmount());
        walletRepository.save(wallet);

        // Сохранение транзакции
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