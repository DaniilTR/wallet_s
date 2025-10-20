// src/main/java/com/cryptowallet/entity/Transaction.java
package com.cryptowallet.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @Column(nullable = false)
    private String type; // "send" or "receive"

    @Column(nullable = false)
    private Double amount;

    @Column(nullable = false)
    private String toAddress;

    @Column(nullable = false)
    private String status; // "pending", "completed", "failed"

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @Column(nullable = false)
    private String currency;
}