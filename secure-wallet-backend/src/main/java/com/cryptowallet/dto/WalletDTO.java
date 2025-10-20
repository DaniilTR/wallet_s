// src/main/java/com/cryptowallet/dto/WalletDTO.java
package com.cryptowallet.dto;

import lombok.*;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WalletDTO {
    private String id;
    private String name;
    private String currency;
    private String symbol;
    private Double balance;
    private String address;
    private List<TransactionDTO> transactions;
}

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateWalletRequest {
    private String name;
    private String currency;
}

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionDTO {
    private String id;
    private String type;
    private Double amount;
    private String address;
    private String status;
    private String timestamp;
    private String currency;
}

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SendTransactionRequest {
    private String fromWalletId;
    private String toAddress;
    private Double amount;
}