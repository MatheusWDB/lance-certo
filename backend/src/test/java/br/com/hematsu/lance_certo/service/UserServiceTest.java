package br.com.hematsu.lance_certo.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;

import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.repository.UserRepository;

class UserServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private UserMapper userMapper;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private AuthenticationManager authenticationManager;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void setup() {

        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("")
    void testAuthenticate() {

    }

    @Test
    @DisplayName("")
    void testDoesUsernameOrEmailAlreadyExist() {

    }

    @Test
    @DisplayName("")
    void testEncodePassword() {

    }

    @Test
    @DisplayName("")
    void testFindById() {

    }

    @Test
    @DisplayName("")
    void testRegisterUser() {

    }

    @Test
    @DisplayName("")
    void testSave() {

    }
}
