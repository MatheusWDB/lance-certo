package br.com.hematsu.lance_certo.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.exception.ResourceNotFoundException;
import br.com.hematsu.lance_certo.exception.user.UserAlreadyExistsException;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.UserRepository;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final BCryptPasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, UserMapper userMapper, BCryptPasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public void registerUser(UserRegistrationRequestDTO registrationDTO) {

        if (doesUsernameOrEmailAlreadyExist(registrationDTO.username(), registrationDTO.email())) {
            throw new UserAlreadyExistsException();
        }

        User newUser = userMapper.userRegistrationRequestDTOToUser(registrationDTO);

        String encodedPassword = passwordEncoder.encode(registrationDTO.password());
        newUser.setPassword(encodedPassword);

        save(newUser);
    }

    public User findById(Long id) {
        return userRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Usuário, com o id: " + id));
    }

    @Transactional
    public User save(User user){
        return userRepository.save(user);
    }

    public Boolean doesUsernameOrEmailAlreadyExist(String username, String email) {
        if (userRepository.findByLogin(username).isPresent() || userRepository.findByLogin(email).isPresent()) {
            return true;
        }

        return false;
    }
}
