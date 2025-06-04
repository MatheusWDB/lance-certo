package br.com.hematsu.lance_certo.repository.specs;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import br.com.hematsu.lance_certo.model.Bid;

public class BidSpecifications {

    public static Specification<Bid> bidId(Long bidderId) {

        return (root, query, criteriaBuilder) -> {
            return criteriaBuilder.equal(root.get("bidder").get("id"), bidderId);
        };
    }

    public static Specification<Bid> auctionId(Long auctionId) {

        return (root, query, criteriaBuilder) -> {
            return criteriaBuilder.equal(root.get("auction").get("id"), auctionId);
        };
    }

    public static Specification<Bid> withFilters(String entity, Long id) {

        List<Specification<Bid>> specs = new ArrayList<>();
        specs.add("bid".equals(entity) ? bidId(id) : auctionId(id));

        return Specification.allOf(specs);
    }
}
