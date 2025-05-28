package br.com.hematsu.lance_certo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.lang.NonNull;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(@NonNull MessageBrokerRegistry config) {

        // Habilita um simple broker em memória.
        // Mensagens com prefixo "/topic" ou "/queue" serão roteadas para o broker e
        // entregues aos clientes inscritos.
        config.enableSimpleBroker("/topic", "/queue");

        // Define o prefixo para destinos "de aplicação".
        // Mensagens enviadas do cliente para o servidor com prefixo "/app"
        // serão roteadas para métodos @MessageMapping em classes @Controller.
        // Para este projeto, a maior parte da comunicação cliente->servidor será via
        // REST,
        // mas é uma configuração padrão.
        config.setApplicationDestinationPrefixes("/app");

        // Opcional: Configurar prefíxos para o usuário.
        // Se você tiver destinos específicos por usuário (ex: notificações privadas).
        // config.setUserDestinationPrefix("/user");
    }

    @Override
    public void registerStompEndpoints(@NonNull StompEndpointRegistry registry) {
        // Registra o endpoint "/ws" para o handshake do WebSocket.
        // Clientes usarão ws://<host>:<porta>/ws para se conectar.
        // withSockJS() habilita o suporte a SockJS para navegadores que não suportam
        // WebSocket nativamente.
        registry.addEndpoint("/ws").withSockJS();
    }

}
