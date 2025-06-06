package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.model.Auction;

@Mapper(componentModel = "spring", uses = { ProductMapper.class,
        UserMapper.class }, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface AuctionMapper {

    @Mapping(target = "product", source = "product")
    @Mapping(target = "currentBidder", source = "currentBidder")
    @Mapping(target = "winner", source = "winner")
    AuctionDetailsResponseDTO toAuctionDetailsResponseDTO(Auction auction);

    Auction toAuction(AuctionCreateRequestDTO dto);

}
