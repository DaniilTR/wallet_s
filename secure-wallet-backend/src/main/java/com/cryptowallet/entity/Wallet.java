package com.cryptowallet.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;
import java.util.List;

@Document(collection = "wallets")
public class Wallet {
    @Id
    private String id;

    @DBRef(lazy = true)
    private User user;

    private String name;

    private String currency;

    private String symbol;

    private Double balance;

    @Indexed(unique = true)
    private String address;

    private LocalDateTime createdAt;

    @Transient
    private List<Transaction> transactions;

    // Приватный конструктор для использования билдером
    private Wallet(WalletBuilder builder) {
        this.id = builder.id;
        this.user = builder.user;
        this.name = builder.name;
        this.currency = builder.currency;
        this.symbol = builder.symbol;
        this.balance = builder.balance;
        this.address = builder.address;
        this.createdAt = builder.createdAt;
        this.transactions = builder.transactions;
    }

    // Пустой конструктор для JPA
    public Wallet() {
    }

    // Статический метод для получения билдера
    public static WalletBuilder builder() {
        return new WalletBuilder();
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getSymbol() { return symbol; }
    public void setSymbol(String symbol) { this.symbol = symbol; }
    public Double getBalance() { return balance; }
    public void setBalance(Double balance) { this.balance = balance; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public List<Transaction> getTransactions() { return transactions; }
    public void setTransactions(List<Transaction> transactions) { this.transactions = transactions; }

    // Вложенный статический класс Builder
    public static class WalletBuilder {
        private String id;
        private User user;
        private String name;
        private String currency;
        private String symbol;
        private Double balance;
        private String address;
        private LocalDateTime createdAt;
        private List<Transaction> transactions;

        public WalletBuilder id(String id) {
            this.id = id;
            return this;
        }

        public WalletBuilder user(User user) {
            this.user = user;
            return this;
        }

        public WalletBuilder name(String name) {
            this.name = name;
            return this;
        }

        public WalletBuilder currency(String currency) {
            this.currency = currency;
            return this;
        }

        public WalletBuilder symbol(String symbol) {
            this.symbol = symbol;
            return this;
        }

        public WalletBuilder balance(Double balance) {
            this.balance = balance;
            return this;
        }

        public WalletBuilder address(String address) {
            this.address = address;
            return this;
        }

        public WalletBuilder createdAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public WalletBuilder transactions(List<Transaction> transactions) {
            this.transactions = transactions;
            return this;
        }

        public Wallet build() {
            return new Wallet(this);
        }
    }
}
