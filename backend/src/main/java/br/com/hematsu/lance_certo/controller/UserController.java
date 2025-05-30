package br.com.hematsu.lance_certo.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.user.UserLoginRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserTokenResponseDTO;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.service.TokenService;
import br.com.hematsu.lance_certo.service.UserService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;
    private final UserMapper userMapper;
    private final AuthenticationManager authenticationManager;
    private final TokenService tokenService;

    public UserController(
            UserService userService,
            UserMapper userMapper,
            AuthenticationManager authenticationManager,
            TokenService tokenService) {
        this.userService = userService;
        this.userMapper = userMapper;
        this.authenticationManager = authenticationManager;
        this.tokenService = tokenService;
    }

    @PostMapping("/register")
    public ResponseEntity<Void> registerUser(@RequestBody @Valid UserRegistrationRequestDTO registrationDTO) {

        userService.registerUser(registrationDTO);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/login")
    public ResponseEntity<UserTokenResponseDTO> userLogin(@RequestBody UserLoginRequestDTO loginDTO) {

        UsernamePasswordAuthenticationToken loginPassword = new UsernamePasswordAuthenticationToken(
                loginDTO.login(), loginDTO.password());

        Authentication auth = this.authenticationManager.authenticate(loginPassword);

        User user = (User) auth.getPrincipal();
        String token = tokenService.generateToken((User) auth.getPrincipal());

        UserTokenResponseDTO userDTO = new UserTokenResponseDTO(token, userMapper.userToUserResponseDTO(user));

        return ResponseEntity.status(HttpStatus.OK).body(userDTO);
    }
}
