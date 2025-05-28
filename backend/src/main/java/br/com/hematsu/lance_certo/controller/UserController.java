package br.com.hematsu.lance_certo.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.user.UserLoginRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserResponseDTO;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.service.UserService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;
    private final UserMapper userMapper;

    public UserController(UserService userService,
            UserMapper userMapper) {
        this.userService = userService;
        this.userMapper = userMapper;
    }

    @PostMapping("/register")
    public ResponseEntity<Void> registerUser(@RequestBody @Valid UserRegistrationRequestDTO registrationDTO) {

        userService.registerUser(registrationDTO);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/login")
    public ResponseEntity<UserResponseDTO> userLogin(@RequestBody UserLoginRequestDTO loginDTO) {

        UserResponseDTO userDTO = userService.userLogin(loginDTO);
        return ResponseEntity.status(HttpStatus.OK).body(userDTO);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponseDTO> getUserById(@PathVariable Long id) {

        User user = userService.findById(id);
        return ResponseEntity.status(HttpStatus.OK).body(userMapper.userToUserResponseDTO(user));
    }
}
