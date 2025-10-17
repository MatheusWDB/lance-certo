package br.com.hematsu.lance_certo.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

import br.com.hematsu.lance_certo.model.Product;

public interface ProductRepository extends JpaRepository<Product, Long>, JpaSpecificationExecutor<Product> {

    @Query("SELECT p FROM tb_products p WHERE p.seller.id = :sellerId AND p.id NOT IN (SELECT a.product.id FROM tb_auctions a)")
    List<Product> findBySellerId(Long sellerId);

    @NonNull
    Page<Product> findAll(@Nullable Specification<Product> spec, @NonNull Pageable pageable);
}
