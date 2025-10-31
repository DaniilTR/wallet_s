package com.cryptowallet.dto;

public class ImportWalletRequest {
    private String name;      // произвольное имя кошелька в UI
    private String address;   // EVM адрес 0x...
    private String currency;  // полное имя, например Binance Coin
    private String symbol;    // BNB или T1PS

    public ImportWalletRequest() {}

    public String getName() { return name; }
    public String getAddress() { return address; }
    public String getCurrency() { return currency; }
    public String getSymbol() { return symbol; }
}
