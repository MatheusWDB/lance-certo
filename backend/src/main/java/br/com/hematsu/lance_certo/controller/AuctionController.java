package br.com.hematsu.lance_certo.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.service.AuctionService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/auctions")
public class AuctionController {

    private final AuctionService auctionService;

    public AuctionController(AuctionService auctionService) {
        this.auctionService = auctionService;
    }

    @PostMapping("/sellers/{sellerId}")
    public ResponseEntity<Void> createAuction(@PathVariable Long sellerId,
            @RequestBody @Valid AuctionCreateRequestDTO auctionDTO) {

        auctionService.createAuction(auctionDTO, sellerId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<AuctionDetailsResponseDTO> getAuctionDetailsById(@PathVariable Long id){

        AuctionDetailsResponseDTO auction = auctionService.findAuctionDetailsById(id);
        return ResponseEntity.status(HttpStatus.OK).body(auction);
    }

    @PutMapping("/cancel/{id}/sellers/{sellerId}")
    public ResponseEntity<Void> cancelAuction(@PathVariable Long id, @PathVariable Long sellerId){

        auctionService.cancelAuction(id, sellerId);
        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
