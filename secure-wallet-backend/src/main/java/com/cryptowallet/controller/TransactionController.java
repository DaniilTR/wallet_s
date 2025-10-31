package com.cryptowallet.controller;

import com.cryptowallet.dto.*;
import com.cryptowallet.service.TransactionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@CrossOrigin(origins = "*")
public class TransactionController {
    private final TransactionService transactionService;

    // Явный конструктор для корректной инициализации (вместо Lombok)
    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    @GetMapping
    public ResponseEntity<List<TransactionDTO>> getTransactions(Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.ok(transactionService.getUserTransactions(userId));
    }

    @PostMapping("/send")
    public ResponseEntity<TransactionDTO> sendTransaction(
            @RequestBody SendTransactionRequest request,
            Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(transactionService.sendTransaction(userId, request));
    }
}
