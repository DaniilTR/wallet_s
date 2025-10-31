package com.cryptowallet.controller;

import com.cryptowallet.exception.BadCredentialsException;
import com.cryptowallet.exception.EmailAlreadyExistsException;
import com.cryptowallet.exception.UserNotFoundException;
import com.cryptowallet.exception.UsernameAlreadyExistsException;
import com.cryptowallet.dto.LoginRequest; // Исправленный импорт
import com.cryptowallet.payload.request.RegisterRequest;
import com.cryptowallet.payload.response.AuthResponse;
import com.cryptowallet.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody RegisterRequest registerRequest) {
        try {
            AuthResponse authResponse = authService.registerUser(registerRequest);
            return ResponseEntity.status(HttpStatus.CREATED).body(authResponse); // Возвращаем 201 Created при успешной регистрации
        } catch (UsernameAlreadyExistsException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage()); // 409 Conflict для существующего имени пользователя
        } catch (EmailAlreadyExistsException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage()); // 409 Conflict для существующего email
        } catch (Exception e) {
            // Общий обработчик для других неожиданных ошибок
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An unexpected error occurred: " + e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody LoginRequest loginRequest) {
        try {
            AuthResponse authResponse = authService.loginUser(loginRequest);
            return ResponseEntity.ok(authResponse); // 200 OK при успешном входе
        } catch (UserNotFoundException | BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage()); // 401 Unauthorized для неверных учетных данных
        } catch (Exception e) {
            // Общий обработчик для других неожиданных ошибок
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An unexpected error occurred: " + e.getMessage());
        }
    }
}
