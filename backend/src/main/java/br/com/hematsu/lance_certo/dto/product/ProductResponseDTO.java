package br.com.hematsu.lance_certo.dto.product;

import br.com.hematsu.lance_certo.dto.user.UserResponseDTO;

public record ProductResponseDTO(
        Long id,
        String name,
        String description,
        String imageUrl,
        String category,
        UserResponseDTO seller) {

}
