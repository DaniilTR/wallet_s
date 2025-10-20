package com.cryptowallet.dto;

public class SendTransactionRequest {
    private String fromWalletId;
    private String toAddress;
    private Double amount;

    public SendTransactionRequest() {
    }

    public SendTransactionRequest(String fromWalletId, String toAddress, Double amount) {
        this.fromWalletId = fromWalletId;
        this.toAddress = toAddress;
        this.amount = amount;
    }

    public String getFromWalletId() {
        return fromWalletId;
    }

    public String getToAddress() {
        return toAddress;
    }

    public Double getAmount() {
        return amount;
    }
}
