package br.com.hematsu.lance_certo.dto.product;

import jakarta.validation.constraints.NotBlank;

public record ProductCreateRequestDTO(
                @NotBlank(message = "Product name is required") String name,

                @NotBlank(message = "Product description is required") String description,

                String imageUrl,

                @NotBlank(message = "Product category is required") String category) {
}
