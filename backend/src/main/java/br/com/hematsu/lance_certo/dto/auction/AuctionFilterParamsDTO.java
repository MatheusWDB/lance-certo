package br.com.hematsu.lance_certo.dto.auction;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record AuctionFilterParamsDTO(String productName,
        String productCategory,
        String sellerName,
        String winnerName,
        String status,
        BigDecimal minInitialPrice,
        BigDecimal maxInitialPrice,
        BigDecimal minCurrentBid,
        BigDecimal maxCurrentBid,
        LocalDateTime minStartTime,
        LocalDateTime maxStartTime,
        LocalDateTime minEndTime,
        LocalDateTime maxEndTime) {

}
