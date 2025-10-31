package com.cryptowallet.service;

import com.cryptowallet.entity.User;
import com.cryptowallet.exception.BadCredentialsException;
import com.cryptowallet.exception.EmailAlreadyExistsException;
import com.cryptowallet.exception.UserNotFoundException;
import com.cryptowallet.exception.UsernameAlreadyExistsException;
import com.cryptowallet.dto.LoginRequest;
import com.cryptowallet.payload.request.RegisterRequest;
import com.cryptowallet.payload.response.AuthResponse;
import com.cryptowallet.repository.UserRepository;
import com.cryptowallet.security.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import org.slf4j.Logger; // Импортируем Logger
import org.slf4j.LoggerFactory; // Импортируем LoggerFactory

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
            throw new UsernameAlreadyExistsException("Username is already taken!");
        }
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new EmailAlreadyExistsException("Email is already in use!");
        }

        User user = new User();
        user.setUsername(registerRequest.getUsername());
        user.setEmail(registerRequest.getEmail());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        user.setAge(registerRequest.getAge());
        user.setCreatedAt(LocalDateTime.now());

        User newUser = userRepository.save(user);
        walletService.createDefaultWallets(newUser);

        String jwt = jwtUtil.generateTokenForSubject(newUser.getId());
        return new AuthResponse(jwt);
    }

    public AuthResponse loginUser(LoginRequest loginRequest) {
        logger.info("Attempting login for username: {}", loginRequest.getUsername()); // Логируем имя пользователя

        User user = userRepository.findByUsername(loginRequest.getUsername())
                .orElseThrow(() -> new UserNotFoundException("User not found with username: " + loginRequest.getUsername()));

        logger.info("Raw password from request: {}", loginRequest.getPassword()); // Логируем сырой пароль
        logger.info("Hashed password from DB: {}", user.getPassword()); // Логируем хешированный пароль из БД

        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            throw new BadCredentialsException("Invalid password");
        }

        String jwt = jwtUtil.generateTokenForSubject(user.getId());
        return new AuthResponse(jwt);
    }
}
