package br.com.hematsu.lance_certo.repository;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.model.UserRole;
import jakarta.persistence.EntityManager;

@DataJpaTest
@ActiveProfiles("test")
class UserRepositoryTest {

    @Autowired
    private EntityManager entityManager;
    @Autowired
    private UserRepository userRepository;
    @Mock
    private UserMapper userMapper;

    private User newUser;
    private UserRegistrationRequestDTO dto;

    @BeforeEach
    void setup() {
        MockitoAnnotations.openMocks(this);

        dto = new UserRegistrationRequestDTO("adminkrl", "12345678", "testador@gmail.com",
                "Testador Admin", UserRole.ADMIN, "99999999999");

        newUser= new User();
        newUser.setUsername(dto.username());
        newUser.setPassword(dto.password());
        newUser.setEmail(dto.email());
        newUser.setName(dto.name());
        newUser.setRole(dto.role());
        newUser.setPhone(dto.phone());

    }

    @Test
    @DisplayName("Sucesso ao obter usuário do banco de dados")
    void testFindByLoginCase1() {

        when(userMapper.toUser(dto)).thenReturn(newUser);

        this.entityManager.persist(newUser);
        this.entityManager.flush();

        Optional<User> result = userRepository.findByLogin(dto.username());

        assertThat(result).isPresent();
    }

    @Test
    @DisplayName("Fracasso ao obter usuário do banco de dados")
    void testFindByLoginCase2() {

        Optional<User> result = userRepository.findByLogin("nonExistingLogin");

        assertThat(result).isEmpty();
    }
}
