package br.com.hematsu.lance_certo.repository.specs;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

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

    public static Specification<Auction> withFilters(
            String productName,
            List<String> productCategories,
            String sellerName,
            String winnerName,
            List<AuctionStatus> statuses,
            BigDecimal minInitialPrice, BigDecimal maxInitialPrice,
            BigDecimal minCurrentBid, BigDecimal maxCurrentBid,
            LocalDateTime minStartTime, LocalDateTime maxStartTime,
            LocalDateTime minEndTime, LocalDateTime maxEndTime) {

        List<Specification<Auction>> specs = new ArrayList<>();

        if (productName != null && !productName.trim().isEmpty()) {
            specs.add(productNameLike(productName));
        }
        if (productCategories != null && !productCategories.isEmpty()) {
            specs.add(productCategoryIn(productCategories));
        }
        if (sellerName != null && !sellerName.trim().isEmpty()) {
            specs.add(sellerNameLike(sellerName));
        }
        if (winnerName != null && !winnerName.trim().isEmpty()) {
            specs.add(winnerNameLike(winnerName));
        }
        if (statuses != null && !statuses.isEmpty()) {
            specs.add(hasStatusIn(statuses));
        }
        if (minInitialPrice != null || maxInitialPrice != null) {
            specs.add(initialPriceBetween(minInitialPrice, maxInitialPrice));
        }
        if (minCurrentBid != null || maxCurrentBid != null) {
            specs.add(currentBidBetween(minCurrentBid, maxCurrentBid));
        }
        if (minStartTime != null || maxStartTime != null) {
            specs.add(startTimeBetween(minStartTime, maxStartTime));
        }
        if (minEndTime != null || maxEndTime != null) {
            specs.add(endTimeBetween(minEndTime, maxEndTime));
        }

        return Specification.allOf(specs);
    }
}