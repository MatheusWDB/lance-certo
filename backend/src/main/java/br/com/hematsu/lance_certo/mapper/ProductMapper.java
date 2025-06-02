package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

import br.com.hematsu.lance_certo.dto.product.ProductRequestDTO;
import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.model.Product;

@Mapper(componentModel = "spring", uses = {UserMapper.class}, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface ProductMapper {

    Product productRequestDTOToEntity(ProductRequestDTO dto);

    Product productResponseDTOToProduct(ProductResponseDTO dto);

    ProductResponseDTO productToProductResponseDTO(Product product);
}
