package br.com.hematsu.lance_certo.dto.user;

import br.com.hematsu.lance_certo.model.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UserRegistrationRequestDTO(
        @NotBlank(message = "Username is required") @Size(min = 4, max = 50, message = "Username must be between 4 and 50 characters") String username,

        @NotBlank(message = "Password is required") @Size(min = 8, message = "Password must be at least 8 characters long") String password,

        @NotBlank(message = "Email is required") @Email(message = "Invalid email format") String email,

        @NotBlank(message = "Name is required") String name,

        // Valide o Role se o usuário puder escolher (ex: BUYER/SELLER).
        // Se o role for atribuído pelo backend, talvez não precise aqui.
        // @NotNull(message = "Role is required")
        UserRole role, // Pode ser removido se o backend atribuir o role (ex: sempre BUYER ou SELLER no
                       // registro)

        @NotBlank(message = "Phone is required") String phone) {

}
