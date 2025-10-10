package br.com.hematsu.lance_certo.dto.auction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;

public record AuctionCreateRequestDTO(
        @NotNull(message = "Product ID é obrigatório!") Long productId,

        @NotNull(message = "Start time é obrigatório!") @FutureOrPresent(message = "Start time precisa ser no presente ou no futuro") LocalDateTime startTime,

        @NotNull(message = "End time é obrigatório!") @Future(message = "End time precisa ser no futuro") LocalDateTime endTime,

        @NotNull(message = "Initial price é obrigatório!") @DecimalMin(value = "0.01", message = "Initial price precisa ser positivo") BigDecimal initialPrice,

        @NotNull(message = "Minimum bid increment é obrigatório!") @DecimalMin(value = "0.01", message = "Minimum bid increment precisa ser positivo") BigDecimal minimunBidIncrement) {

    public AuctionCreateRequestDTO {
        if (!endTime.isAfter(startTime)) {
            throw new IllegalArgumentException("End time precisa ser depois de start time");
        }
    }

}
