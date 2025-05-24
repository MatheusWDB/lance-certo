package br.com.hematsu.lance_certo.dto.user;

import br.com.hematsu.lance_certo.model.UserRole;

public record UserResponseDTO(
                Long id,
                String username,
                String email,
                String name,
                UserRole role,
                String phone) {

}
