package br.com.hematsu.lance_certo.service;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.exception.ResourceNotFoundException;
import br.com.hematsu.lance_certo.exception.user.UserAlreadyExistsException;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.model.UserRole;
import br.com.hematsu.lance_certo.repository.UserRepository;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;

    public UserService(
            UserRepository userRepository,
            UserMapper userMapper,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager) {

        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public void registerUser(UserRegistrationRequestDTO registrationDTO) {

        Boolean doesAlreadyExist = this.doesUsernameOrEmailAlreadyExist(registrationDTO.username(),
                registrationDTO.email());
        if (Boolean.TRUE.equals(doesAlreadyExist)) {
            throw new UserAlreadyExistsException();
        }

        User newUser = userMapper.toUser(registrationDTO);

        if (newUser.getRole() == null) {
            newUser.setRole(UserRole.BUYER);
        }

        String encodedPassword = encodePassword(registrationDTO.password());
        newUser.setPassword(encodedPassword);

        userRepository.save(newUser);
    }

    public User findById(Long id) {
        return userRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Usuário, com o id: " + id));
    }

    public String encodePassword(String password) {
        return passwordEncoder.encode(password);
    }

    @Transactional
    public User save(User user) {
        return userRepository.save(user);
    }

    public Boolean doesUsernameOrEmailAlreadyExist(String username, String email) {

        Boolean doesAlreadyExist = false;

        if (userRepository.findByLogin(username).isPresent() || userRepository.findByLogin(email).isPresent()) {
            doesAlreadyExist = true;
        }

        return doesAlreadyExist;
    }

    public Authentication authenticate(String login, String password) {

        UsernamePasswordAuthenticationToken loginPassword = new UsernamePasswordAuthenticationToken(login, password);
        return this.authenticationManager.authenticate(loginPassword);
    }
}
