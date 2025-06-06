package br.com.hematsu.lance_certo.repository.specs;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import br.com.hematsu.lance_certo.dto.auction.AuctionFilterParamsDTO;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;

public class AuctionSpecifications {

    private AuctionSpecifications() {
    }

    public static Specification<Auction> hasStatusIn(List<AuctionStatus> statuses) {
        return (root, query, criteriaBuilder) -> {
            if (statuses == null || statuses.isEmpty()) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }

            return root.get("status").in(statuses);
        };
    }

    public static Specification<Auction> productNameLike(String productName) {
        return (root, query, criteriaBuilder) -> {
            if (productName == null || productName.trim().isEmpty()) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
            return criteriaBuilder.like(criteriaBuilder.lower(root.get("product").get("name")),
                    "%" + productName.toLowerCase() + "%");
        };
    }

    public static Specification<Auction> productCategoryIn(List<String> categories) {
        return (root, query, criteriaBuilder) -> {
            if (categories == null || categories.isEmpty()) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }

            return root.get("product").get("category").in(categories);
        };
    }

    public static Specification<Auction> sellerNameLike(String sellerName) {
        return (root, query, criteriaBuilder) -> {
            if (sellerName == null || sellerName.trim().isEmpty()) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
            return criteriaBuilder.like(criteriaBuilder.lower(root.get("seller").get("name")),
                    "%" + sellerName.toLowerCase() + "%");
        };
    }

    public static Specification<Auction> winnerNameLike(String winnerName) {
        return (root, query, criteriaBuilder) -> {
            if (winnerName == null || winnerName.trim().isEmpty()) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }

            return criteriaBuilder.like(criteriaBuilder.lower(root.get("winner").get("name")),
                    "%" + winnerName.toLowerCase() + "%");

        };
    }

    public static Specification<Auction> initialPriceBetween(
            BigDecimal minPrice,
            BigDecimal maxPrice) {

        String attributeName = "initialPrice";

        return (root, query, criteriaBuilder) -> {
            if (minPrice == null && maxPrice == null) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
            if (minPrice != null && maxPrice != null) {
                return criteriaBuilder.between(root.get(attributeName), minPrice, maxPrice);

            }
            if (minPrice != null) {
                return criteriaBuilder.greaterThanOrEqualTo(root.get(attributeName), minPrice);
            }

            return criteriaBuilder.lessThanOrEqualTo(root.get(attributeName), maxPrice);
        };
    }

    public static Specification<Auction> currentBidBetween(BigDecimal minBid, BigDecimal maxBid) {
        String attributeName = "currentBid";

        return (root, query, criteriaBuilder) -> {
            if (minBid == null && maxBid == null) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
            if (minBid != null && maxBid != null) {
                return criteriaBuilder.between(root.get(attributeName), minBid, maxBid);
            }
            if (minBid != null) {
                return criteriaBuilder.greaterThanOrEqualTo(root.get(attributeName), minBid);
            }
            return criteriaBuilder.lessThanOrEqualTo(root.get(attributeName), maxBid);
        };
    }

    public static Specification<Auction> startTimeBetween(
            LocalDateTime minTime,
            LocalDateTime maxTime) {

        String attributeName = "startTime";

        return (root, query, criteriaBuilder) -> {
            if (minTime == null && maxTime == null) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
            if (minTime != null && maxTime != null) {
                return criteriaBuilder.between(root.get(attributeName), minTime, maxTime);
            }
            if (minTime != null) {
                return criteriaBuilder.greaterThanOrEqualTo(root.get(attributeName), minTime);
            }
            return criteriaBuilder.lessThanOrEqualTo(root.get(attributeName), maxTime);
        };
    }

    public static Specification<Auction> endTimeBetween(
            LocalDateTime minTime,
            LocalDateTime maxTime) {

        String attributeName = "endTime";

        return (root, query, criteriaBuilder) -> {
            if (minTime == null && maxTime == null) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
            if (minTime != null && maxTime != null) {
                return criteriaBuilder.between(root.get(attributeName), minTime, maxTime);
            }
            if (minTime != null) {
                return criteriaBuilder.greaterThanOrEqualTo(root.get(attributeName), minTime);
            }
            return criteriaBuilder.lessThanOrEqualTo(root.get(attributeName), maxTime);
        };
    }

    public static Specification<Auction> withFilters(AuctionFilterParamsDTO auctionFilterParamsDTO) {

       List<String> productCategories = null;
        if (auctionFilterParamsDTO.productCategory() != null && !auctionFilterParamsDTO.productCategory().trim().isEmpty()) {
            productCategories = Arrays.stream(auctionFilterParamsDTO.productCategory().split(","))
                    .map(String::trim).toList();
        }

        List<AuctionStatus> statuses = null;
        if (auctionFilterParamsDTO.status() != null && !auctionFilterParamsDTO.status().trim().isEmpty()) {
            statuses = Arrays.stream(auctionFilterParamsDTO.status().split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(s -> AuctionStatus.valueOf(s.toUpperCase()))
                    .filter(s -> s != null)
                    .toList();
        }

        List<Specification<Auction>> specs = new ArrayList<>();

        specs.add(productNameLike(auctionFilterParamsDTO.productName()));
        specs.add(productCategoryIn(productCategories));
        specs.add(sellerNameLike(auctionFilterParamsDTO.sellerName()));
        specs.add(winnerNameLike(auctionFilterParamsDTO.winnerName()));
        specs.add(hasStatusIn(statuses));
        specs.add(initialPriceBetween(auctionFilterParamsDTO.minInitialPrice(), auctionFilterParamsDTO.maxInitialPrice()));
        specs.add(currentBidBetween(auctionFilterParamsDTO.minCurrentBid(), auctionFilterParamsDTO.maxCurrentBid()));
        specs.add(startTimeBetween(auctionFilterParamsDTO.minStartTime(), auctionFilterParamsDTO.maxStartTime()));
        specs.add(endTimeBetween(auctionFilterParamsDTO.minEndTime(), auctionFilterParamsDTO.maxEndTime()));
        
        return Specification.allOf(specs);
    }
}