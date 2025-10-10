package br.com.hematsu.lance_certo.dto.user;

import br.com.hematsu.lance_certo.model.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UserRegistrationRequestDTO(

                @NotBlank(message = "Username é obrigatório!") @Size(min = 4, max = 50, message = "Username precisa ter entre 4 e 50 caracteres") String username,

                @NotBlank(message = "Password é obrigatório!") @Size(min = 8, message = "Password precisa ter no mínimo 8 caracteres") String password,

                @NotBlank(message = "Email é obrigatório!") @Email(message = "Formato de email inválido") String email,

                @NotBlank(message = "Name é obrigatório!") String name,

                UserRole role,

                @NotBlank(message = "Phone é obrigatório!") String phone) {

}
