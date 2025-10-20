package com.cryptowallet.dto;

public class CreateWalletRequest {
    private String name;
    private String currency;

    public CreateWalletRequest() {
    }

    public CreateWalletRequest(String name, String currency) {
        this.name = name;
        this.currency = currency;
    }

    public String getName() {
        return name;
    }

    public String getCurrency() {
        return currency;
    }
}
