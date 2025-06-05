package br.com.hematsu.lance_certo.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.exception.ResourceNotFoundException;
import br.com.hematsu.lance_certo.exception.auction.AuctionCannotBeCancelledException;
import br.com.hematsu.lance_certo.exception.auction.NotAuctionOwnerException;
import br.com.hematsu.lance_certo.exception.auction.ProductAlreadyInAuctionException;
import br.com.hematsu.lance_certo.mapper.AuctionMapper;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;
import br.com.hematsu.lance_certo.model.Product;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.AuctionRepository;
import br.com.hematsu.lance_certo.repository.specs.AuctionSpecifications;
import jakarta.transaction.Transactional;

@Service
public class AuctionService {

    private final AuctionRepository auctionRepository;
    private final AuctionMapper auctionMapper;
    private final ProductService productService;
    private final UserService userService;
    private final SimpMessagingTemplate messagingTemplate;

    public AuctionService(
            AuctionRepository auctionRepository,
            AuctionMapper auctionMapper,
            ProductService productService,
            UserService userService,
            SimpMessagingTemplate messagingTemplate) {

        this.auctionRepository = auctionRepository;
        this.auctionMapper = auctionMapper;
        this.productService = productService;
        this.userService = userService;
        this.messagingTemplate = messagingTemplate;
    }

    @Transactional
    public void createAuction(AuctionCreateRequestDTO auctionDTO, Long sellerId) {

        User seller = userService.findById(sellerId);

        List<Auction> existingAuctionForProduct = auctionRepository.findByProductId(auctionDTO.productId());

        if (!existingAuctionForProduct.isEmpty()) {

            existingAuctionForProduct.forEach(auction -> {
                if (auction.getStatus() == AuctionStatus.PENDING ||
                        auction.getStatus() == AuctionStatus.ACTIVE) {

                    throw new ProductAlreadyInAuctionException();
                }
            });

        }

        Product product = productService.findById(auctionDTO.productId());

        Auction auction = auctionMapper.auctionCreateRequestDTOToAuction(auctionDTO);
        auction.setSeller(seller);
        auction.setProduct(product);
        auction.setStatus(AuctionStatus.PENDING);
        auction.setInitialPrice(auctionDTO.initialPrice());
        auction.setMinimunBidIncrement(auctionDTO.minimunBidIncrement());
        auction.setCurrentBid(BigDecimal.ZERO);
        auction.setCurrentBidder(null);

        auctionRepository.save(auction);
    }

    public Auction findById(Long id) {
        return auctionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Leilão, com o id: " + id));
    }

    public List<AuctionDetailsResponseDTO> findAuctionsBySellerId(Long sellerId) {

        List<Auction> auctions = auctionRepository.findBySellerId(sellerId);
        return auctions.stream().map(auctionMapper::auctionToAuctionDetailsResponseDTO).toList();
    }

    public List<AuctionDetailsResponseDTO> findAuctionsByStatus(AuctionStatus status) {

        List<Auction> auctions = auctionRepository.findByStatus(status);
        return auctions.stream().map(auctionMapper::auctionToAuctionDetailsResponseDTO).toList();
    }

    @Transactional
    public void save(Auction auction) {
        auctionRepository.save(auction);
    }

    public Page<AuctionDetailsResponseDTO> searchAndFilterAuctions(
            String productName,
            String productCategory,
            String sellerName,
            String winnerName,
            String status,
            BigDecimal minInitialPrice,
            BigDecimal maxInitialPrice,
            BigDecimal minCurrentBid,
            BigDecimal maxCurrentBid,
            LocalDateTime minStartTime,
            LocalDateTime maxStartTime,
            LocalDateTime minEndTime,
            LocalDateTime maxEndTime,
            Pageable pageable) {

        List<String> productCategories = null;
        if (productCategory != null && !productCategory.trim().isEmpty()) {
            productCategories = Arrays.stream(productCategory.split(","))
                    .map(String::trim).toList();
        }

        List<AuctionStatus> statuses = null;
        if (status != null && !status.trim().isEmpty()) {
            statuses = Arrays.stream(status.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(s -> AuctionStatus.valueOf(s.toUpperCase()))
                    .filter(s -> s != null)
                    .collect(Collectors.toList());
        }

        Specification<Auction> spec = AuctionSpecifications.withFilters(
                productName,
                productCategories,
                sellerName,
                winnerName,
                statuses,
                minInitialPrice,
                maxInitialPrice,
                minCurrentBid,
                maxCurrentBid,
                minStartTime,
                maxStartTime,
                minEndTime,
                maxEndTime);

        Page<Auction> auctionPage = auctionRepository.findAll(spec, pageable);

        return auctionPage.map(auctionMapper::auctionToAuctionDetailsResponseDTO);
    }

    @Transactional
    @Scheduled(cron = "0 * * * * ?")
    public void processPendingAuctions() {

        List<Auction> auctions = auctionRepository.findByStatusAndStartTimeBefore(AuctionStatus.PENDING,
                LocalDateTime.now());

        if (auctions.isEmpty()) {
            return;
        }

        auctions.forEach(auction -> auction.setStatus(AuctionStatus.ACTIVE));

        auctionRepository.saveAll(auctions);

        auctions.forEach(auction -> {
            AuctionDetailsResponseDTO auctionDTO = auctionMapper.auctionToAuctionDetailsResponseDTO(auction);
            String destination = "/topic/auctions/" + auctionDTO.id() + "/status";
            messagingTemplate.convertAndSend(destination, auctionDTO);
        });
    }

    @Transactional
    @Scheduled(cron = "0 * * * * ?")
    public void processEndingAuctions() {

        List<Auction> auctions = auctionRepository.findByStatusAndEndTimeBefore(AuctionStatus.ACTIVE,
                LocalDateTime.now());

        if (auctions.isEmpty()) {
            return;
        }

        auctions.forEach(auction -> {
            auction.setStatus(AuctionStatus.CLOSED);

            if (auction.getCurrentBid().compareTo(BigDecimal.ZERO) > 0
                    && !auction.getCurrentBidder().equals(auction.getSeller())) {

                auction.setWinner(auction.getCurrentBidder());
            }
        });

        auctionRepository.saveAll(auctions);

        auctions.forEach(auction -> {
            AuctionDetailsResponseDTO auctionDTO = auctionMapper.auctionToAuctionDetailsResponseDTO(auction);
            String destination = "/topic/auctions/" + auctionDTO.id() + "/status";
            messagingTemplate.convertAndSend(destination, auctionDTO);
        });
    }

    @Transactional
    public AuctionDetailsResponseDTO cancelAuction(Long auctionId, Long sellerId) {

        User seller = userService.findById(sellerId);

        Auction auction = findById(auctionId);

        if (!auction.getSeller().equals(seller)) {
            throw new NotAuctionOwnerException();
        }

        if (!auction.getStatus().equals(AuctionStatus.PENDING) || !auction.getBids().isEmpty()) {
            throw new AuctionCannotBeCancelledException();
        }

        auction.setStatus(AuctionStatus.CANCELLED);
        auction = auctionRepository.save(auction);

        return auctionMapper.auctionToAuctionDetailsResponseDTO(auction);
    }
}