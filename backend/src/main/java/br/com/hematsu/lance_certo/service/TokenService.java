package br.com.hematsu.lance_certo.service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTCreationException;
import com.auth0.jwt.exceptions.JWTVerificationException;

import br.com.hematsu.lance_certo.model.User;

@Service
public class TokenService {
    
    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    public String generateToken(User user) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(secret);
            return JWT.create()
                    .withIssuer("lance_certo-api")
                    .withSubject(user.getUsername())
                    .withExpiresAt(genExpirationDate())
                    .sign(algorithm);
        } catch (JWTCreationException e) {
            throw new JWTCreationException("Erro ao gerar um token: ", e);
        }
    }

    public String validateToken(String token) {

        try {
            Algorithm algorithm = Algorithm.HMAC256(secret);
            return JWT.require(algorithm)
                    .withIssuer("lance_certo-api")
                    .build()
                    .verify(token)
                    .getSubject();

        } catch (JWTVerificationException e) {
            throw new JWTVerificationException("Token inválido: ", e);
        }
    }

    private Instant genExpirationDate() {
        return LocalDateTime.now().plusHours(expiration).toInstant(ZoneOffset.of("-03:00"));
    }
}
