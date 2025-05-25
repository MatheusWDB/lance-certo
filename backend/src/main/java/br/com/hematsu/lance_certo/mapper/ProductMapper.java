package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;

import br.com.hematsu.lance_certo.dto.product.ProductCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.model.Product;

@Mapper(componentModel = "spring")
public interface ProductMapper {
    Product productCreateRequestDTOToEntity(ProductCreateRequestDTO dto);

    Product productResponseDTOToProduct(ProductResponseDTO dto);

    ProductResponseDTO productToProductResponseDTO(Product product);
}
