// src/main/java/com/cryptowallet/dto/AuthDTO.java
package com.cryptowallet.dto;

import lombok.*;
import jakarta.validation.constraints.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50)
    private String username;

    @NotBlank(message = "Email is required")
    @Email
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6)
    private String password;

    @Min(value = 18, message = "You must be at least 18 years old")
    private Integer age;
}

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {
    @NotBlank
    private String username;

    @NotBlank
    private String password;
}

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private boolean success;
    private String message;
    private UserDTO user;
    private String error;

    public static AuthResponse success(String message, UserDTO user) {
        return new AuthResponse(true, message, user, null);
    }

    public static AuthResponse error(String message, String error) {
        return new AuthResponse(false, message, null, error);
    }
}

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDTO {
    private String id;
    private String username;
    private String email;
    private Integer age;
    private String createdAt;
    private String token;
}