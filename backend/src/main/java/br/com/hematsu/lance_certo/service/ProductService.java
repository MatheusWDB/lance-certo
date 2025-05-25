package br.com.hematsu.lance_certo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import br.com.hematsu.lance_certo.dto.product.ProductCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.mapper.ProductMapper;
import br.com.hematsu.lance_certo.model.Product;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.ProductRepository;
import jakarta.transaction.Transactional;

@Service
public class ProductService {

    private final ProductRepository productRepository;
    private final ProductMapper productMapper;
    private final UserService userService;

    public ProductService(ProductRepository productRepository, ProductMapper productMapper, UserService userService) {
        this.productRepository = productRepository;
        this.productMapper = productMapper;
        this.userService = userService;
    }

    @Transactional
    public void createProduct(ProductCreateRequestDTO productDTO, Long sellerId) {
        User seller = userService.findById(sellerId);
        Product product = productMapper.productCreateRequestDTOToEntity(productDTO);

        product.setSeller(seller);

        productRepository.save(product);
    }

    public ProductResponseDTO findById(Long id) {
        Product product = productRepository.findById(id).orElseThrow(() -> new RuntimeException());

        return productMapper.productToProductResponseDTO(product);
    }

    public List<ProductResponseDTO> findProductsBySeller(Long sellerId) {
        List<Product> products = productRepository.findBySellerId(sellerId);

        return products.stream().map(product -> productMapper.productToProductResponseDTO(product)).toList();
    }
}
