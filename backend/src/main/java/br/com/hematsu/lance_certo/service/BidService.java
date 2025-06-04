package br.com.hematsu.lance_certo.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import br.com.hematsu.lance_certo.dto.bid.BidResponseDTO;
import br.com.hematsu.lance_certo.exception.bid.InvalidBidException;
import br.com.hematsu.lance_certo.mapper.BidMapper;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;
import br.com.hematsu.lance_certo.model.Bid;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.BidRepository;
import br.com.hematsu.lance_certo.repository.specs.BidSpecifications;
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

        if (!auction.getStatus().equals(AuctionStatus.ACTIVE)) {
            throw new InvalidBidException("O leilão ainda não iniciou!");
        }
        if (!auction.getEndTime().isAfter(LocalDateTime.now())) {
            throw new InvalidBidException("O leilão já encerrou!");
        }
        if (auction.getSeller().equals(bidder)) {
            throw new InvalidBidException("O vendedor não pode dá lance no próprio leilão!");
        }
        if (amount.compareTo(auction.getInitialPrice().add(auction.getMinimunBidIncrement())) < 0) {
            throw new InvalidBidException(
                    "O lance não pode ser menor do quê a soma do preço inicial mais o incremento mínimo!");
        }
        if (amount.compareTo(auction.getCurrentBid().add(auction.getMinimunBidIncrement())) < 0) {
            throw new InvalidBidException(
                    "O lance não pode ser menor do quê a soma do lance atual mais o incremento mínimo!");
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

    public Page<BidResponseDTO> findBids(String entity, Long id, Pageable pageable) {

        Specification<Bid> spec = BidSpecifications.withFilters(entity, id);
        Page<Bid> bids = bidRepository.findAll(spec, pageable);

        return bids.map(bidMapper::bidToBidResponseDTO);
    }

    public List<BidResponseDTO> findBidsByBidder(Long BidderId) {

        List<Bid> bids = bidRepository.findByBidderId(BidderId);

        return bids.stream().map(bidMapper::bidToBidResponseDTO).toList();
    }
}
