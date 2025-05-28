package br.com.hematsu.lance_certo.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.bid.BidResponseDTO;
import br.com.hematsu.lance_certo.dto.bid.PlaceBidRequestDTO;
import br.com.hematsu.lance_certo.service.BidService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/bids")
public class BidController {

    private final BidService bidService;

    public BidController(BidService bidService) {
        this.bidService = bidService;
    }

    @PostMapping("/auctions/{auctionId}/bidders/{bidderId}")
    public ResponseEntity<Void> placeBid(@PathVariable Long auctionId, @PathVariable Long bidderId, @RequestBody @Valid PlaceBidRequestDTO bidDTO){

        bidService.placeBid(auctionId, bidDTO.amount(), bidderId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/auctions/{auctionId}")
    public ResponseEntity<List<BidResponseDTO>> getBidHistoryForAuction(@PathVariable Long auctionId){
        
        List<BidResponseDTO> bids = bidService.getBidHistoryForAuction(auctionId);
        return ResponseEntity.status(HttpStatus.OK).body(bids);
    }
}
