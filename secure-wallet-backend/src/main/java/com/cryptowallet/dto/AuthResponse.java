package com.cryptowallet.dto;

import java.util.List;

/**
 * Ответ аутентификации/регистрации.
 * Расширен: теперь возвращает список кошельков пользователя, чтобы на клиенте не приходилось
 * подставлять какой-либо временный или "жёстко прошитый" адрес.
 */
public class AuthResponse {
    private boolean success;
    private String message;
    private UserDTO user;
    private List<WalletDTO> wallets; // Список актуальных кошельков пользователя
    private String error;

    public AuthResponse() {
    }

    public AuthResponse(boolean success, String message, UserDTO user, List<WalletDTO> wallets, String error) {
        this.success = success;
        this.message = message;
        this.user = user;
        this.wallets = wallets;
        this.error = error;
    }

    // Старый фабричный метод оставляем для совместимости (без кошельков)
    public static AuthResponse success(String message, UserDTO user) {
        return new AuthResponse(true, message, user, null, null);
    }

    // Новый фабричный метод — с кошельками
    public static AuthResponse successWithWallets(String message, UserDTO user, List<WalletDTO> wallets) {
        return new AuthResponse(true, message, user, wallets, null);
    }

    public static AuthResponse error(String message, String error) {
        return new AuthResponse(false, message, null, null, error);
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

    public List<WalletDTO> getWallets() {
        return wallets;
    }

    public String getError() {
        return error;
    }
}
