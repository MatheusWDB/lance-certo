package br.com.hematsu.lance_certo.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.service.AuctionService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/auctions")
public class AuctionController {

    private final AuctionService auctionService;

    public AuctionController(AuctionService auctionService) {
        this.auctionService = auctionService;
    }

    @PostMapping("/sellers")
    public ResponseEntity<Void> createAuction(@RequestBody @Valid AuctionCreateRequestDTO auctionDTO) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User authenticatedUser = (User) authentication.getPrincipal();
        Long sellerId = authenticatedUser.getId();

        auctionService.createAuction(auctionDTO, sellerId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<AuctionDetailsResponseDTO> getAuctionDetailsById(@PathVariable Long id) {

        AuctionDetailsResponseDTO auction = auctionService.findAuctionDetailsById(id);
        return ResponseEntity.status(HttpStatus.OK).body(auction);
    }

    @PutMapping("{id}/cancel")
    public ResponseEntity<Void> cancelAuction(@PathVariable Long id) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User authenticatedUser = (User) authentication.getPrincipal();
        Long sellerId = authenticatedUser.getId();

        auctionService.cancelAuction(id, sellerId);
        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
