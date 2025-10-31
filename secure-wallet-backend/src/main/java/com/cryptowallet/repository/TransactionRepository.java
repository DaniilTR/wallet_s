// src/main/java/com/cryptowallet/repository/TransactionRepository.java
package com.cryptowallet.repository;

import com.cryptowallet.entity.Transaction;
import com.cryptowallet.entity.Wallet;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TransactionRepository extends MongoRepository<Transaction, String> {
    List<Transaction> findByWallet(Wallet wallet);
    List<Transaction> findByWalletUserIdOrderByTimestampDesc(String userId);
}