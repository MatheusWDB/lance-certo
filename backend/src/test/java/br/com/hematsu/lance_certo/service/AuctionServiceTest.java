package br.com.hematsu.lance_certo.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionDetailsResponseDTO;
import br.com.hematsu.lance_certo.dto.auction.AuctionFilterParamsDTO;
import br.com.hematsu.lance_certo.exception.ResourceNotFoundException;
import br.com.hematsu.lance_certo.exception.auction.AuctionCannotBeCancelledException;
import br.com.hematsu.lance_certo.exception.auction.NotAuctionOwnerException;
import br.com.hematsu.lance_certo.exception.auction.ProductAlreadyInAuctionException;
import br.com.hematsu.lance_certo.mapper.AuctionMapper;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;
import br.com.hematsu.lance_certo.model.Bid;
import br.com.hematsu.lance_certo.model.Product;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.model.UserRole;
import br.com.hematsu.lance_certo.repository.AuctionRepository;

class AuctionServiceTest {

    @Mock
    private AuctionRepository auctionRepository;
    @Mock
    private AuctionMapper auctionMapper;
    @Mock
    private ProductService productService;
    @Mock
    private UserService userService;
    @Mock
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    @InjectMocks
    private AuctionService auctionService;

    private User sellerUser;

    private Product product;

    private Auction existingAuction;

    private AuctionCreateRequestDTO auctionCreateDTO;

    @BeforeEach
    void setup() {

        MockitoAnnotations.openMocks(this);

        sellerUser = new User();
        sellerUser.setId(1L);
        sellerUser.setUsername("seller123");
        sellerUser.setRole(UserRole.SELLER);
        sellerUser.setEmail("seller@test.com");

        product = new Product();
        product.setId(10L);
        product.setName("Test Product");
        product.setSeller(sellerUser);

        existingAuction = new Auction();
        existingAuction.setId(100L);
        existingAuction.setProduct(product);
        existingAuction.setSeller(sellerUser);
        existingAuction.setStatus(AuctionStatus.PENDING);
        existingAuction.setStartDateAndTime(LocalDateTime.now().plusHours(1));
        existingAuction.setEndDateAndTime(LocalDateTime.now().plusHours(2));
        existingAuction.setInitialPrice(BigDecimal.valueOf(100.0));
        existingAuction.setMinimunBidIncrement(BigDecimal.valueOf(10.0));
        existingAuction.setCurrentBid(BigDecimal.ZERO);
        existingAuction.setBids(new ArrayList<>());

        auctionCreateDTO = new AuctionCreateRequestDTO(
                product.getId(),
                LocalDateTime.now().plusMinutes(5),
                LocalDateTime.now().plusMinutes(15),
                BigDecimal.valueOf(150.0),
                BigDecimal.valueOf(5.0));
    }

    // --- Testes para createAuction ---

    // Pronto
    @Test
    @DisplayName("Deve criar um leilão com sucesso")
    void createAuction_ShouldCreateSuccessfully() {

        Long sellerId = sellerUser.getId();

        when(userService.findById(sellerId)).thenReturn(sellerUser);
        when(auctionRepository.findByProductId(auctionCreateDTO.productId())).thenReturn(new ArrayList<>());
        when(productService.findById(auctionCreateDTO.productId())).thenReturn(product);

        Auction newAuction = new Auction();
        newAuction.setProduct(product);
        newAuction.setSeller(sellerUser);
        newAuction.setStatus(AuctionStatus.PENDING);

        when(auctionMapper.toAuction(any(AuctionCreateRequestDTO.class))).thenReturn(newAuction);

        auctionService.createAuction(auctionCreateDTO, sellerId);

        verify(userService, times(1)).findById(sellerId);
        verify(auctionRepository, times(1)).findByProductId(auctionCreateDTO.productId());
        verify(productService, times(1)).findById(auctionCreateDTO.productId());
        verify(auctionMapper, times(1)).toAuction(auctionCreateDTO);
        verify(auctionRepository, times(1)).save(newAuction);
    }

