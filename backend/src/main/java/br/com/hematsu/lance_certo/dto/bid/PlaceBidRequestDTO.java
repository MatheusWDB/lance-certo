package br.com.hematsu.lance_certo.dto.bid;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

public record PlaceBidRequestDTO(
        @NotNull(message = "Bid amount é obrigatório!") 
        @DecimalMin(value = "0.01", message = "Bid precisa ser positivo") 
        BigDecimal amount) {

}
