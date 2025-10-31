package com.cryptowallet.service;

import com.cryptowallet.entity.User;
import com.cryptowallet.exception.BadCredentialsException;
import com.cryptowallet.exception.EmailAlreadyExistsException;
import com.cryptowallet.exception.UserNotFoundException;
import com.cryptowallet.exception.UsernameAlreadyExistsException;
import com.cryptowallet.dto.LoginRequest;
import com.cryptowallet.payload.request.RegisterRequest;
import com.cryptowallet.dto.UserDTO;
import com.cryptowallet.dto.AuthResponse;
import com.cryptowallet.repository.UserRepository;
import com.cryptowallet.security.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class); // Добавляем логгер

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final WalletService walletService;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtUtil jwtUtil,
                       WalletService walletService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.walletService = walletService;
    }

    public AuthResponse registerUser(RegisterRequest registerRequest) {
        if (userRepository.existsByUsername(registerRequest.getUsername())) {
            logger.warn("Registration failed: username already taken. username={}", registerRequest.getUsername());
            throw new UsernameAlreadyExistsException("Username is already taken!");
        }
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            logger.warn("Registration failed: email already in use. email={}", registerRequest.getEmail());
            throw new EmailAlreadyExistsException("Email is already in use!");
        }

        User user = new User();
        user.setId(java.util.UUID.randomUUID().toString());
        user.setUsername(registerRequest.getUsername());
        user.setEmail(registerRequest.getEmail());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        user.setAge(registerRequest.getAge());
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

    User newUser = userRepository.save(user);
    logger.info("Registration successful: username={}, id={}", newUser.getUsername(), newUser.getId());
        walletService.createDefaultWallets(newUser);

    String jwt = jwtUtil.generateTokenForSubject(newUser.getId());

    UserDTO userDto = UserDTO.builder()
        .id(newUser.getId())
        .username(newUser.getUsername())
        .email(newUser.getEmail())
        .age(newUser.getAge())
        .createdAt(newUser.getCreatedAt() != null ? newUser.getCreatedAt().toString() : null)
        .token(jwt)
        .build();
    return AuthResponse.success("Registration successful", userDto);
    }

    public AuthResponse loginUser(LoginRequest loginRequest) {
    logger.info("Attempting login for username: {}", loginRequest.getUsername());

        User user = userRepository.findByUsername(loginRequest.getUsername())
        .orElseThrow(() -> {
            logger.warn("Login failed: user not found. username={}", loginRequest.getUsername());
            return new UserNotFoundException("User not found with username: " + loginRequest.getUsername());
        });

        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            logger.warn("Login failed: invalid password. username={}", loginRequest.getUsername());
            throw new BadCredentialsException("Invalid password");
        }

    String jwt = jwtUtil.generateTokenForSubject(user.getId());
    logger.info("Login successful: username={}, id={}", user.getUsername(), user.getId());

    // Если у пользователя нет кошельков — создать дефолтные (BNB + T1PS)
    walletService.ensureDefaultWallets(user);

    UserDTO userDto = UserDTO.builder()
        .id(user.getId())
        .username(user.getUsername())
        .email(user.getEmail())
        .age(user.getAge())
        .createdAt(user.getCreatedAt() != null ? user.getCreatedAt().toString() : null)
        .token(jwt)
        .build();

    return AuthResponse.success("Login successful", userDto);
    }
}
