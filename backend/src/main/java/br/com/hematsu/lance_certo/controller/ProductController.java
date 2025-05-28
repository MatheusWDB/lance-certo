package br.com.hematsu.lance_certo.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.product.ProductCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.service.ProductService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @PostMapping("/sellers/{sellerId}")
    public ResponseEntity<Void> createProduct(@PathVariable Long sellerId,
            @RequestBody @Valid ProductCreateRequestDTO productDTO) {

        productService.createProduct(productDTO, sellerId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductResponseDTO> getProductById(@PathVariable Long id) {

        ProductResponseDTO product = productService.findById(id);
        return ResponseEntity.status(HttpStatus.OK).body(product);
    }

    @GetMapping("/sellers/{sellerId}")
    public ResponseEntity<List<ProductResponseDTO>> getProductsBySeller(@PathVariable Long sellerId) {

        List<ProductResponseDTO> products = productService.findProductsBySeller(sellerId);
        return ResponseEntity.status(HttpStatus.OK).body(products);
    }
}