    // Pronto
    @Test
    @DisplayName("Deve lançar ProductAlreadyInAuctionException se o produto já estiver em um leilão ativo/pendente")
    void createAuction_ShouldThrowProductAlreadyInAuctionException_WhenProductIsInActiveAuction() {

        Long sellerId = sellerUser.getId();
        Auction activeAuctionForProduct = new Auction();
        activeAuctionForProduct.setStatus(AuctionStatus.ACTIVE);

        when(userService.findById(sellerId)).thenReturn(sellerUser);
        when(auctionRepository.findByProductId(auctionCreateDTO.productId()))
                .thenReturn(List.of(activeAuctionForProduct));

        assertThrows(ProductAlreadyInAuctionException.class, () -> {
            auctionService.createAuction(auctionCreateDTO, sellerId);
        });

        verify(productService, never()).findById(anyLong());
        verify(auctionMapper, never()).toAuction(any(AuctionCreateRequestDTO.class));
        verify(auctionRepository, never()).save(any(Auction.class));
    }

    // Pronto
    @Test
    @DisplayName("Deve lançar ResourceNotFoundException se o vendedor não for encontrado")
    void createAuction_ShouldThrowResourceNotFoundException_WhenSellerNotFound() {

        Long nonExistingSellerId = 99L;

        when(userService.findById(nonExistingSellerId))
                .thenThrow(new ResourceNotFoundException("Usuário, com o id: " + nonExistingSellerId));

        assertThrows(ResourceNotFoundException.class, () -> {
            auctionService.createAuction(auctionCreateDTO, nonExistingSellerId);
        });

        verify(auctionRepository, never()).findByProductId(anyLong());
        verify(productService, never()).findById(anyLong());
        verify(auctionMapper, never()).toAuction(any(AuctionCreateRequestDTO.class));
        verify(auctionRepository, never()).save(any(Auction.class));
    }

    // --- Testes para findById ---

    // Pronto
    @Test
    @DisplayName("Deve encontrar um leilão por ID com sucesso")
    void findById_ShouldReturnAuction_WhenFound() {

        Long auctionId = existingAuction.getId();

        when(auctionRepository.findById(auctionId)).thenReturn(Optional.of(existingAuction));

        Auction foundAuction = auctionService.findById(auctionId);
        assertNotNull(foundAuction);
    }

    // Pronto
    @Test
    @DisplayName("Deve lançar ResourceNotFoundException se o leilão não for encontrado por ID")
    void findById_ShouldThrowResourceNotFoundException_WhenNotFound() {

        Long nonExistingAuctionId = 999L;

        when(auctionRepository.findById(nonExistingAuctionId)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> {
            auctionService.findById(nonExistingAuctionId);
        });

        verify(auctionRepository, times(1)).findById(nonExistingAuctionId);
    }

    // --- Testes para findAuctionsBySellerId ---

    // Pronto
    @Test
    @DisplayName("Deve retornar os dto dos leilões achados por sellerId")
    void findAuctionsBySellerId_ShouldReturnAuctionsDTO() {

        Long sellerId = sellerUser.getId();
        List<Auction> mockAuctions = List.of(existingAuction);

        when(auctionRepository.findBySellerId(sellerId)).thenReturn(mockAuctions);
        when(auctionMapper.toAuctionDetailsResponseDTO(any(Auction.class)))
                .thenReturn(any(AuctionDetailsResponseDTO.class));

        List<AuctionDetailsResponseDTO> result = auctionService.findAuctionsBySellerId(sellerId);

        assertFalse(result.isEmpty());

        verify(auctionRepository, times(1)).findBySellerId(sellerId);
        verify(auctionMapper, times(mockAuctions.size())).toAuctionDetailsResponseDTO(any(Auction.class));
    }

    // --- Testes para saveAuction ---

    @Test
    @DisplayName("Deve salvar o leilão")
    void save_ShouldSaveAuction() {

        when(auctionRepository.save(existingAuction)).thenReturn(existingAuction);

        auctionService.save(existingAuction);

        verify(auctionRepository, times(1)).save(existingAuction);
    }

