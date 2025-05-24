package br.com.hematsu.lance_certo.dto.bid;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

public record PlaceBidRequestDTO(
        @NotNull(message = "Bid amount is required") 
        @DecimalMin(value = "0.01", message = "Bid amount must be positive") 
        BigDecimal amount) {

}
