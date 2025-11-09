package com.cryptowallet.entity;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.FieldType;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Document(collection = "transactions")
public class Transaction {
    @Id
    private String id;

    @DBRef(lazy = true)
    private Wallet wallet;

    // Для совместимости со схемой БД явно храним идентификатор кошелька
    private String walletId;

    private String type;

    // Decimal128 в Mongo для сумм
    @Field(targetType = FieldType.DECIMAL128)
    private BigDecimal amount;

    private String toAddress;

    private String status;

    private LocalDateTime timestamp;

    @CreatedDate
    private LocalDateTime createdAt;

    private String currency;

    public Transaction() {
    }

    public Transaction(String id, Wallet wallet, String walletId, String type, BigDecimal amount, String toAddress, String status, LocalDateTime timestamp, LocalDateTime createdAt, String currency) {
        this.id = id;
        this.wallet = wallet;
        this.walletId = walletId;
        this.type = type;
        this.amount = amount;
        this.toAddress = toAddress;
        this.status = status;
        this.timestamp = timestamp;
        this.createdAt = createdAt;
        this.currency = currency;
    }

    public static TransactionBuilder builder() {
        return new TransactionBuilder();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public Wallet getWallet() { return wallet; }
    public void setWallet(Wallet wallet) { this.wallet = wallet; }
    public String getWalletId() { return walletId; }
    public void setWalletId(String walletId) { this.walletId = walletId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getToAddress() { return toAddress; }
    public void setToAddress(String toAddress) { this.toAddress = toAddress; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public static class TransactionBuilder {
        private String id;
        private Wallet wallet;
        private String walletId;
        private String type;
        private BigDecimal amount;
        private String toAddress;
        private String status;
        private LocalDateTime timestamp;
        private LocalDateTime createdAt;
        private String currency;

        public TransactionBuilder id(String id) { this.id = id; return this; }
        public TransactionBuilder wallet(Wallet wallet) { this.wallet = wallet; return this; }
        public TransactionBuilder walletId(String walletId) { this.walletId = walletId; return this; }
        public TransactionBuilder type(String type) { this.type = type; return this; }
        public TransactionBuilder amount(BigDecimal amount) { this.amount = amount; return this; }
        public TransactionBuilder toAddress(String toAddress) { this.toAddress = toAddress; return this; }
        public TransactionBuilder status(String status) { this.status = status; return this; }
        public TransactionBuilder timestamp(LocalDateTime timestamp) { this.timestamp = timestamp; return this; }
        public TransactionBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public TransactionBuilder currency(String currency) { this.currency = currency; return this; }

        public Transaction build() {
            return new Transaction(id, wallet, walletId, type, amount, toAddress, status, timestamp, createdAt, currency);
        }
    }
}