    // --- Testes para searchAndFilterAuctions (Paginação e Filtros) ---

    // Pronto
    @Test
    @DisplayName("Deve retornar uma página de leilões filtrados e paginados")
    void searchAndFilterAuctions_ShouldReturnFilteredPagedAuctions() {

        AuctionFilterParamsDTO filterParams = new AuctionFilterParamsDTO(null,
                "Test Product", null, null, null, "PENDING", null, null, null, null, null, null,
                null, null);
        Pageable pageable = Pageable.ofSize(10).withPage(0);

        List<Auction> mockAuctions = List.of(existingAuction);
        Page<Auction> auctionPage = new PageImpl<Auction>(mockAuctions, pageable, mockAuctions.size());
        AuctionDetailsResponseDTO expectedAuctionDTO = new AuctionDetailsResponseDTO(
                existingAuction.getId(),
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null);

        when(auctionRepository.findAll(any(Specification.class), eq(pageable))).thenReturn(auctionPage);
        when(auctionMapper.toAuctionDetailsResponseDTO(any(Auction.class)))
                .thenReturn(expectedAuctionDTO);

        Page<AuctionDetailsResponseDTO> resultPage = auctionService.searchAndFilterAuctions(filterParams, pageable);

        assertNotNull(resultPage);
        assertFalse(resultPage.isEmpty());

        verify(auctionRepository, times(1)).findAll(any(Specification.class), eq(pageable));
        verify(auctionMapper, times(mockAuctions.size())).toAuctionDetailsResponseDTO(any(Auction.class));
    }

    // --- Testes para processPendingAuctions (Agendamento) ---

    // Pronto
    @Test
    @DisplayName("Deve ativar leilões pendentes e enviar notificação")
    void processPendingAuctions_ShouldActivateAndNotify() {

        Auction pendingAuction = new Auction();
        pendingAuction.setId(300L);
        pendingAuction.setStatus(AuctionStatus.PENDING);
        pendingAuction.setStartDateAndTime(LocalDateTime.now().minusMinutes(1));

        List<Auction> auctionsToActivate = List.of(pendingAuction);
        AuctionDetailsResponseDTO activatedAuctionDTO = new AuctionDetailsResponseDTO(
                pendingAuction.getId(), null, pendingAuction.getStartDateAndTime(), null, null, null, null, null,
                AuctionStatus.ACTIVE, null,
                null, null);

        when(auctionRepository.findByStatusAndStartDateAndTimeBefore(eq(AuctionStatus.PENDING),
                any(LocalDateTime.class)))
                .thenReturn(auctionsToActivate);
        when(auctionRepository.saveAll(auctionsToActivate)).thenReturn(auctionsToActivate);
        when(auctionMapper.toAuctionDetailsResponseDTO(any(Auction.class))).thenReturn(activatedAuctionDTO);

        auctionService.processPendingAuctions();

        verify(auctionRepository, times(1)).findByStatusAndStartDateAndTimeBefore(eq(AuctionStatus.PENDING),
                any(LocalDateTime.class));
        verify(auctionRepository, times(1)).saveAll(auctionsToActivate);
        verify(auctionMapper, times(1)).toAuctionDetailsResponseDTO(pendingAuction);
        verify(messagingTemplate, times(1)).convertAndSend(
                "/topic/auctions/" + pendingAuction.getId() + "/status",
                activatedAuctionDTO);

        assertEquals(AuctionStatus.ACTIVE, pendingAuction.getStatus());
    }

