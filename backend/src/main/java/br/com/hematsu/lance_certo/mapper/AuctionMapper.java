package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.model.Auction;

@Mapper(componentModel = "spring", uses = { ProductMapper.class,
        UserMapper.class })
public interface AuctionMapper {

    @Mapping(target = "product", source = "product")
    @Mapping(target = "currentBidder", source = "currentBidder")
    @Mapping(target = "winner", source = "winner")
    AuctionDetailsResponseDTO auctionToAuctionDetailsResponseDTO(Auction auction);

    Auction auctionCreateRequestDTOToAuction(AuctionCreateRequestDTO dto);

}
