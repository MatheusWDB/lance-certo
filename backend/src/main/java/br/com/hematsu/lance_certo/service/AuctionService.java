package br.com.hematsu.lance_certo.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.dto.product.ProductResponseDTO;
import br.com.hematsu.lance_certo.mapper.AuctionMapper;
import br.com.hematsu.lance_certo.mapper.ProductMapper;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.AuctionRepository;
import jakarta.transaction.Transactional;

@Service
public class AuctionService {

    private final AuctionRepository auctionRepository;
    private final AuctionMapper auctionMapper;
    private final ProductMapper productMapper;
    private final ProductService productService;
    private final UserService userService;

    public AuctionService(
            AuctionRepository auctionRepository,
            AuctionMapper auctionMapper,
            ProductMapper productMapper,
            ProductService productService,
            UserService userService) {

        this.auctionRepository = auctionRepository;
        this.auctionMapper = auctionMapper;
        this.productMapper = productMapper;
        this.productService = productService;
        this.userService = userService;
    }

    @Transactional
    public void createAuction(AuctionCreateRequestDTO auctionDTO, Long sellerId) {

        ProductResponseDTO product = productService.findById(auctionDTO.productId());
        User seller = userService.findById(sellerId);

        Auction auction = auctionMapper.auctionCreateRequestDTOToAuction(auctionDTO);
        auction.setSeller(seller);
        auction.setProduct(productMapper.productResponseDTOToProduct(product));
        auction.setStatus(AuctionStatus.PENDING);
        auction.setInitialPrice(auctionDTO.initialPrice());
        auction.setMinimunBidIncrement(auctionDTO.minimunBidIncrement());
        auction.setCurrentBid(BigDecimal.ZERO);
        auction.setCurrentBidder(null);

        auctionRepository.save(auction);
    }

    public Auction findById(Long auctionId) {

        return auctionRepository.findById(auctionId).orElseThrow(() -> new RuntimeException());
    }

    public AuctionDetailsResponseDTO findAuctionDetailsById(Long auctionId) {

        Auction auction = auctionRepository.findById(auctionId).orElseThrow(() -> new RuntimeException());
        /*
         * AuctionDetailsResponseDTO auctionDTO = new AuctionDetailsResponseDTO(
         * auction.getId(),
         * productMapper.productToProductResponseDTO(auction.getProduct()),
         * userMapper.userToUserResponseDTO(auction.getSeller()),
         * auction.getStartTime(),
         * auction.getEndTime(),
         * auction.getInitialPrice(),
         * auction.getMinimunBidIncrement(),
         * auction.getCurrentBid(),
         * userMapper.userToUserResponseDTO(auction.getCurrentBidder()),
         * auction.getStatus(),
         * userMapper.userToUserResponseDTO(auction.getWinner()),
         * auction.getCreatedAt(),
         * auction.getUpdatedAt());
         */

        return auctionMapper.auctionToAuctionDetailsResponseDTO(auction);
    }

    @Transactional
    public void save(Auction auction) {

        auctionRepository.save(auction);
    }

    @Transactional
    @Scheduled@Scheduled(cron = "0 * * * * ?")
    public void processPendingAuctions() {

        List<Auction> auctions = auctionRepository.findByStatusAndStartTimeBefore(AuctionStatus.PENDING,
                LocalDateTime.now());
        auctions.forEach(auction -> auction.setStatus(AuctionStatus.ACTIVE));

        auctionRepository.saveAll(auctions);
    }

    @Transactional
    @Scheduled@Scheduled(cron = "0 * * * * ?")
    public void processEndingAuctions() {

        List<Auction> auctions = auctionRepository.findByStatusAndEndTimeBefore(AuctionStatus.ACTIVE,
                LocalDateTime.now());
        auctions.forEach(auction -> {
            auction.setStatus(AuctionStatus.CLOSED);

            if (auction.getCurrentBid().compareTo(BigDecimal.ZERO) > 0
                    && !auction.getCurrentBidder().equals(auction.getSeller()))
                auction.setWinner(auction.getCurrentBidder());
        });

        auctionRepository.saveAll(auctions);
    }

    @Transactional
    public AuctionDetailsResponseDTO cancelAuction(Long auctionId, Long sellerId) {

        Auction auction = auctionRepository.findById(auctionId).orElseThrow(() -> new RuntimeException());

        if (!auction.getSeller().getId().equals(sellerId) ||
                !auction.getStatus().equals(AuctionStatus.PENDING) ||
                !auction.getBids().isEmpty()) {

            throw new RuntimeException();
        }

        auction.setStatus(AuctionStatus.CANCELLED);
        auction = auctionRepository.save(auction);

        return auctionMapper.auctionToAuctionDetailsResponseDTO(auction);
    }
}