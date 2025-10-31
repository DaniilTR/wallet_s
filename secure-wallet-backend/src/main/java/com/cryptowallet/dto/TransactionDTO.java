package com.cryptowallet.dto;

public class TransactionDTO {
    private String id;
    private String type;
    private Double amount;
    private String address;
    private String status;
    private String timestamp;
    private String currency;

    // Пустой конструктор для десериализации
    public TransactionDTO() {
    }

    // Приватный конструктор для использования билдером
    private TransactionDTO(TransactionDTOBuilder builder) {
        this.id = builder.id;
        this.type = builder.type;
        this.amount = builder.amount;
        this.address = builder.address;
        this.status = builder.status;
        this.timestamp = builder.timestamp;
        this.currency = builder.currency;
    }

    public static TransactionDTOBuilder builder() {
        return new TransactionDTOBuilder();
    }

    // Getters
    public String getId() { return id; }
    public String getType() { return type; }
    public Double getAmount() { return amount; }
    public String getAddress() { return address; }
    public String getStatus() { return status; }
    public String getTimestamp() { return timestamp; }
    public String getCurrency() { return currency; }

    public static class TransactionDTOBuilder {
        private String id;
        private String type;
        private Double amount;
        private String address;
        private String status;
        private String timestamp;
        private String currency;

        public TransactionDTOBuilder id(String id) { this.id = id; return this; }
        public TransactionDTOBuilder type(String type) { this.type = type; return this; }
        public TransactionDTOBuilder amount(Double amount) { this.amount = amount; return this; }
        public TransactionDTOBuilder address(String address) { this.address = address; return this; }
        public TransactionDTOBuilder status(String status) { this.status = status; return this; }
        public TransactionDTOBuilder timestamp(String timestamp) { this.timestamp = timestamp; return this; }
        public TransactionDTOBuilder currency(String currency) { this.currency = currency; return this; }

        public TransactionDTO build() {
            return new TransactionDTO(this);
        }
    }
}
