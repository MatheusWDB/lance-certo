package br.com.hematsu.lance_certo.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import br.com.hematsu.lance_certo.dto.user.UserLoginRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserResponseDTO;
import br.com.hematsu.lance_certo.dto.user.UserTokenResponseDTO;
import br.com.hematsu.lance_certo.dto.user.UserUpdateRequestDTO;
import br.com.hematsu.lance_certo.mapper.UserMapper;
import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.service.AuthenticationService;
import br.com.hematsu.lance_certo.service.TokenService;
import br.com.hematsu.lance_certo.service.UserService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api")
public class UserController {

    private final UserService userService;
    private final AuthenticationService authenticationService;
    private final UserMapper userMapper;
    private final AuthenticationManager authenticationManager;
    private final TokenService tokenService;

    public UserController(
            UserService userService,
            AuthenticationService authenticationService,
            UserMapper userMapper,
            AuthenticationManager authenticationManager,
            TokenService tokenService) {
        this.userService = userService;
        this.authenticationService = authenticationService;
        this.userMapper = userMapper;
        this.authenticationManager = authenticationManager;
        this.tokenService = tokenService;
    }

    @PostMapping("/users/register")
    public ResponseEntity<Void> registerUser(@RequestBody @Valid UserRegistrationRequestDTO registrationDTO) {

        userService.registerUser(registrationDTO);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/users/login")
    public ResponseEntity<UserTokenResponseDTO> loginUser(@RequestBody UserLoginRequestDTO loginDTO) {

        UsernamePasswordAuthenticationToken loginPassword = new UsernamePasswordAuthenticationToken(
                loginDTO.login(), loginDTO.password());

        try {
            Authentication auth = this.authenticationManager.authenticate(loginPassword);

            User user = (User) auth.getPrincipal();
            String token = tokenService.generateToken((User) auth.getPrincipal());

            UserTokenResponseDTO userDTO = new UserTokenResponseDTO(token, userMapper.userToUserResponseDTO(user));

            return ResponseEntity.status(HttpStatus.OK).body(userDTO);

        } catch (AuthenticationException e) {
            System.err.println("Login failed for user: " + loginDTO.login() + " - " + e.getMessage());
            throw e;

        } catch (Exception e) {
            System.err.println("Unexpected error during login: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    @GetMapping("/user")
    public ResponseEntity<UserResponseDTO> getByUsernameOrEmail(
            @RequestParam(name = "login", required = true) String login) {

        User user = (User) authenticationService.loadUserByUsername(login);
        return ResponseEntity.status(HttpStatus.OK).body(userMapper.userToUserResponseDTO(user));
    }

    @PatchMapping("/users/update")
    public ResponseEntity<UserResponseDTO> updateUser(@RequestBody @Valid UserUpdateRequestDTO userDTO){
        
        User user = userService.save(userMapper.userUpdateRequestDTOToUser(userDTO));
        return ResponseEntity.status(HttpStatus.OK).body(userMapper.userToUserResponseDTO(user));
    }
}
