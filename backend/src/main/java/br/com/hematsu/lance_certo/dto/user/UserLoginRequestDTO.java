package br.com.hematsu.lance_certo.dto.user;

import jakarta.validation.constraints.NotBlank;

public record UserLoginRequestDTO(
        @NotBlank(message = "Login (username ou email) é obrigatório!") 
        String login,

        @NotBlank(message = "Password é obrigatório!") 
        String password) {
}