    // Pronto
    @Test
    @DisplayName("Deve parar se não houver leilões pendentes prontos para serem ativados")
    void processPendingAuctions_ShouldStop_WhenAuctionsIsEmpty() {

        List<Auction> auctionsEmpty = new ArrayList<Auction>();

        when(auctionRepository.findByStatusAndStartDateAndTimeBefore(eq(AuctionStatus.PENDING),
                any(LocalDateTime.class)))
                .thenReturn(auctionsEmpty);

        auctionService.processPendingAuctions();

        verify(auctionRepository, times(1)).findByStatusAndStartDateAndTimeBefore(eq(AuctionStatus.PENDING),
                any(LocalDateTime.class));

        verify(auctionRepository, never()).saveAll(auctionsEmpty);
        verify(auctionMapper, never()).toAuctionDetailsResponseDTO(any(Auction.class));
        verify(messagingTemplate, never()).convertAndSend(any(String.class), any(Object.class));
    }

    // --- Testes para processEndingAuctions (Agendamento) ---

    // Pronto
    @Test
    @DisplayName("Deve fechar leilões ativos e enviar notificação")
    void processEndingAuctions_ShouldActivateAndNotify() {

        Auction activeAuction = new Auction();
        activeAuction.setId(300L);
        activeAuction.setStatus(AuctionStatus.ACTIVE);
        activeAuction.setEndDateAndTime(LocalDateTime.now().minusMinutes(1));
        activeAuction.setCurrentBid(BigDecimal.TEN);
        activeAuction.setCurrentBidder(new User());

        List<Auction> auctionsToClose = List.of(activeAuction);
        AuctionDetailsResponseDTO closedAuctionDTO = new AuctionDetailsResponseDTO(
                activeAuction.getId(), null, activeAuction.getStartDateAndTime(), null, null, null, null, null,
                AuctionStatus.ACTIVE, null,
                null, null);

        when(auctionRepository.findByStatusAndEndDateAndTimeBefore(eq(AuctionStatus.ACTIVE), any(LocalDateTime.class)))
                .thenReturn(auctionsToClose);
        when(auctionRepository.saveAll(auctionsToClose)).thenReturn(auctionsToClose);
        when(auctionMapper.toAuctionDetailsResponseDTO(any(Auction.class))).thenReturn(closedAuctionDTO);

        auctionService.processEndingAuctions();

        verify(auctionRepository, times(1)).findByStatusAndEndDateAndTimeBefore(eq(AuctionStatus.ACTIVE),
                any(LocalDateTime.class));
        verify(auctionRepository, times(1)).saveAll(auctionsToClose);
        verify(auctionMapper, times(1)).toAuctionDetailsResponseDTO(activeAuction);
        verify(messagingTemplate, times(1)).convertAndSend(
                "/topic/auctions/" + activeAuction.getId() + "/status",
                closedAuctionDTO);

        assertEquals(AuctionStatus.CLOSED, activeAuction.getStatus());
    }

    // Pronto
    @Test
    @DisplayName("Deve parar se não houver leilões ativos prontos para serem fechados")
    void processEndingAuctions_ShouldStop_WhenAuctionsIsEmpty() {

        List<Auction> auctionsEmpty = new ArrayList<Auction>();

        when(auctionRepository.findByStatusAndEndDateAndTimeBefore(eq(AuctionStatus.ACTIVE), any(LocalDateTime.class)))
                .thenReturn(auctionsEmpty);

        auctionService.processEndingAuctions();

        verify(auctionRepository, times(1)).findByStatusAndEndDateAndTimeBefore(eq(AuctionStatus.ACTIVE),
                any(LocalDateTime.class));

        verify(auctionRepository, never()).saveAll(auctionsEmpty);
        verify(auctionMapper, never()).toAuctionDetailsResponseDTO(any(Auction.class));
        verify(messagingTemplate, never()).convertAndSend(any(String.class), any(Object.class));
    }

    // --- Testes para cancelAuction ---

