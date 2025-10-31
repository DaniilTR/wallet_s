// src/main/java/com/cryptowallet/repository/TransactionRepository.java
package com.cryptowallet.repository;

import com.cryptowallet.entity.Transaction;
import com.cryptowallet.entity.Wallet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, String> {
    List<Transaction> findByWallet(Wallet wallet);
    List<Transaction> findByWalletUserIdOrderByTimestampDesc(String userId);
}