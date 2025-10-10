package br.com.hematsu.lance_certo.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.bid.BidFilterParamsDTO;
import br.com.hematsu.lance_certo.dto.bid.BidResponseDTO;
import br.com.hematsu.lance_certo.dto.bid.PlaceBidRequestDTO;
import br.com.hematsu.lance_certo.service.AuctionService;
import br.com.hematsu.lance_certo.service.AuthenticationService;
import br.com.hematsu.lance_certo.service.BidService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class BidController {

    private final BidService bidService;
    private final AuctionService auctionService;
    private final AuthenticationService authenticationService;

    public BidController(BidService bidService, AuctionService auctionService,
            AuthenticationService authenticationService) {
        this.bidService = bidService;
        this.auctionService = auctionService;
        this.authenticationService = authenticationService;
    }

    @PostMapping("/bids/auctions/{auctionId}/bidder")
    public ResponseEntity<Void> placeBid(@PathVariable Long auctionId, @RequestBody @Valid PlaceBidRequestDTO bidDTO) {

        Long bidderId = authenticationService.getIdByAuthentication();

        bidService.placeBid(auctionId, bidDTO.amount(), bidderId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/bids/auctions/{auctionId}")
    public ResponseEntity<Page<BidResponseDTO>> getBidHistoryForAuction(
            @PathVariable Long auctionId,
            BidFilterParamsDTO bidParam) {

        Pageable pageable = Pageable.unpaged(Sort.by("amount").descending());

        Page<BidResponseDTO> bids = bidService.findBids(bidParam, pageable);
        return ResponseEntity.status(HttpStatus.OK).body(bids);
    }

    @GetMapping("/bids/bidder")
    public ResponseEntity<Page<BidResponseDTO>> findMyBids(Pageable pageable) {

        auctionService.processEndingAuctions();
        auctionService.processPendingAuctions();

        Long bidderId = authenticationService.getIdByAuthentication();
        BidFilterParamsDTO bidParam = new BidFilterParamsDTO(bidderId, null);

        Page<BidResponseDTO> bids = bidService.findBids(bidParam, pageable);
        return ResponseEntity.status(HttpStatus.OK).body(bids);
    }
}
