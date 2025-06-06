package br.com.hematsu.lance_certo.config;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.beans.factory.annotation.Value;
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

        @Value("${password.test}")
        private String passwordTest;

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
                String password = this.passwordTest;

                UserRegistrationRequestDTO createUserAdmin = new UserRegistrationRequestDTO(
                                "Admin123",
                                passwordEncoder.encode(password),
                                "admin@gmail.com",
                                "Administrador",
                                UserRole.ADMIN,
                                "79 999999990");

                UserRegistrationRequestDTO createUserSeller = new UserRegistrationRequestDTO(
                                "Seller123",
                                passwordEncoder.encode(password),
                                "seller@gmail.com",
                                "Vendedor",
                                UserRole.SELLER,
                                "79 999999991");

                UserRegistrationRequestDTO createUserBuyer = new UserRegistrationRequestDTO(
                                "Buyer123",
                                passwordEncoder.encode(password),
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
                List<Product> createdProducts = new ArrayList<>();

                String[] productNames = {
                                "Vinho Envelhecido Reserva", "Fones de Ouvido Premium X1", "Livro 'O Código Secreto'",
                                "Guitarra Elétrica Vintage", "Smartwatch Ultra", "Tênis de Corrida Aerodinâmico",
                                "Máquina de Café Espresso Pro", "Mochila de Viagem Confort", "Console Retrô GigaPlay",
                                "Kit de Pintura a Óleo Profissional", "Bicicleta Mountain Trail", "Drone com Câmera 4K",
                                "Relógio de Pulso Clássico", "Coleção de Moedas Raras", "Cadeira Gamer Ergonômica"
                };
                String[] categories = {
                                "Bebidas", "Eletrônicos", "Livros", "Instrumentos Musicais", "Wearables", "Esportes",
                                "Cozinha", "Acessórios", "Games", "Arte", "Ciclismo", "Drones",
                                "Joias e Relógios", "Colecionáveis", "Móveis"
                };
                String[] descriptions = {
                                "Safra especial, sabor único.", "Áudio imersivo e cancelamento de ruído.",
                                "Um thriller que prende do início ao fim.",
                                "Som autêntico dos anos 70.", "Mantenha-se conectado e em forma.",
                                "Desempenho e conforto em cada passo.",
                                "Café perfeito com um toque.", "Ideal para aventuras e o dia a dia.",
                                "Reviva os clássicos com estilo.",
                                "Cores vibrantes para sua arte.", "Supere trilhas com confiança.",
                                "Perspectivas aéreas incríveis.",
                                "Elegância e precisão.", "Tesouros de diferentes épocas.",
                                "Conforto supremo para longas sessões."
                };

                for (int i = 0; i < 15; i++) {
                        ProductRequestDTO productDto = new ProductRequestDTO(
                                        productNames[i],
                                        descriptions[i],
                                        null,
                                        categories[i]);
                        Product product = productMapper.productRequestDTOToEntity(productDto);
                        product.setSeller(userSeller);
                        createdProducts.add(product);
                }
                createdProducts = productRepository.saveAll(createdProducts);

                // Criar leilões
                List<Auction> createdAuctions = new ArrayList<>();

                LocalDateTime fixedStartTime = LocalDateTime.now().plusSeconds(30);
                LocalDateTime fixedEndTime = LocalDateTime.now().plusMinutes(10);
                BigDecimal fixedCurrentBid = BigDecimal.ZERO;
                User fixedCurrentBidder = null;
                AuctionStatus fixedStatus = AuctionStatus.PENDING;

                for (int i = 0; i < 15; i++) {

                        Product associatedProduct = createdProducts.get(i % createdProducts.size());

                        BigDecimal initialPrice = BigDecimal
                                        .valueOf(ThreadLocalRandom.current().nextDouble(50.0, 5000.0))
                                        .setScale(2, RoundingMode.HALF_UP);
                        BigDecimal minBidIncrement = BigDecimal
                                        .valueOf(ThreadLocalRandom.current().nextDouble(5.0, 200.0))
                                        .setScale(2, RoundingMode.HALF_UP);

                        AuctionCreateRequestDTO auctionDto = new AuctionCreateRequestDTO(
                                        associatedProduct.getId(),
                                        fixedStartTime,
                                        fixedEndTime,
                                        initialPrice,
                                        minBidIncrement);

                        Auction auction = auctionMapper.auctionCreateRequestDTOToAuction(auctionDto);
                        auction.setSeller(userSeller);
                        auction.setProduct(associatedProduct);
                        auction.setStatus(fixedStatus);
                        auction.setCurrentBid(fixedCurrentBid);
                        auction.setCurrentBidder(fixedCurrentBidder);

                        createdAuctions.add(auction);
                }
                
                auctionRepository.saveAll(createdAuctions);
        }

}