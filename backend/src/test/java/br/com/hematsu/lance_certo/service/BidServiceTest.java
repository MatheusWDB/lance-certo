package br.com.hematsu.lance_certo.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import br.com.hematsu.lance_certo.dto.bid.BidFilterParamsDTO;
import br.com.hematsu.lance_certo.dto.bid.BidResponseDTO;
import br.com.hematsu.lance_certo.exception.ResourceNotFoundException;
import br.com.hematsu.lance_certo.exception.bid.InvalidBidException;
import br.com.hematsu.lance_certo.mapper.BidMapper;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;
import br.com.hematsu.lance_certo.model.Bid;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.BidRepository;

class BidServiceTest {

    @Mock
    private BidRepository bidRepository;
    @Mock
    private BidMapper bidMapper;
    @Mock
    private AuctionService auctionService;
    @Mock
    private UserService userService;
    @Mock
    private SimpMessagingTemplate messagingTemplate;

    @InjectMocks
    private BidService bidService;

    private Auction existingAuction;
    private User userBidder;
    private Bid existingBid;
    
    @BeforeEach
    void setup() {

        MockitoAnnotations.openMocks(this);

        existingAuction = new Auction();
        existingAuction.setId(1L);
        existingAuction.setStatus(AuctionStatus.ACTIVE);
        existingAuction.setSeller(new User());
        existingAuction.setEndDateAndTime(LocalDateTime.now().plusDays(1));
        existingAuction.setInitialPrice(BigDecimal.ZERO);
        existingAuction.setMinimunBidIncrement(BigDecimal.ZERO);
        existingAuction.setCurrentBid(BigDecimal.ZERO);        

        userBidder = new User();
        userBidder.setId(10L);

        existingBid = new Bid();
        existingBid.setId(100L);      
    }

    @Test
    @DisplayName("")
    void testFindBids_() {

        BidFilterParamsDTO filterParams = new BidFilterParamsDTO(null, 10L);
        Pageable pageable = Pageable.ofSize(10).withPage(0);

        List<Bid> mockBids = List.of(existingBid);
        Page<Bid> bidPage = new PageImpl<Bid>(mockBids, pageable, mockBids.size());
        BidResponseDTO expectedBidDTO = new BidResponseDTO(
                existingBid.getId(),
                null,
                null,
                null,
                null);

        when(bidRepository.findAll(any(Specification.class), any(Pageable.class))).thenReturn(bidPage);
        when(bidMapper.toBidResponseDTO(any(Bid.class)))
                .thenReturn(expectedBidDTO);

        Page<BidResponseDTO> resultPage = bidService.findBids(filterParams, pageable);

        assertNotNull(resultPage);
        assertFalse(resultPage.isEmpty());

        verify(bidRepository, times(1)).findAll(any(Specification.class), eq(pageable));
        verify(bidMapper, times(mockBids.size())).toBidResponseDTO(any(Bid.class));        
    }

    @Test
    @DisplayName("")
    void testPlaceBid_() {

        Long auctionId = existingAuction.getId();
        BigDecimal amount = BigDecimal.ONE;
        Long bidderId = userBidder.getId();

        Bid newBid = new Bid(existingAuction, userBidder, amount);
        newBid.setId(10000L);
        BidResponseDTO bidDTO = new BidResponseDTO(newBid.getId(), null, null, amount, null);

        when(auctionService.findById(auctionId)).thenReturn(existingAuction);
        when(userService.findById(bidderId)).thenReturn(userBidder);
        when(bidRepository.save(any(Bid.class))).thenReturn(newBid);
        when(bidMapper.toBidResponseDTO(any(Bid.class))).thenReturn(bidDTO);

        BidResponseDTO result = bidService.placeBid(auctionId, amount, bidderId);

        assertEquals(result.id(), newBid.getId());

        verify(auctionService, times(1)).findById(auctionId);
        verify(userService, times(1)).findById(bidderId);
        verify(bidRepository, times(1)).save(any(Bid.class));
        verify(auctionService, times(1)).save(any(Auction.class));
        verify(bidMapper, times(1)).toBidResponseDTO(newBid);
        verify(messagingTemplate, times(1)).convertAndSend("/topic/bids/auctions/" + auctionId, result);
    }

    @Test
    @DisplayName("")
    void testPlaceBid_2() {

        Long nonExistingAuctionId = 11L;
        BigDecimal amount = BigDecimal.ONE;
        Long bidderId = userBidder.getId();

        when(auctionService.findById(nonExistingAuctionId))
                .thenThrow(new ResourceNotFoundException("Leilão, com o id: " + nonExistingAuctionId));

        assertThrows(ResourceNotFoundException.class, () -> {
            bidService.placeBid(nonExistingAuctionId, amount, bidderId);
        });

        verify(auctionService, times(1)).findById(nonExistingAuctionId);
        verify(userService, never()).findById(bidderId);
        verify(bidRepository, never()).save(any(Bid.class));
        verify(auctionService, never()).save(any(Auction.class));
        verify(bidMapper, never()).toBidResponseDTO(any(Bid.class));
        verify(messagingTemplate, never()).convertAndSend(any(String.class), any(BidResponseDTO.class));
    }

