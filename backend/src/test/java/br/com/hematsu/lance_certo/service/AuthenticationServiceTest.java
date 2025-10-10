package br.com.hematsu.lance_certo.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.Random;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.UserRepository;

class AuthenticationServiceTest {

    @Mock
    private UserRepository userRepository;

    @Autowired
    @InjectMocks
    private AuthenticationService authenticationService;

    private User userAuthenticate;

    @BeforeEach
    void setup() {

        MockitoAnnotations.openMocks(this);

        userAuthenticate = new User();
        userAuthenticate.setId(1L);
        userAuthenticate.setEmail("email@test.com");
        userAuthenticate.setUsername("Usuário Teste");
    }

    @Test
    @DisplayName("Deve carregar o usuário com sucesso ao fornecer email ou username.")
    void testLoadUserByUsername_1() {

        List<String> identifiers = Arrays.asList(
                userAuthenticate.getEmail(),
                userAuthenticate.getUsername());

        Random random = new Random();
        int randomIndex = random.nextInt(identifiers.size());
        String chosenIdentifier = identifiers.get(randomIndex);

        when(userRepository.findByLogin(chosenIdentifier)).thenReturn(Optional.of(userAuthenticate));

        User result = (User) authenticationService.loadUserByUsername(chosenIdentifier);

        assertEquals(result.getId(), userAuthenticate.getId());

        verify(userRepository, times(1)).findByLogin(chosenIdentifier);
    }

    @Test
    @DisplayName("Deve lançar UsernameNotFoundException quando o usuário não for encontrado")
    void testLoadUserByUsername_2() {

        String nonExistingUser = "nonExistingUser";

        when(userRepository.findByLogin(nonExistingUser)).thenReturn(Optional.empty());

        assertThrows(UsernameNotFoundException.class, () -> {
            authenticationService.loadUserByUsername(nonExistingUser);
        });

        verify(userRepository, times(1)).findByLogin(nonExistingUser);
    }

    @Test
    @DisplayName("Deve retornar o ID do usuário autenticado")
    void testGetIdByAuthentication_1() {

        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);

        when(authentication.getPrincipal()).thenReturn(userAuthenticate);
        when(securityContext.getAuthentication()).thenReturn(authentication);

        try (MockedStatic<SecurityContextHolder> mockedStatic = mockStatic(SecurityContextHolder.class)) {

            mockedStatic.when(SecurityContextHolder::getContext).thenReturn(securityContext);

            Long actualId = authenticationService.getIdByAuthentication();

            assertEquals(userAuthenticate.getId(), actualId);

            verify(authentication, times(1)).getPrincipal();
            verify(securityContext, times(1)).getAuthentication();
        }
    }
}
