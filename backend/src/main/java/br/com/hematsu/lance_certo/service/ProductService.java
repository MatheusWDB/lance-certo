package br.com.hematsu.lance_certo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import br.com.hematsu.lance_certo.dto.product.ProductRequestDTO;
import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.exception.ResourceNotFoundException;
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
    public void createProduct(ProductRequestDTO productDTO, Long sellerId) {

        User seller = userService.findById(sellerId);

        Product product = productMapper.productRequestDTOToEntity(productDTO);

        product.setSeller(seller);

        save(product);
    }

    public Product findById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Produto, com o id: " + id));        
    }

    public List<ProductResponseDTO> findProductsBySeller(Long sellerId) {

        List<Product> products = productRepository.findBySellerId(sellerId);
        return products.stream().map(product -> productMapper.productToProductResponseDTO(product)).toList();
    }

    public List<ProductResponseDTO> findByNameOrCategory(String name, String category) {

        List<Product> products = productRepository.findByNameAndCategory(name, category);
        return products.stream().map(productMapper::productToProductResponseDTO).toList();
    }

    @Transactional
    public Product save(Product product) {
        return productRepository.save(product);
    }
}
