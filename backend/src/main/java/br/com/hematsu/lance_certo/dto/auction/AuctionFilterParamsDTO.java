package br.com.hematsu.lance_certo.dto.auction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record AuctionFilterParamsDTO(
        Long sellerId,
        String productName,
        String productCategories,
        String sellerName,
        String winnerName,
        String statuses,
        BigDecimal minInitialPrice,
        BigDecimal maxInitialPrice,
        BigDecimal minCurrentBid,
        BigDecimal maxCurrentBid,
        LocalDateTime minStartTime,
        LocalDateTime maxStartTime,
        LocalDateTime minEndTime,
        LocalDateTime maxEndTime) {

}
