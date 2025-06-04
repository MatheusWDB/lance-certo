package br.com.hematsu.lance_certo.controller;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
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
        return ResponseEntity.status(HttpStatus.OK).body(auctionMapper.auctionToAuctionDetailsResponseDTO(auction));
    }

    @GetMapping("/auctions/seller")
    public ResponseEntity<List<AuctionDetailsResponseDTO>> getMyAuctions() {

        Long sellerId = authenticationService.getIdByAuthentication();

        List<AuctionDetailsResponseDTO> auctions = auctionService.findAuctionsBySellerId(sellerId);
        return ResponseEntity.status(HttpStatus.OK).body(auctions);
    }

    @GetMapping("/auctions")
    public ResponseEntity<Page<AuctionDetailsResponseDTO>> searchAndFilterAuctions(
            @RequestParam(required = false) String productName,
            @RequestParam(required = false) String productCategory,
            @RequestParam(required = false) String sellerName,
            @RequestParam(required = false) String winnerName,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) BigDecimal minInitialPrice,
            @RequestParam(required = false) BigDecimal maxInitialPrice,
            @RequestParam(required = false) BigDecimal minCurrentBid,
            @RequestParam(required = false) BigDecimal maxCurrentBid,
            @RequestParam(required = false) LocalDateTime minStartTime,
            @RequestParam(required = false) LocalDateTime maxStartTime,
            @RequestParam(required = false) LocalDateTime minEndTime,
            @RequestParam(required = false) LocalDateTime maxEndTime,
            Pageable pageable) {

        Page<AuctionDetailsResponseDTO> auctionPage = auctionService.searchAndFilterAuctions(
                productName,
                productCategory,
                sellerName,
                winnerName,
                status,
                minInitialPrice,
                maxInitialPrice,
                minCurrentBid,
                maxCurrentBid,
                minStartTime,
                maxStartTime,
                minEndTime,
                maxEndTime,
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
