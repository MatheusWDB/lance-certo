package br.com.hematsu.lance_certo.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import br.com.hematsu.lance_certo.model.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findBySellerId(Long sellerId);

    List<Product> findByName(String name);

    List<Product> findByCategory(String category);

    @Query("SELECT p FROM tb_products p WHERE (:name = '' OR p.name LIKE %:name%) AND (:category = '' OR p.category = :category)")
    List<Product> findByNameAndCategory(String name, String category);
}
