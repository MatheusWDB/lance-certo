package br.com.hematsu.lance_certo.dto.auction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;

public record AuctionCreateRequestDTO(
        @NotNull(message = "Product ID is required") Long productId,

        @NotNull(message = "Start time is required") @FutureOrPresent(message = "Start time must be in the present or future") LocalDateTime startTime,

        @NotNull(message = "End time is required") @Future(message = "End time must be in the future") LocalDateTime endTime,

        @NotNull(message = "Initial price is required") @DecimalMin(value = "0.01", message = "Initial price must be positive") BigDecimal initialPrice,

        @NotNull(message = "Minimum bid increment is required") @DecimalMin(value = "0.01", message = "Minimum bid increment must be positive") BigDecimal minimunBidIncrement) {

    public AuctionCreateRequestDTO {
        if (startTime != null && endTime != null && !endTime.isAfter(startTime)) {
            throw new IllegalArgumentException("End time must be after start time");
        }
    }

}
