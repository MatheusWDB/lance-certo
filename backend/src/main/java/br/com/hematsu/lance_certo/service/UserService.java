package br.com.hematsu.lance_certo.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.UserRepository;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    public UserService(UserRepository userRepository, UserMapper userMapper) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }

    @Transactional
    public void registerUser(UserRegistrationRequestDTO registrationDTO) {
        if (findByUsernameOrEmail(registrationDTO.username(), registrationDTO.email()).contains(true)) {
            throw new RuntimeException("User with this email or username already exists");
        }

        userRepository.save(userMapper.userRegistrationRequestDTOToEntity(registrationDTO));
    }

    public User findById(Long id) {
        return userRepository.findById(id).orElseThrow(() -> new RuntimeException());
    }

    public List<Boolean> findByUsernameOrEmail(String username, String email) {
        List<Boolean> existingUserByUsernameOrEmail = new ArrayList<>();
        existingUserByUsernameOrEmail.add(userRepository.findByUsernameOrEmail(email).isPresent());
        existingUserByUsernameOrEmail.add(userRepository.findByUsernameOrEmail(username).isPresent());

        return existingUserByUsernameOrEmail;
    }
}
