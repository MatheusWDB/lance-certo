package br.com.hematsu.lance_certo.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.hematsu.lance_certo.model.Product;
import java.util.List;


public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findBySellerId(Long sellerId);
}
