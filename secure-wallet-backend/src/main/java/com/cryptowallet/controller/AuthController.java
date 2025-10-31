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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody RegisterRequest registerRequest) {
        try {
            AuthResponse authResponse = authService.registerUser(registerRequest);
            logger.info("Register endpoint: success username={}", registerRequest.getUsername());
            return ResponseEntity.status(HttpStatus.CREATED)
                    .header("X-Log-Message", "Registration successful")
                    .body(authResponse); // Возвращаем 201 Created при успешной регистрации
        } catch (UsernameAlreadyExistsException | EmailAlreadyExistsException e) {
            logger.warn("Register endpoint: conflict username/email={} reason={}", registerRequest.getUsername(), e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .header("X-Log-Message", e.getMessage())
                    .body(e.getMessage()); // 409 Conflict для существующего username/email
        } catch (Exception e) {
            // Общий обработчик для других неожиданных ошибок
            logger.error("Register endpoint: unexpected error username={} err={}", registerRequest.getUsername(), e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .header("X-Log-Message", "An unexpected error occurred: " + e.getMessage())
                    .body("An unexpected error occurred: " + e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody LoginRequest loginRequest) {
        try {
            AuthResponse authResponse = authService.loginUser(loginRequest);
            logger.info("Login endpoint: success username={}", loginRequest.getUsername());
            return ResponseEntity.ok()
                    .header("X-Log-Message", "Login successful")
                    .body(authResponse); // 200 OK при успешном входе
        } catch (UserNotFoundException | BadCredentialsException e) {
            logger.warn("Login endpoint: unauthorized username={} reason={}", loginRequest.getUsername(), e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .header("X-Log-Message", e.getMessage())
                    .body(e.getMessage()); // 401 Unauthorized для неверных учетных данных
        } catch (Exception e) {
            // Общий обработчик для других неожиданных ошибок
            logger.error("Login endpoint: unexpected error username={} err={}", loginRequest.getUsername(), e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .header("X-Log-Message", "An unexpected error occurred: " + e.getMessage())
                    .body("An unexpected error occurred: " + e.getMessage());
        }
    }
}
