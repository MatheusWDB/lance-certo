package br.com.hematsu.lance_certo.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import br.com.hematsu.lance_certo.dto.bid.BidResponseDTO;
import br.com.hematsu.lance_certo.mapper.BidMapper;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;
import br.com.hematsu.lance_certo.model.Bid;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.BidRepository;
import jakarta.transaction.Transactional;

@Service
public class BidService {

    private final BidRepository bidRepository;
    private final BidMapper bidMapper;
    private final AuctionService auctionService;
    private final UserService userService;
    private final SimpMessagingTemplate messagingTemplate;

    public BidService(
            BidRepository bidRepository,
            BidMapper bidMapper,
            AuctionService auctionService,
            UserService userService,
            SimpMessagingTemplate messagingTemplate) {

        this.bidRepository = bidRepository;
        this.bidMapper = bidMapper;
        this.auctionService = auctionService;
        this.userService = userService;
        this.messagingTemplate = messagingTemplate;
    }

    @Transactional
    public BidResponseDTO placeBid(Long auctionId, BigDecimal amount, Long bidderId) {

        Auction auction = auctionService.findById(auctionId);
        User bidder = userService.findById(bidderId);

        if (!auction.getStatus().equals(AuctionStatus.ACTIVE) ||
                !auction.getEndTime().isAfter(LocalDateTime.now()) ||
                auction.getSeller().equals(bidder) ||
                amount.compareTo(auction.getInitialPrice().add(auction.getMinimunBidIncrement())) < 0 ||
                amount.compareTo(auction.getCurrentBid().add(auction.getMinimunBidIncrement())) < 0) {

            throw new RuntimeException();
        }

        Bid bid = new Bid(auction, bidder, amount);
        bid = bidRepository.save(bid);

        auction.setCurrentBid(amount);
        auction.setCurrentBidder(bidder);

        auctionService.save(auction);

        String destination = "/topic/bids/auctions/" + auctionId;
        BidResponseDTO bidResponse = bidMapper.bidToBidResponseDTO(bid);
        messagingTemplate.convertAndSend(destination, bidResponse);

        return bidResponse;
    }

    public List<BidResponseDTO> getBidHistoryForAuction(Long auctionId) {
        List<Bid> bids = bidRepository.findByAuctionId(auctionId);

        return bids.stream().map(bid -> bidMapper.bidToBidResponseDTO(bid)).toList();
    }
}
