// java
// Файл: src/main/java/com/cryptowallet/controller/AuthController.java
package com.cryptowallet.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.cryptowallet.service.AuthService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    // Конструкторная инъекция — решает ошибку "variable authService not initialized in the default constructor"
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // Добавьте эндпоинты ниже по необходимости
}
