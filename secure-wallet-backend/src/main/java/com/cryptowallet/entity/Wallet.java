package com.cryptowallet.entity;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.CompoundIndexes;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.FieldType;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Document(collection = "wallets")
@CompoundIndexes({
    // Разрешаем один и тот же address использовать для разных символов и/или пользователей,
    // но запрещаем дубликаты в рамках одной пары (userId,address,symbol)
    @CompoundIndex(name = "user_address_symbol_unique", def = "{ 'userId': 1, 'address': 1, 'symbol': 1 }", unique = true)
})
public class Wallet {
    @Id
    private String id;

    // Для схемы БД требуется явное поле userId
    private String userId;

    @DBRef(lazy = true)
    private User user;

    private String name;

    private String currency;

    private String symbol;

    // Decimal128 в Mongo — явно указываем тип для поля
    @Field(targetType = FieldType.DECIMAL128)
    private BigDecimal balance;

    // Индекс без уникальности: уникальность обеспечивается составным индексом выше
    @Indexed
    private String address;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Transient
    private List<Transaction> transactions;

    // Приватный конструктор для использования билдером
    private Wallet(WalletBuilder builder) {
        this.id = builder.id;
    this.user = builder.user;
    this.userId = builder.userId;
        this.name = builder.name;
        this.currency = builder.currency;
        this.symbol = builder.symbol;
        this.balance = builder.balance;
        this.address = builder.address;
        this.createdAt = builder.createdAt;
    this.updatedAt = builder.updatedAt;
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
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getSymbol() { return symbol; }
    public void setSymbol(String symbol) { this.symbol = symbol; }
    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal balance) { this.balance = balance; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public List<Transaction> getTransactions() { return transactions; }
    public void setTransactions(List<Transaction> transactions) { this.transactions = transactions; }

    // Вложенный статический класс Builder
    public static class WalletBuilder {
        private String id;
        private String userId;
        private User user;
        private String name;
        private String currency;
        private String symbol;
        private BigDecimal balance;
        private String address;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        private List<Transaction> transactions;

        public WalletBuilder id(String id) {
            this.id = id;
            return this;
        }

        public WalletBuilder user(User user) {
            this.user = user;
            return this;
        }
        public WalletBuilder userId(String userId) {
            this.userId = userId;
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

        public WalletBuilder balance(BigDecimal balance) {
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
        public WalletBuilder updatedAt(LocalDateTime updatedAt) {
            this.updatedAt = updatedAt;
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
