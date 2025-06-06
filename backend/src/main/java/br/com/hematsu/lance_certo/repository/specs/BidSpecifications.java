package br.com.hematsu.lance_certo.repository.specs;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import br.com.hematsu.lance_certo.dto.bid.BidFilterParamsDTO;
import br.com.hematsu.lance_certo.model.Bid;

public class BidSpecifications {

    private BidSpecifications() {
    }

    public static Specification<Bid> bidderIdEquals(Long bidderId) {
        return (root, query, criteriaBuilder) -> {
            if(bidderId == null){
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }

            return criteriaBuilder.equal(root.get("bidder").get("id"), bidderId);
        };
    }

    public static Specification<Bid> auctionIdEquals(Long auctionId) {
        return (root, query, criteriaBuilder) -> { 
            if(auctionId == null){
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
            return criteriaBuilder.equal(root.get("auction").get("id"), auctionId);};
    }

    public static Specification<Bid> withFilters(BidFilterParamsDTO bidParam) {

        List<Specification<Bid>> specs = new ArrayList<>();
        specs.add(bidderIdEquals(bidParam.bidderId()));
        specs.add(auctionIdEquals(bidParam.auctionId()));

        return Specification.allOf(specs);
    }
}