    // Pronto
    @Test
    @DisplayName("Deve cancelar um leilão com sucesso se o usuário for o dono, status PENDING e sem lances")
    void cancelAuction_ShouldCancelSuccessfully_WhenOwnerAndPendingAndNoBids() {

        Long auctionId = existingAuction.getId();
        Long sellerId = sellerUser.getId();
        AuctionDetailsResponseDTO cancelledAuctionDTO = new AuctionDetailsResponseDTO(
                existingAuction.getId(), null, null, null, null, null, null, null, AuctionStatus.CANCELLED, null, null,
                null);

        when(userService.findById(sellerId)).thenReturn(sellerUser);
        when(auctionRepository.findById(auctionId)).thenReturn(Optional.of(existingAuction));
        when(auctionRepository.save(any(Auction.class))).thenAnswer(invocation -> {
            Auction auctionToSave = invocation.getArgument(0);
            assertEquals(AuctionStatus.CANCELLED, auctionToSave.getStatus());
            return auctionToSave;
        });
        when(auctionMapper.toAuctionDetailsResponseDTO(any(Auction.class))).thenReturn(cancelledAuctionDTO);

        AuctionDetailsResponseDTO result = auctionService.cancelAuction(auctionId, sellerId);

        assertNotNull(result);
        assertEquals(AuctionStatus.CANCELLED, result.status());
        verify(userService, times(1)).findById(sellerId);
        verify(auctionRepository, times(1)).findById(auctionId);
        verify(auctionRepository, times(1)).save(any(Auction.class));
        verify(auctionMapper, times(1)).toAuctionDetailsResponseDTO(any(Auction.class));
    }

    // Pronto
    @Test
    @DisplayName("Deve lançar NotAuctionOwnerException se o usuário não for o dono do leilão")
    void cancelAuction_ShouldThrowNotAuctionOwnerException_WhenNotOwner() {

        Long auctionId = existingAuction.getId();

        Long nonOwnerSellerId = 99L;
        User nonOwnerUser = new User();
        nonOwnerUser.setId(nonOwnerSellerId);
        nonOwnerUser.setRole(UserRole.SELLER);

        when(userService.findById(nonOwnerSellerId)).thenReturn(nonOwnerUser);
        when(auctionRepository.findById(auctionId)).thenReturn(Optional.of(existingAuction));

        assertThrows(NotAuctionOwnerException.class, () -> {
            auctionService.cancelAuction(auctionId, nonOwnerSellerId);
        });

        verify(auctionRepository, never()).save(any(Auction.class));
        verify(auctionMapper, never()).toAuctionDetailsResponseDTO(any(Auction.class));
    }

    // Pronto
    @Test
    @DisplayName("Deve lançar AuctionCannotBeCancelledException se o leilão não estiver PENDING")
    void cancelAuction_ShouldThrowAuctionCannotBeCancelledException_WhenNotPending() {

        Long sellerId = sellerUser.getId();
        Long auctionId = existingAuction.getId();
        existingAuction.setStatus(AuctionStatus.ACTIVE);

        when(userService.findById(sellerId)).thenReturn(sellerUser);
        when(auctionRepository.findById(auctionId)).thenReturn(Optional.of(existingAuction));

        assertThrows(AuctionCannotBeCancelledException.class, () -> {
            auctionService.cancelAuction(auctionId, sellerId);
        });

        verify(auctionRepository, never()).save(any(Auction.class));
        verify(auctionMapper, never()).toAuctionDetailsResponseDTO(any(Auction.class));
    }

    // Pronto
    @Test
    @DisplayName("Deve lançar AuctionCannotBeCancelledException se o leilão tiver lances")
    void cancelAuction_ShouldThrowAuctionCannotBeCancelledException_WhenHasBids() {

        Long sellerId = sellerUser.getId();
        Long auctionId = existingAuction.getId();
        existingAuction.setBids(List.of(new Bid()));

        when(userService.findById(sellerId)).thenReturn(sellerUser);
        when(auctionRepository.findById(auctionId)).thenReturn(Optional.of(existingAuction));

        assertThrows(AuctionCannotBeCancelledException.class, () -> {
            auctionService.cancelAuction(auctionId, sellerId);
        });

        verify(auctionRepository, never()).save(any(Auction.class));
        verify(auctionMapper, never()).toAuctionDetailsResponseDTO(any(Auction.class));
    }
}
