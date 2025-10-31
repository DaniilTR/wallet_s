package com.cryptowallet.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "transactions")
public class Transaction {
    @Id
    private String id;

    @DBRef(lazy = true)
    private Wallet wallet;

    private String type;

    private Double amount;

    private String toAddress;

    private String status;

    private LocalDateTime timestamp;

    private String currency;

    public Transaction() {
    }

    public Transaction(String id, Wallet wallet, String type, Double amount, String toAddress, String status, LocalDateTime timestamp, String currency) {
        this.id = id;
        this.wallet = wallet;
        this.type = type;
        this.amount = amount;
        this.toAddress = toAddress;
        this.status = status;
        this.timestamp = timestamp;
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
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }
    public String getToAddress() { return toAddress; }
    public void setToAddress(String toAddress) { this.toAddress = toAddress; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public static class TransactionBuilder {
        private String id;
        private Wallet wallet;
        private String type;
        private Double amount;
        private String toAddress;
        private String status;
        private LocalDateTime timestamp;
        private String currency;

        public TransactionBuilder id(String id) { this.id = id; return this; }
        public TransactionBuilder wallet(Wallet wallet) { this.wallet = wallet; return this; }
        public TransactionBuilder type(String type) { this.type = type; return this; }
        public TransactionBuilder amount(Double amount) { this.amount = amount; return this; }
        public TransactionBuilder toAddress(String toAddress) { this.toAddress = toAddress; return this; }
        public TransactionBuilder status(String status) { this.status = status; return this; }
        public TransactionBuilder timestamp(LocalDateTime timestamp) { this.timestamp = timestamp; return this; }
        public TransactionBuilder currency(String currency) { this.currency = currency; return this; }

        public Transaction build() {
            return new Transaction(id, wallet, type, amount, toAddress, status, timestamp, currency);
        }
    }
}
