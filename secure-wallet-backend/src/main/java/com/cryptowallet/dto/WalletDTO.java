package com.cryptowallet.dto;

import java.util.List;

public class WalletDTO {
    private String id;
    private String name;
    private String currency;
    private String symbol;
    private Double balance;
    private String address;
    private List<TransactionDTO> transactions;

    public WalletDTO() {
    }

    public WalletDTO(String id, String name, String currency, String symbol, Double balance, String address, List<TransactionDTO> transactions) {
        this.id = id;
        this.name = name;
        this.currency = currency;
        this.symbol = symbol;
        this.balance = balance;
        this.address = address;
        this.transactions = transactions;
    }

    public static WalletDTOBuilder builder() {
        return new WalletDTOBuilder();
    }

    // Getters
    public String getId() { return id; }
    public String getName() { return name; }
    public String getCurrency() { return currency; }
    public String getSymbol() { return symbol; }
    public Double getBalance() { return balance; }
    public String getAddress() { return address; }
    public List<TransactionDTO> getTransactions() { return transactions; }

    public static class WalletDTOBuilder {
        private String id;
        private String name;
        private String currency;
        private String symbol;
        private Double balance;
        private String address;
        private List<TransactionDTO> transactions;

        public WalletDTOBuilder id(String id) { this.id = id; return this; }
        public WalletDTOBuilder name(String name) { this.name = name; return this; }
        public WalletDTOBuilder currency(String currency) { this.currency = currency; return this; }
        public WalletDTOBuilder symbol(String symbol) { this.symbol = symbol; return this; }
        public WalletDTOBuilder balance(Double balance) { this.balance = balance; return this; }
        public WalletDTOBuilder address(String address) { this.address = address; return this; }
        public WalletDTOBuilder transactions(List<TransactionDTO> transactions) { this.transactions = transactions; return this; }

        public WalletDTO build() {
            return new WalletDTO(id, name, currency, symbol, balance, address, transactions);
        }
    }
}
