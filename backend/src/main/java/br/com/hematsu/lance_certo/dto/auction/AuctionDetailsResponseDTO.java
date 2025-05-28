package br.com.hematsu.lance_certo.dto.auction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.dto.user.UserResponseDTO;
import br.com.hematsu.lance_certo.model.AuctionStatus;

public record AuctionDetailsResponseDTO(
                Long id,
                ProductResponseDTO product,
                LocalDateTime startTime,
                LocalDateTime endTime,
                BigDecimal initialPrice,
                BigDecimal minimunBidIncrement,
                BigDecimal currentBid,
                UserResponseDTO currentBidder,
                AuctionStatus status,
                UserResponseDTO winner,
                LocalDateTime createdAt,
                LocalDateTime updatedAt) {

}
