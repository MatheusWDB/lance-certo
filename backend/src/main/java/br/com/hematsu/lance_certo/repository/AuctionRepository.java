package br.com.hematsu.lance_certo.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;

public interface AuctionRepository extends JpaRepository<Auction, Long> {

    List<Auction> findBySellerId(Long sellerId);

    List<Auction> findByProductId(Long productId);

    List<Auction> findByStatus(AuctionStatus status);

    List<Auction> findByStatusAndEndTimeBefore(AuctionStatus status, LocalDateTime endTime);

    List<Auction> findByStatusAndStartTimeBefore(AuctionStatus status, LocalDateTime startTime);
}
