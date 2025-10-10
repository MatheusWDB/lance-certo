package br.com.hematsu.lance_certo.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionFilterParamsDTO;
import br.com.hematsu.lance_certo.mapper.AuctionMapper;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.service.AuctionService;
import br.com.hematsu.lance_certo.service.AuthenticationService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class AuctionController {

    private final AuctionService auctionService;
    private final AuctionMapper auctionMapper;
    private final AuthenticationService authenticationService;

    public AuctionController(AuctionService auctionService, AuctionMapper auctionMapper,
            AuthenticationService authenticationService) {
        this.auctionService = auctionService;
        this.auctionMapper = auctionMapper;
        this.authenticationService = authenticationService;
    }

    @PostMapping("/auctions/create/sellers")
    public ResponseEntity<Void> createAuction(@RequestBody @Valid AuctionCreateRequestDTO auctionDTO) {

        Long sellerId = authenticationService.getIdByAuthentication();

        auctionService.createAuction(auctionDTO, sellerId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/auction/{id}")
    public ResponseEntity<AuctionDetailsResponseDTO> getAuctionById(@PathVariable Long id) {

        Auction auction = auctionService.findById(id);
        return ResponseEntity.status(HttpStatus.OK).body(auctionMapper.toAuctionDetailsResponseDTO(auction));
    }

    @GetMapping("/auctions/seller")
    public ResponseEntity<Page<AuctionDetailsResponseDTO>> getMyAuctions() {

        auctionService.processEndingAuctions();
        auctionService.processPendingAuctions();

        Long sellerId = authenticationService.getIdByAuthentication();

        AuctionFilterParamsDTO auctionFilterParamsDTO = new AuctionFilterParamsDTO(sellerId, null, null, null, null,
                null, null, null, null, null, null, null, null, null);
        Pageable pageable = Pageable.unpaged();

        Page<AuctionDetailsResponseDTO> auctionPage = auctionService.searchAndFilterAuctions(
                auctionFilterParamsDTO,
                pageable);

        return ResponseEntity.status(HttpStatus.OK).body(auctionPage);
    }

    @GetMapping("/auctions")
    public ResponseEntity<Page<AuctionDetailsResponseDTO>> searchAndFilterAuctions(
            AuctionFilterParamsDTO auctionFilterParamsDTO,
            Pageable pageable) {

        auctionService.processEndingAuctions();
        auctionService.processPendingAuctions();

        Page<AuctionDetailsResponseDTO> auctionPage = auctionService.searchAndFilterAuctions(
                auctionFilterParamsDTO,
                pageable);

        return ResponseEntity.status(HttpStatus.OK).body(auctionPage);
    }

    @PatchMapping("/auctions/{id}/cancel")
    public ResponseEntity<Void> cancelAuction(@PathVariable Long id) {

        Long sellerId = authenticationService.getIdByAuthentication();

        auctionService.cancelAuction(id, sellerId);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

}
