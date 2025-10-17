package br.com.hematsu.lance_certo.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;

public interface AuctionRepository extends JpaRepository<Auction, Long>, JpaSpecificationExecutor<Auction> {

    List<Auction> findBySellerId(Long sellerId);

    List<Auction> findByProductId(Long productId);

    List<Auction> findByStatus(AuctionStatus status);

    @Query("SELECT a FROM tb_auctions a WHERE a.status = :status AND a.endDateAndTime <= :endDateAndTime")
    List<Auction> findByStatusAndEndDateAndTimeBefore(AuctionStatus status, LocalDateTime endDateAndTime);

    @Query("SELECT a FROM tb_auctions a WHERE a.status = :status AND a.startDateAndTime <= :startDateAndTime")
    List<Auction> findByStatusAndStartDateAndTimeBefore(AuctionStatus status, LocalDateTime startDateAndTime);

    @NonNull
    @Override
    Page<Auction> findAll(@Nullable Specification<Auction> spec, @NonNull Pageable pageable);
}
