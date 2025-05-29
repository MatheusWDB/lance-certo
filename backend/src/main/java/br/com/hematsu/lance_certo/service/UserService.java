package br.com.hematsu.lance_certo.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.com.hematsu.lance_certo.dto.user.UserLoginRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserResponseDTO;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.UserRepository;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, UserMapper userMapper, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public void registerUser(UserRegistrationRequestDTO registrationDTO) {

        if (doesUsernameOrEmailAlreadyExist(registrationDTO.username(), registrationDTO.email())) {
            throw new RuntimeException("User with this email or username already exists");
        }

        User newUser = userMapper.userRegistrationRequestDTOToUser(registrationDTO);

        String encodedPassword = passwordEncoder.encode(registrationDTO.password());
        newUser.setPassword(encodedPassword);

        userRepository.save(newUser);
    }

    public UserResponseDTO userLogin(UserLoginRequestDTO loginDTO) {

        User user = userRepository.findByLogin(loginDTO.login()).orElseThrow(() -> new RuntimeException());

        if (!user.getPassword().equals(loginDTO.password())) {
            throw new RuntimeException();
        }

        return userMapper.userToUserResponseDTO(user);
    }

    public User findById(Long id) {
        return userRepository.findById(id).orElseThrow(() -> new RuntimeException());
    }

    public Boolean doesUsernameOrEmailAlreadyExist(String username, String email) {
        if (userRepository.findByLogin(username).isPresent() || userRepository.findByLogin(email).isPresent()) {
            return true;
        }

        return false;
    }
}
