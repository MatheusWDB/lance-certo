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
import jakarta.persistence.criteria.Expression;

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

    public static Specification<Auction> sellerIdEquals(Long sellerId) {
        return (root, query, criteriaBuilder) -> {
            if (sellerId == null) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
            return criteriaBuilder.equal(root.get("seller").get("id"), sellerId);
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

    public static Specification<Auction> minCurrentBidBetween(BigDecimal minBid, BigDecimal maxBid) {
        String currentBidAttribute = "currentBid";
        String minIncrementAttribute = "minimunBidIncrement";

        return (root, query, criteriaBuilder) -> {
            if (minBid == null && maxBid == null) {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }

            Expression<BigDecimal> currentBidPath = root.get(currentBidAttribute);
            Expression<BigDecimal> minIncrementPath = root.get(minIncrementAttribute);

            if (minBid != null && maxBid != null) {
                Expression<BigDecimal> lowerBound = criteriaBuilder.sum(
                        criteriaBuilder.literal(minBid),
                        minIncrementPath);

                Expression<BigDecimal> upperBound = criteriaBuilder.sum(
                        criteriaBuilder.literal(maxBid),
                        minIncrementPath);

                return criteriaBuilder.between(currentBidPath, lowerBound, upperBound);
            }

            if (minBid != null) {
                Expression<BigDecimal> lowerBound = criteriaBuilder.sum(
                        criteriaBuilder.literal(minBid),
                        minIncrementPath);

                return criteriaBuilder.greaterThanOrEqualTo(currentBidPath, lowerBound);
            }

            Expression<BigDecimal> upperBound = criteriaBuilder.sum(
                    criteriaBuilder.literal(maxBid),
                    minIncrementPath);

            return criteriaBuilder.lessThanOrEqualTo(currentBidPath, upperBound);
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
        if (auctionFilterParamsDTO.productCategories() != null
                && !auctionFilterParamsDTO.productCategories().trim().isEmpty()) {
            productCategories = Arrays.stream(auctionFilterParamsDTO.productCategories().split(","))
                    .map(String::trim).toList();
        }

        List<AuctionStatus> statuses = null;
        if (auctionFilterParamsDTO.statuses() != null && !auctionFilterParamsDTO.statuses().trim().isEmpty()) {
            statuses = Arrays.stream(auctionFilterParamsDTO.statuses().split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(s -> AuctionStatus.valueOf(s.toUpperCase()))
                    .filter(s -> s != null)
                    .toList();
        }

        List<Specification<Auction>> specs = new ArrayList<>();

        specs.add(sellerIdEquals(auctionFilterParamsDTO.sellerId()));
        specs.add(productNameLike(auctionFilterParamsDTO.productName()));
        specs.add(productCategoryIn(productCategories));
        specs.add(sellerNameLike(auctionFilterParamsDTO.sellerName()));
        specs.add(winnerNameLike(auctionFilterParamsDTO.winnerName()));
        specs.add(hasStatusIn(statuses));
        specs.add(initialPriceBetween(auctionFilterParamsDTO.minInitialPrice(),
                auctionFilterParamsDTO.maxInitialPrice()));
        specs.add(minCurrentBidBetween(auctionFilterParamsDTO.minCurrentBid(), auctionFilterParamsDTO.maxCurrentBid()));
        specs.add(startTimeBetween(auctionFilterParamsDTO.minStartTime(), auctionFilterParamsDTO.maxStartTime()));
        specs.add(endTimeBetween(auctionFilterParamsDTO.minEndTime(), auctionFilterParamsDTO.maxEndTime()));

        return Specification.allOf(specs);
    }
}