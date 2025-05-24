package br.com.hematsu.lance_certo.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.hematsu.lance_certo.model.Bid;

public interface BidRepository extends JpaRepository<Bid, Long> {

    List<Bid> findByAuctionId(Long auctionId);

    List<Bid> findByBidderId(Long bidderId);

    List<Bid> findByAuctionIdOrderByAmountDescCreatedAtAsc(Long auctionId);
}
