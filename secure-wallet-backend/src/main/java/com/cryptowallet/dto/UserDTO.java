package com.cryptowallet.dto;

public class UserDTO {
    private String id;
    private String username;
    private String email;
    private Integer age;
    private String createdAt;
    private String token;

    public UserDTO() {
    }

    public UserDTO(String id, String username, String email, Integer age, String createdAt, String token) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.age = age;
        this.createdAt = createdAt;
        this.token = token;
    }

    public static UserDTOBuilder builder() {
        return new UserDTOBuilder();
    }

    public String getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public Integer getAge() {
        return age;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public String getToken() {
        return token;
    }

    public static class UserDTOBuilder {
        private String id;
        private String username;
        private String email;
        private Integer age;
        private String createdAt;
        private String token;

        public UserDTOBuilder id(String id) {
            this.id = id;
            return this;
        }

        public UserDTOBuilder username(String username) {
            this.username = username;
            return this;
        }

        public UserDTOBuilder email(String email) {
            this.email = email;
            return this;
        }

        public UserDTOBuilder age(Integer age) {
            this.age = age;
            return this;
        }

        public UserDTOBuilder createdAt(String createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public UserDTOBuilder token(String token) {
            this.token = token;
            return this;
        }

        public UserDTO build() {
            return new UserDTO(id, username, email, age, createdAt, token);
        }
    }
}
