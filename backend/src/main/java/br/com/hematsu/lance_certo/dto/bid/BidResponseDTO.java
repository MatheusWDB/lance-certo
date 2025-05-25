package br.com.hematsu.lance_certo.dto.bid;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.dto.user.UserResponseDTO;

public record BidResponseDTO(
        Long id,
        AuctionDetailsResponseDTO auction,
        UserResponseDTO bidder,
        BigDecimal amount,
        LocalDateTime createdAt) {
}
