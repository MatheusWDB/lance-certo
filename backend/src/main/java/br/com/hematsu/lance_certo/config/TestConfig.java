package br.com.hematsu.lance_certo.config;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;

import br.com.hematsu.lance_certo.dto.auction.AuctionCreateRequestDTO;
import br.com.hematsu.lance_certo.dto.product.ProductRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.mapper.AuctionMapper;
import br.com.hematsu.lance_certo.mapper.ProductMapper;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.Auction;
import br.com.hematsu.lance_certo.model.AuctionStatus;
import br.com.hematsu.lance_certo.model.Product;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.model.UserRole;
import br.com.hematsu.lance_certo.repository.AuctionRepository;
import br.com.hematsu.lance_certo.repository.ProductRepository;
import br.com.hematsu.lance_certo.repository.UserRepository;

@Configuration
@Profile("test")
public class TestConfig implements CommandLineRunner {

        private final UserRepository userRepository;
        private final ProductRepository productRepository;
        private final AuctionRepository auctionRepository;
        private final UserMapper userMapper;
        private final ProductMapper productMapper;
        private final AuctionMapper auctionMapper;
        private final PasswordEncoder passwordEncoder;

        public TestConfig(
                        UserRepository userRepository,
                        ProductRepository productRepository,
                        AuctionRepository auctionRepository,
                        UserMapper userMapper,
                        ProductMapper productMapper,
                        AuctionMapper auctionMapper,
                        PasswordEncoder passwordEncoder) {

                this.userRepository = userRepository;
                this.productRepository = productRepository;
                this.auctionRepository = auctionRepository;
                this.userMapper = userMapper;
                this.productMapper = productMapper;
                this.auctionMapper = auctionMapper;
                this.passwordEncoder = passwordEncoder;
        }

        @Override
        public void run(String... args) throws Exception {

                // Criar usuários
                UserRegistrationRequestDTO createUserAdmin = new UserRegistrationRequestDTO(
                                "Admin123",
                                passwordEncoder.encode("12345678"),
                                "admin@gmail.com",
                                "Administrador",
                                UserRole.ADMIN,
                                "79 999999990");

                UserRegistrationRequestDTO createUserSeller = new UserRegistrationRequestDTO(
                                "Seller123",
                                passwordEncoder.encode("12345678"),
                                "seller@gmail.com",
                                "Vendedor",
                                UserRole.SELLER,
                                "79 999999991");

                UserRegistrationRequestDTO createUserBuyer = new UserRegistrationRequestDTO(
                                "Buyer123",
                                passwordEncoder.encode("12345678"),
                                "buyer@gmail.com",
                                "Comprador",
                                UserRole.BUYER,
                                "79 999999992");

                userRepository.saveAll(List.of(
                                userMapper.userRegistrationRequestDTOToUser(createUserAdmin),
                                userMapper.userRegistrationRequestDTOToUser(createUserSeller),
                                userMapper.userRegistrationRequestDTOToUser(createUserBuyer)));

                User userSeller = userRepository.findByLogin("seller@gmail.com").orElse(null);

                // Criar produtos
                ProductRequestDTO createProduct = new ProductRequestDTO("Produto 1", "Description", null,
                                "Teste");

                Product product = productMapper.productRequestDTOToEntity(createProduct);
                product.setSeller(userSeller);

                ProductRequestDTO createProduct2 = new ProductRequestDTO("Produto 2", "Description", null,
                                "Teste");
                Product product2 = productMapper.productRequestDTOToEntity(createProduct2);
                product2.setSeller(userSeller);

                productRepository.saveAll(List.of(product, product2));

                // Criar leilões
                AuctionCreateRequestDTO createAuction = new AuctionCreateRequestDTO(
                                1L,
                                LocalDateTime.now().plusSeconds(30),
                                LocalDateTime.now().plusMinutes(10),
                                BigDecimal.valueOf(100.0),
                                BigDecimal.valueOf(25.0));

                product = productRepository.findById(createAuction.productId()).orElse(null);

                Auction auction = auctionMapper.auctionCreateRequestDTOToAuction(createAuction);
                auction.setSeller(userSeller);
                auction.setProduct(product);
                auction.setStatus(AuctionStatus.PENDING);
                auction.setInitialPrice(createAuction.initialPrice());
                auction.setMinimunBidIncrement(createAuction.minimunBidIncrement());
                auction.setCurrentBid(BigDecimal.ZERO);
                auction.setCurrentBidder(null);

                AuctionCreateRequestDTO createAuction2 = new AuctionCreateRequestDTO(
                                2L,
                                LocalDateTime.now().plusSeconds(30),
                                LocalDateTime.now().plusMinutes(10),
                                BigDecimal.valueOf(25.0),
                                BigDecimal.valueOf(5.0));

                product2 = productRepository.findById(createAuction2.productId()).orElse(null);

                Auction auction2 = auctionMapper.auctionCreateRequestDTOToAuction(createAuction2);
                auction2.setSeller(userSeller);
                auction2.setProduct(product2);
                auction2.setStatus(AuctionStatus.PENDING);
                auction2.setInitialPrice(createAuction2.initialPrice());
                auction2.setMinimunBidIncrement(createAuction2.minimunBidIncrement());
                auction2.setCurrentBid(BigDecimal.ZERO);
                auction2.setCurrentBidder(null);

                auctionRepository.saveAll(List.of(auction, auction2));

        }

}