// src/main/java/com/cryptowallet/repository/WalletRepository.java
package com.cryptowallet.repository;

import com.cryptowallet.entity.Wallet;
import com.cryptowallet.entity.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface WalletRepository extends MongoRepository<Wallet, String> {
    List<Wallet> findByUser(User user);
    Optional<Wallet> findByIdAndUser(String id, User user);
    Optional<Wallet> findByAddress(String address);
}