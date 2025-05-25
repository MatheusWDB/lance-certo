package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.model.Auction;

@Mapper(componentModel = "spring")
public interface AuctionMapper {

    AuctionDetailsResponseDTO acutionToAuctionDetailsResponseDTO(Auction auction);
    
    Auction auctionCreateRequestDTOToAuction(AuctionCreateRequestDTO dto);

    Auction auctionDetailsResponseDTOToAuction(AuctionDetailsResponseDTO dto);
    
}
