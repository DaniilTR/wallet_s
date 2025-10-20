package com.cryptowallet.dto;

public class AuthResponse {
    private boolean success;
    private String message;
    private UserDTO user;
    private String error;

    public AuthResponse() {
    }

    public AuthResponse(boolean success, String message, UserDTO user, String error) {
        this.success = success;
        this.message = message;
        this.user = user;
        this.error = error;
    }

    public static AuthResponse success(String message, UserDTO user) {
        return new AuthResponse(true, message, user, null);
    }

    public static AuthResponse error(String message, String error) {
        return new AuthResponse(false, message, null, error);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public UserDTO getUser() {
        return user;
    }

    public String getError() {
        return error;
    }
}
