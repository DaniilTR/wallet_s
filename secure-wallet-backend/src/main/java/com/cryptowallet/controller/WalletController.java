// src/main/java/com/cryptowallet/controller/WalletController.java
package com.cryptowallet.controller;

import com.cryptowallet.dto.*;
import com.cryptowallet.service.WalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import java.util.List;

@RestController
@RequestMapping("/api/wallets")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class WalletController {
    private final WalletService walletService;

    @GetMapping
    public ResponseEntity<List<WalletDTO>> getWallets(Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.ok(walletService.getUserWallets(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<WalletDTO> getWallet(@PathVariable String id, Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.ok(walletService.getWallet(id, userId));
    }

    @PostMapping("/create")
    public ResponseEntity<WalletDTO> createWallet(
            @RequestBody CreateWalletRequest request,
            Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(walletService.createWallet(userId, request));
    }

    @GetMapping("/{id}/transactions")
    public ResponseEntity<List<TransactionDTO>> getWalletTransactions(
            @PathVariable String id,
            Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.ok(walletService.getWalletTransactions(id, userId));
    }
}