package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import br.com.hematsu.lance_certo.dto.bid.BidResponseDTO;
import br.com.hematsu.lance_certo.model.Bid;

@Mapper(componentModel = "spring", uses = { UserMapper.class,
            AuctionMapper.class })
public interface BidMapper {

      @Mapping(target = "auction", source = "auction")
      @Mapping(target = "bidder", source = "bidder")
      BidResponseDTO toBidResponseDTO(Bid bid);
}
