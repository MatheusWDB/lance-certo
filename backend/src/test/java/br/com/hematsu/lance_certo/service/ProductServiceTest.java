package br.com.hematsu.lance_certo.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;

import br.com.hematsu.lance_certo.dto.product.ProductRequestDTO;
import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.exception.ResourceNotFoundException;
import br.com.hematsu.lance_certo.mapper.ProductMapper;
import br.com.hematsu.lance_certo.model.Product;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.ProductRepository;

class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;
    @Mock
    private ProductMapper productMapper;
    @Mock
    private UserService userService;

    @InjectMocks
    private ProductService productService;

    private User userSeller;
    private Product existingProduct;

    @BeforeEach
    void setup() {

        MockitoAnnotations.openMocks(this);

        userSeller = new User();
        userSeller.setId(1L);

        existingProduct = new Product();
        existingProduct.setId(10L);
        existingProduct.setSeller(userSeller);
    }

    @Test
    @DisplayName("")
    void testCreateProduct_1() {

        ProductRequestDTO productDTO = new ProductRequestDTO(null, null, null, null);
        Long sellerId = userSeller.getId();

        when(userService.findById(sellerId)).thenReturn(userSeller);
        when(productMapper.toProduct(any(ProductRequestDTO.class))).thenReturn(new Product());

        productService.createProduct(productDTO, sellerId);

        verify(userService, times(1)).findById(sellerId);
        verify(productMapper, times(1)).toProduct(productDTO);
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    @DisplayName("")
    void testCreateProduct_2() {

        ProductRequestDTO productDTO = new ProductRequestDTO(null, null, null, null);
        Long nonExitingSellerId = 2L;

        when(userService.findById(nonExitingSellerId))
                .thenThrow(new ResourceNotFoundException("Usuário, com o id: " + nonExitingSellerId));

        assertThrows(ResourceNotFoundException.class, () -> {
            productService.createProduct(productDTO, nonExitingSellerId);
        });

        verify(userService, times(1)).findById(nonExitingSellerId);
        verify(productMapper, never()).toProduct(productDTO);
        verify(productRepository, never()).save(any(Product.class));
    }

    @Test
    @DisplayName("")
    void testFindById_1() {

        Long productId = existingProduct.getId();

        when(productRepository.findById(productId)).thenReturn(Optional.of(existingProduct));

        Product result = productService.findById(productId);

        assertEquals(productId, result.getId());

        verify(productRepository, times(1)).findById(productId);
    }

    @Test
    @DisplayName("")
    void testFindById_2() {

        Long nonExistingProductId = 11L;

        when(productRepository.findById(nonExistingProductId))
                .thenThrow(new ResourceNotFoundException("Produto, com o id: " + nonExistingProductId));

        assertThrows(ResourceNotFoundException.class, () -> {
            productService.findById(nonExistingProductId);
        });

        verify(productRepository, times(1)).findById(nonExistingProductId);
    }

    @Test
    @DisplayName("")
    void testFindByNameOrCategory_1() {

        Pageable pageable = Pageable.ofSize(10).withPage(0);
        List<Product> mockProducts = List.of(existingProduct);
        Page<Product> productPage = new PageImpl<Product>(mockProducts, pageable, mockProducts.size());

        ProductResponseDTO expectedProductDTO = new ProductResponseDTO(
                existingProduct.getId(),
                null,
                null,
                null,
                null,
                null);

        when(productRepository.findAll(any(Specification.class), any(Pageable.class))).thenReturn(productPage);
        when(productMapper.toProductResponseDTO(any(Product.class)))
                .thenReturn(expectedProductDTO);

        Page<ProductResponseDTO> resultPage = productService.findByNameOrCategory(any(String.class), any(String.class),
                pageable);

        assertNotNull(resultPage);
        assertFalse(resultPage.isEmpty());

        verify(productRepository, times(1)).findAll(any(Specification.class), eq(pageable));
        verify(productMapper, times(mockProducts.size())).toProductResponseDTO(any(Product.class));
    }

    @Test
    @DisplayName("")
    void testFindProductsBySeller_1() {

        Long sellerId = userSeller.getId();
        List<Product> products = List.of(existingProduct);
        ProductResponseDTO productDTO = new ProductResponseDTO(existingProduct.getId(), null, null, null, null, null);

        when(productRepository.findBySellerId(sellerId)).thenReturn(products);
        when(productMapper.toProductResponseDTO(existingProduct)).thenReturn(productDTO);

        List<ProductResponseDTO> result = productService.findProductsBySeller(sellerId);

        assertTrue(result.contains(productDTO));

        verify(productRepository, times(1)).findBySellerId(sellerId);
        verify(productMapper, times(products.size())).toProductResponseDTO(existingProduct);
    }

    @Test
    @DisplayName("")
    void testSave() {

        when(productRepository.save(existingProduct)).thenReturn(existingProduct);

        productService.save(existingProduct);

        verify(productRepository, times(1)).save(existingProduct);
    }
}
