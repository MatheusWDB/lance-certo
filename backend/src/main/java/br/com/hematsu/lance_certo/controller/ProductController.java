package br.com.hematsu.lance_certo.controller;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.product.ProductRequestDTO;
import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.mapper.ProductMapper;
import br.com.hematsu.lance_certo.model.Product;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.service.AuthenticationService;
import br.com.hematsu.lance_certo.service.ProductService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class ProductController {

    private final ProductService productService;
    private final ProductMapper productMapper;
    private final AuthenticationService authenticationService;

    public ProductController(ProductService productService, ProductMapper productMapper,
            AuthenticationService authenticationService) {
        this.productService = productService;
        this.productMapper = productMapper;
        this.authenticationService = authenticationService;
    }

    @PostMapping("/products/create/sellers")
    public ResponseEntity<Void> createProducts(@RequestBody @Valid ProductRequestDTO body) {

        Long sellerId = authenticationService.getIdByAuthentication();
        productService.createProduct(body, sellerId);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/products")
    public ResponseEntity<Page<ProductResponseDTO>> getProductsByNameOrCategory(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String category,
            Pageable pageable) {

        if (name.isBlank() && category.isBlank()) {
            throw new IllegalArgumentException("Pelo menos um dos parâmetros precisa ter um valor.");
        }

        Page<ProductResponseDTO> products = productService.findByNameOrCategory(name, category, pageable);
        return ResponseEntity.status(HttpStatus.OK).body(products);
    }

    @GetMapping("/products/seller")
    public ResponseEntity<List<ProductResponseDTO>> getProductsBySeller(
            @RequestParam(name = "seller", required = true) String param) {

        User seller = (User) authenticationService.loadUserByUsername(param);
        Long sellerId = seller.getId();

        List<ProductResponseDTO> products = productService.findProductsBySeller(sellerId);
        return ResponseEntity.status(HttpStatus.OK).body(products);
    }

    @PatchMapping("/products/{id}/update")
    public ResponseEntity<ProductResponseDTO> updateProduct(
            @PathVariable Long id,
            @RequestBody ProductRequestDTO body) {

        Product product = productService.findById(id);
        product.setCategory(body.category());
        product.setName(body.name());
        product.setImageUrl(body.imageUrl());
        product.setDescription(body.description());

        product = productService.save(product);
        return ResponseEntity.status(HttpStatus.OK).body(productMapper.productToProductResponseDTO(product));
    }
}
