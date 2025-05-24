package br.com.hematsu.lance_certo.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import br.com.hematsu.lance_certo.model.User;

public interface UserRepository extends JpaRepository<User, Long> {

    @Query("SELECT u FROM Users u WHERE u.username = :login OR u.email = :login")
    Optional<User> findByUsernameOrEmail(String login);
}
