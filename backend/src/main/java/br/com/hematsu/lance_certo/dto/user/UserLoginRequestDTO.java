package br.com.hematsu.lance_certo.dto.user;

import jakarta.validation.constraints.NotBlank;

public record UserLoginRequestDTO(
        @NotBlank(message = "Login (username or email) is required") 
        String login,

        @NotBlank(message = "Password is required") 
        String password) {
}
