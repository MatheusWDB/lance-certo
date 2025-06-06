package br.com.hematsu.lance_certo.service;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import br.com.hematsu.lance_certo.model.User;
import br.com.hematsu.lance_certo.repository.UserRepository;

@Service
public class AuthenticationService implements UserDetailsService {

    private final UserRepository userRepository;

    public AuthenticationService(UserRepository userRepository){
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String login) throws UsernameNotFoundException {

        return userRepository.findByLogin(login)
                .orElseThrow(() -> new UsernameNotFoundException("Email ou username, '" + login + "', não encontrado!"));                
    }

    public Long getIdByAuthentication(){

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User authenticatedUser = (User) authentication.getPrincipal();
        return authenticatedUser.getId();
    }
}
