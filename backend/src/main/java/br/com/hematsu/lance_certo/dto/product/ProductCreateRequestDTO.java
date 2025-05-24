package br.com.hematsu.lance_certo.dto.product;

import jakarta.validation.constraints.NotBlank;

public record ProductCreateRequestDTO(
        @NotBlank(message = "Product name is required")
        String name,

        @NotBlank(message = "Product description is required")
        String description,

        String imageUrl,

        @NotBlank(message = "Product category is required")
        String category

// O initialPrice pertence ao Leilão, não ao Produto em si.
// Deveria estar no DTO de criação de Leilão.
// @NotNull(message = "Initial price is required for auction") // Validação
// @DecimalMin(value = "0.01", message = "Initial price must be positive") //
// Validação
// BigDecimal initialPrice
// REMOVIDO
) {

}
