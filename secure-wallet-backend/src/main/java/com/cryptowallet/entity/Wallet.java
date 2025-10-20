package com.cryptowallet.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "wallets")
public class Wallet {
    @Id
    private String id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String currency;

    @Column(nullable = false)
    private String symbol;

    @Column(nullable = false)
    private Double balance;

    @Column(nullable = false, unique = true)
    private String address;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "wallet", cascade = CascadeType.ALL)
    private List<Transaction> transactions;

    public Wallet() {
    }

    public Wallet(String id, User user, String name, String currency, String symbol, Double balance, String address, LocalDateTime createdAt, List<Transaction> transactions) {
        this.id = id;
        this.user = user;
        this.name = name;
        this.currency = currency;
        this.symbol = symbol;
        this.balance = balance;
        this.address = address;
        this.createdAt = createdAt;
        this.transactions = transactions;
    }

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

        public WalletBuilder id(String id) { this.id = id; return this; }
        public WalletBuilder user(User user) { this.user = user; return this; }
        public WalletBuilder name(String name) { this.name = name; return this; }
        public WalletBuilder currency(String currency) { this.currency = currency; return this; }
        public WalletBuilder symbol(String symbol) { this.symbol = symbol; return this; }
        public WalletBuilder balance(Double balance) { this.balance = balance; return this; }
        public WalletBuilder address(String address) { this.address = address; return this; }
        public WalletBuilder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public WalletBuilder transactions(List<Transaction> transactions) { this.transactions = transactions; return this; }

        public Wallet build() {
            return new Wallet(id, user, name, currency, symbol, balance, address, createdAt, transactions);
        }
    }
}
