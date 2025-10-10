package br.com.hematsu.lance_certo.config;

import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.access.hierarchicalroles.RoleHierarchy;
import org.springframework.security.access.hierarchicalroles.RoleHierarchyImpl;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.hematsu.lance_certo.exception.CustomAccessDeniedHandler;
import br.com.hematsu.lance_certo.exception.CustomAuthenticationEntryPoint;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

        @Value("${cors.allowed-origins}")
        private String allowedOrigins;

        @Value("${cors.allowed-methods}")
        private String allowedMethods;

        private static final String ADMIN = "ADMIN";

        private static final String SELLER = "SELLER";

        private static final String[] PUBLIC_MATCHERS = {
                        "/h2-console/**",
                        "/swagger-ui.html",
                        "/swagger-ui/**",
                        "/v3/api-docs/**",
                        "/v3/api-docs.yaml",
                        "/ws/**"
        };

        private static final String[] PUBLIC_POST_MATCHERS = {
                        "/api/users/login",
                        "/api/users/register",
                        "/api/bids/auctions/{auctionId}/bidder"
        };

        private static final String[] PUBLIC_GET_MATCHERS = {
                        "/api/products",
                        "/api/products/seller",
                        "/api/auction/{id}",
                        "/api/auctions",
                        "/api/bids/auctions/{auctionId}",
                        "/api/bids"
        };

        private static final String[] PUBLIC_PATCH_MATCHERS = {
                        "/api/users/update"
        };

        private static final String[] SELLER_POST_MATCHERS = {
                        "/api/products/create/sellers",
                        "/api/auctions/create/sellers"
        };

        private static final String[] SELLER_GET_MATCHERS = {
                        "/api/auctions/seller"
        };

        private static final String[] SELLER_PATCH_MATCHERS = {
                        "/api/products/{id}/update",
                        "/api/auctions/{id}/cancel"
        };

        private static final String[] ADMIN_GET_MATCHERS = {
                        "/api/users"
        };

        private final SecurityFilter securityFilter;
        private final ObjectMapper objectMapper;

        public SecurityConfig(SecurityFilter securityFilter, ObjectMapper objectMapper) {
                this.securityFilter = securityFilter;
                this.objectMapper = objectMapper;
        }

        @Bean
        PasswordEncoder passwordEncoder() {
                return new BCryptPasswordEncoder();
        }

        @Bean
        RoleHierarchy roleHierarchy() {

                String hierarchy = """
                                ROLE_ADMIN > ROLE_SELLER
                                ROLE_SELLER > ROLE_BUYER
                                """;

                return RoleHierarchyImpl.fromHierarchy(hierarchy);
        }

        @Bean
        SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception {
                return httpSecurity
                                .cors(Customizer.withDefaults())
                                .csrf(csrf -> csrf.disable())
                                .headers(headers -> headers.frameOptions(HeadersConfigurer.FrameOptionsConfig::disable))
                                .sessionManagement(session -> session
                                                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                                .authorizeHttpRequests(
                                                authorize -> authorize
                                                                .requestMatchers(PUBLIC_MATCHERS).permitAll()
                                                                .requestMatchers(HttpMethod.POST, PUBLIC_POST_MATCHERS)
                                                                .permitAll()
                                                                .requestMatchers(HttpMethod.GET, PUBLIC_GET_MATCHERS)
                                                                .permitAll()
                                                                .requestMatchers(
                                                                                HttpMethod.PATCH,
                                                                                PUBLIC_PATCH_MATCHERS)
                                                                .permitAll()
                                                                .requestMatchers(HttpMethod.GET, ADMIN_GET_MATCHERS)
                                                                .hasRole(ADMIN)
                                                                .requestMatchers(HttpMethod.POST, SELLER_POST_MATCHERS)
                                                                .hasRole(SELLER)
                                                                .requestMatchers(HttpMethod.GET, SELLER_GET_MATCHERS)
                                                                .hasRole(SELLER)
                                                                .requestMatchers(
                                                                                HttpMethod.PATCH,
                                                                                SELLER_PATCH_MATCHERS)
                                                                .hasRole(SELLER)
                                                                .anyRequest().authenticated())
                                .addFilterBefore(securityFilter, UsernamePasswordAuthenticationFilter.class)
                                .exceptionHandling(exception -> exception
                                                .authenticationEntryPoint(customAuthenticationEntryPoint())
                                                .accessDeniedHandler(customAccessDeniedHandler()))
                                .build();
        }

        @Bean
        public AuthenticationEntryPoint customAuthenticationEntryPoint() {
                return new CustomAuthenticationEntryPoint(objectMapper);
        }

        @Bean
        public AccessDeniedHandler customAccessDeniedHandler() {
                return new CustomAccessDeniedHandler(objectMapper);
        }

        @Bean
        CorsConfigurationSource corsConfigurationSource() {

                CorsConfiguration configuration = new CorsConfiguration();

                configuration.setAllowedOriginPatterns(Arrays.asList(allowedOrigins.split(",")));

                configuration.setAllowedMethods(Arrays.asList(allowedMethods.split(",")));
                configuration.setAllowedHeaders(List.of("*"));
                configuration.setAllowCredentials(true);

                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
                source.registerCorsConfiguration("/ws/**", configuration);
                source.registerCorsConfiguration("/**", configuration);
                return source;
        }

        @Bean
        AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration)
                        throws Exception {
                return authenticationConfiguration.getAuthenticationManager();
        }
}