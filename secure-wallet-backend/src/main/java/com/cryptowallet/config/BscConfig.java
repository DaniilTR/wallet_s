package com.cryptowallet.config;

public class BscConfig {
    public static final String[] RPC_URLS = new String[] {
        "https://data-seed-prebsc-1-s1.binance.org:8545/",
        "https://data-seed-prebsc-2-s1.binance.org:8545/",
        "https://bsc-testnet.publicnode.com"
    };

    public static final int CHAIN_ID = 97;

    // Контракт токена BEP-20 из задачи
    public static final String TOKEN_CONTRACT = "0xf9Db015ae3D2B413FcA691022c610422FFab4368";
}
