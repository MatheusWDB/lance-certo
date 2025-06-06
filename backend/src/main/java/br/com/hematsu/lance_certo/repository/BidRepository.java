package br.com.hematsu.lance_certo.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

import br.com.hematsu.lance_certo.model.Bid;

public interface BidRepository extends JpaRepository<Bid, Long>, JpaSpecificationExecutor<Bid> {

    List<Bid> findByBidderId(Long bidderId);

    @NonNull
    Page<Bid> findAll(@Nullable Specification<Bid> spec, @NonNull Pageable pageable);
}
