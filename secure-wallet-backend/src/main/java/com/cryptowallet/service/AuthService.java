
// src/main/java/com/cryptowallet/service/AuthService.java
package com.cryptowallet.service;

import com.cryptowallet.dto.*;
import com.cryptowallet.entity.User;
import com.cryptowallet.repository.UserRepository;
import com.cryptowallet.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final WalletService walletService;

    public AuthResponse register(RegisterRequest request) {
        // Проверка возраста
        if (request.getAge() < 18) {
            return AuthResponse.error("Registration failed", "You must be at least 18 years old");
        }

        // Проверка на дублирование username
        if (userRepository.existsByUsername(request.getUsername())) {
            return AuthResponse.error("Registration failed", "Username already exists");
        }

        // Проверка на дублирование email
        if (userRepository.existsByEmail(request.getEmail())) {
            return AuthResponse.error("Registration failed", "Email already exists");
        }

        // Создание пользователя
        User user = User.builder()
                .id(UUID.randomUUID().toString())
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .age(request.getAge())
                .createdAt(LocalDateTime.now())
                .build();

        User savedUser = userRepository.save(user);

        // Создание дефолтных кошельков (USDT и ETH)
        walletService.createDefaultWallets(savedUser);

        // Генерация токена
        String token = jwtTokenProvider.generateToken(savedUser.getUsername());

        UserDTO userDTO = convertToDTO(savedUser, token);
        return AuthResponse.success("Registration successful", userDTO);
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElse(null);

        if (user == null) {
            return AuthResponse.error("Login failed", "User not found");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return AuthResponse.error("Login failed", "Invalid password");
        }

        String token = jwtTokenProvider.generateToken(user.getUsername());
        UserDTO userDTO = convertToDTO(user, token);
        return AuthResponse.success("Login successful", userDTO);
    }

    private UserDTO convertToDTO(User user, String token) {
        DateTimeFormatter formatter = DateTimeFormatter.ISO_DATE_TIME;
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .age(user.getAge())
                .createdAt(user.getCreatedAt().format(formatter))
                .token(token)
                .build();
    }
}