    @Test
    @DisplayName("")
    void testPlaceBid_3() {

        Auction irregularAuction = new Auction();
        irregularAuction.setId(10000L);
        irregularAuction.setStatus(AuctionStatus.CLOSED);

        Long auctionId = irregularAuction.getId();
        BigDecimal amount = BigDecimal.ONE;
        Long bidderId = userBidder.getId();

        when(auctionService.findById(auctionId)).thenReturn(irregularAuction);
        when(userService.findById(bidderId)).thenReturn(userBidder);

        assertThrows(InvalidBidException.class, () -> {
            bidService.placeBid(auctionId, amount, bidderId);
        });

        verify(auctionService, times(1)).findById(auctionId);
        verify(userService, times(1)).findById(bidderId);
        verify(bidRepository, never()).save(any(Bid.class));
        verify(auctionService, never()).save(any(Auction.class));
        verify(bidMapper, never()).toBidResponseDTO(any(Bid.class));
        verify(messagingTemplate, never()).convertAndSend(any(String.class), any(BidResponseDTO.class));
    }

    @Test
    @DisplayName("")
    void testPlaceBid_4() {

        Auction irregularAuction = new Auction();
        irregularAuction.setId(10000L);
        irregularAuction.setStatus(AuctionStatus.ACTIVE);
        irregularAuction.setEndDateAndTime(LocalDateTime.now().minusMinutes(1));

        Long auctionId = irregularAuction.getId();
        BigDecimal amount = BigDecimal.ONE;
        Long bidderId = userBidder.getId();

        when(auctionService.findById(auctionId)).thenReturn(irregularAuction);
        when(userService.findById(bidderId)).thenReturn(userBidder);

        assertThrows(InvalidBidException.class, () -> {
            bidService.placeBid(auctionId, amount, bidderId);
        });

        verify(auctionService, times(1)).findById(auctionId);
        verify(userService, times(1)).findById(bidderId);
        verify(bidRepository, never()).save(any(Bid.class));
        verify(auctionService, never()).save(any(Auction.class));
        verify(bidMapper, never()).toBidResponseDTO(any(Bid.class));
        verify(messagingTemplate, never()).convertAndSend(any(String.class), any(BidResponseDTO.class));
    }

    @Test
    @DisplayName("")
    void testPlaceBid_5() {

        Auction irregularAuction = new Auction();
        irregularAuction.setId(10000L);
        irregularAuction.setStatus(AuctionStatus.ACTIVE);
        irregularAuction.setEndDateAndTime(LocalDateTime.now().plusDays(1));
        irregularAuction.setSeller(userBidder);

        Long auctionId = irregularAuction.getId();
        BigDecimal amount = BigDecimal.ONE;
        Long bidderId = userBidder.getId();

        when(auctionService.findById(auctionId)).thenReturn(irregularAuction);
        when(userService.findById(bidderId)).thenReturn(userBidder);

        assertThrows(InvalidBidException.class, () -> {
            bidService.placeBid(auctionId, amount, bidderId);
        });

        verify(auctionService, times(1)).findById(auctionId);
        verify(userService, times(1)).findById(bidderId);
        verify(bidRepository, never()).save(any(Bid.class));
        verify(auctionService, never()).save(any(Auction.class));
        verify(bidMapper, never()).toBidResponseDTO(any(Bid.class));
        verify(messagingTemplate, never()).convertAndSend(any(String.class), any(BidResponseDTO.class));
    }

    @Test
    @DisplayName("")
    void testPlaceBid_6() {

        Auction irregularAuction = new Auction();
        irregularAuction.setId(10000L);
        irregularAuction.setStatus(AuctionStatus.ACTIVE);
        irregularAuction.setEndDateAndTime(LocalDateTime.now().plusDays(1));
        irregularAuction.setSeller(new User());
        irregularAuction.setMinimunBidIncrement(BigDecimal.ONE);
        irregularAuction.setInitialPrice(BigDecimal.ONE);

        Long auctionId = irregularAuction.getId();
        BigDecimal amount = BigDecimal.ONE;
        Long bidderId = userBidder.getId();

        when(auctionService.findById(auctionId)).thenReturn(irregularAuction);
        when(userService.findById(bidderId)).thenReturn(userBidder);

        assertThrows(InvalidBidException.class, () -> {
            bidService.placeBid(auctionId, amount, bidderId);
        });

        verify(auctionService, times(1)).findById(auctionId);
        verify(userService, times(1)).findById(bidderId);
        verify(bidRepository, never()).save(any(Bid.class));
        verify(auctionService, never()).save(any(Auction.class));
        verify(bidMapper, never()).toBidResponseDTO(any(Bid.class));
        verify(messagingTemplate, never()).convertAndSend(any(String.class), any(BidResponseDTO.class));
    }

    @Test
    @DisplayName("")
    void testPlaceBid_7() {

        Auction irregularAuction = new Auction();
        irregularAuction.setId(10000L);
        irregularAuction.setStatus(AuctionStatus.ACTIVE);
        irregularAuction.setEndDateAndTime(LocalDateTime.now().plusDays(1));
        irregularAuction.setSeller(new User());
        irregularAuction.setMinimunBidIncrement(BigDecimal.ONE);        
        irregularAuction.setInitialPrice(BigDecimal.ONE);
        irregularAuction.setCurrentBid(BigDecimal.TWO);

        Long auctionId = irregularAuction.getId();
        BigDecimal amount = BigDecimal.ONE;
        Long bidderId = userBidder.getId();

        when(auctionService.findById(auctionId)).thenReturn(irregularAuction);
        when(userService.findById(bidderId)).thenReturn(userBidder);

        assertThrows(InvalidBidException.class, () -> {
            bidService.placeBid(auctionId, amount, bidderId);
        });

        verify(auctionService, times(1)).findById(auctionId);
        verify(userService, times(1)).findById(bidderId);
        verify(bidRepository, never()).save(any(Bid.class));
        verify(auctionService, never()).save(any(Auction.class));
        verify(bidMapper, never()).toBidResponseDTO(any(Bid.class));
        verify(messagingTemplate, never()).convertAndSend(any(String.class), any(BidResponseDTO.class));
    }
}
