package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;

import br.com.hematsu.lance_certo.dto.bid.BidResponseDTO;
import br.com.hematsu.lance_certo.model.Bid;

@Mapper(componentModel = "spring")
public interface BidMapper {

   BidResponseDTO bidToBidResponseDTO(Bid bid);
}
