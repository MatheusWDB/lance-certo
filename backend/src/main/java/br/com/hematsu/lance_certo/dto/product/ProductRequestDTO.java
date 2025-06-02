package br.com.hematsu.lance_certo.dto.product;

import jakarta.validation.constraints.NotBlank;

public record ProductRequestDTO(
                @NotBlank(message = "Product name é obrigatório!") String name,

                @NotBlank(message = "Product description é obrigatório!") String description,

                String imageUrl,

                @NotBlank(message = "Product category é obrigatório!") String category) {
}
