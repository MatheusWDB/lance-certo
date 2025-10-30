# 🥇 Lance Certo
[![NPM](https://img.shields.io/npm/l/react)](https://github.com/MatheusWDB/lance-certo/blob/main/LICENSE)

# Sobre o Projeto
**Lance Certo** é uma aplicação Full Stack de simulação de plataforma de leilões online, desenvolvida com o objetivo principal de aprofundar e consolidar conhecimentos em programação, arquitetura de sistemas e tecnologias modernas.

O projeto demonstra a implementação de um sistema transacional complexo com comunicação em tempo real e segurança robusta, oferecendo aos usuários a capacidade de:
-	Cadastrar e autenticar-se de forma segura (JWT).
-	Criar e gerenciar produtos e leilões.
-	Participar de leilões existentes.
-	Realizar lances em tempo real através de WebSockets.
-	Visualizar o histórico e o status de seus lances e leilões.
  
# 🚀 Recursos Principais
-	Comunicação em Tempo Real: Atualização dos lances utilizando WebSockets (Spring Boot STOMP).
-	Segurança Robusta: Autenticação e Autorização baseadas em JWT (JSON Web Tokens) com Spring Security.
-	Filtros Avançados: Utilização de Spring Data JPA Specifications para filtragem dinâmica de leilões e produtos.
-	Backend Escalável: Arquitetura orientada a serviços (Service Layer) com testes de unidade e integração.
-	Mobile e Web Cross-Platform: Frontend desenvolvido em Flutter, garantindo compatibilidade com Android e Web.
-	Migrações de Banco de Dados: Uso do Flyway para garantir a evolução controlada do esquema do banco de dados.

## 📋 Sumário
-	[Tecnologias Utilizadas](#-tecnologias-utilizadas)
-	[Instalação](#%EF%B8%8F-instalação)  
    - [Pré-requisitos](#pré-requisitos)
    - [Configuração do Backend](#configuração-do-backend)
    - [Configuração do Frontend](#configuração-do-frontend)    
-	[Uso da Aplicação](#-uso-da-aplicação)
-	[Capturas de Tela/GIFs](#%EF%B8%8F-capturas-de-telagifs)
-	[Autores](#%E2%80%8D-autor)
________________________________________
# 💻 Tecnologias Utilizadas
O projeto é estruturado em duas partes principais: Backend (Java/Spring Boot) e Frontend (Flutter/Dart).

### Backend (Java)
| Categoria |	Tecnologia | Versão (Inferida) |
|:-:|:-:|:-:|
| Linguagem | Java	| 17+ (Recomendado) |
| Framework	| Spring Boot	|3.x.x
| Segurança| Spring Security	| - |
| Autenticação | JWT (JSON Web Tokens) | - |
| Persistência | Spring Data JPA	| - |
| Queries/Filtros |	JPA Specifications	|- |
| Migrações | DB	Flyway	| - |
| WebSockets |	Spring STOMP |	- |
| Build Tool | Maven | - |
| Testes |	JUnit 5, JaCoCo |	- |

### Frontend (Cross-Platform)
| Categoria |	Tecnologia | Versão (Inferida) |
|:-:|:-:|:-:|
| Linguagem |	Dart |	- |
| Framework |	Flutter |	3.16.x+ |
| Plataformas |	Android, Web | - |

### Banco de Dados
-	PostgreSQL (Sugestão para produção/desenvolvimento. Pode ser configurado para H2 para testes ou ambiente local rápido).
________________________________________
# 🛠️ Instalação

### Pré-requisitos
Certifique-se de ter as seguintes ferramentas instaladas:
-	Java Development Kit (JDK): Versão 17 ou superior.
-	Maven: Para gerenciar o projeto Backend.
-	Flutter SDK: Instalado e configurado para sua plataforma de desenvolvimento.
-	PostgreSQL: Servidor de banco de dados rodando localmente ou acesso a uma instância remota.
  
### Configuração do Backend

1.	Clone o repositório:
```bash 
git clone https://github.com/MatheusWDB/lance-certo
cd lance-certo/backend
```

2.	Configurar o Banco de Dados:
    -	Crie um banco de dados PostgreSQL chamado, por exemplo, lance_certo_db.

3.  Configuar as variáveis de ambiente:
    - Crie um arquivo .env em ../backend
    - Crie e atribua os valores para as variáveis:
 ```bash 
PROFILE_ACTIVE
DB_USER
DB_PASSWORD
DB_NAME
JWT_SECRET
JWT_EXPIRATION
CORS_ALLOWED_ORIGINS (Use "[*]" no lugar da porta para aceitar qualquer uma. Aceita mais de um endereço se separado por vírgula.)
PASSWORD_TEST (Somente se PROFILE_ACTIVE="test").
```

4.	Executar o Backend:
```bash 
mvn clean install
mvn spring-boot:run
```

O Backend será iniciado, por padrão, em http://localhost:8080. As migrações do Flyway serão executadas automaticamente.

### Configuração do Frontend
1.	Navegue para o diretório Frontend:
```bash 
cd ../frontend
```
2.	Obtenha as dependências:
```bash 
flutter pub get
```
3.	Configurar o Endereço do Backend:
    -	Crie um arquivo .env em ../frontend
    -	Crie uma variável "URL".
```bash 
URL='endereço do Backend' ('127.0.0.1:8080' para usar no chrome, '10.0.2.2:8080' para usar no emulador e 'seuIp:8080' para usar no smartphone)
```
4.	Executar a Aplicação:
o	Execute em um emulador, dispositivo físico ou navegador:
```bash 
# Para rodar no Chrome (Web)
flutter run -d chrome

# Para rodar em um emulador Android/iOS
flutter run
```
________________________________________
# 🏃 Uso da Aplicação
Após a instalação e execução das partes Frontend e Backend:
1.	Registro de Usuário: Acesse a tela de cadastro para criar uma nova conta.

2.	Login: Use as credenciais para acessar a tela inicial. Um JWT será emitido e usado nas requisições subsequentes.

3.	Gerenciamento de Produtos/Leilões: Usuários autorizados podem criar novos produtos e iniciar leilões, definindo preço inicial e data/hora de encerramento.

4.	Participação em Leilões:
    -	Navegue pela lista de leilões ativos.
    -	Entre em uma sala de leilão específica.
    -	Faça seu lance! Devido ao WebSocket, o preço atual e o usuário do último lance serão atualizados em tempo real para todos os participantes.

### Endpoints Principais da API (Backend):
🛡️ Autenticação e Usuários (/api/users)
| Funcionalidade | Método | Endpoint (Exemplo) | Requer Token? | Descrição |
|:-:|:-:|:-:|:-:|:-:|
| Login | POST | /api/users/login | Não | Gera o token JWT ao autenticar o usuário. |
| Registro | POST | /api/users/register | Não | Cria uma nova conta de usuário. |

🔨 Leilões (/api/auctions)
| Funcionalidade | Método | Endpoint (Exemplo) | Requer Token? | Descrição |
|:-:|:-:|:-:|:-:|:-:|
| Listar/Filtrar | GET | /api/auctions?... | Não | Lista todos os leilões (suporta paginação e múltiplos filtros via AuctionFilterParamsDTO). |
| Buscar Por ID | GET| /api/auctions/{id} | Não | Retorna os detalhes de um leilão específico. |
| Criar Leilão | POST| /api/auctions/create/sellers | Sim | Cria um novo leilão (requer autenticação do tipo Vendedor). |
| Meus Leilões | GET | /api/auctions/seller | Sim | Lista todos os leilões criados pelo usuário autenticado (Vendedor). |

💰 Lances (/api/bids)
| Funcionalidade | Método | Endpoint (Exemplo) | Requer Token? | Descrição |
|:-:|:-:|:-:|:-:|:-:|
|Fazer um Lance|POST|/api/bids/auctions/{auctionId}/bidder|Sim|Envia um novo lance para o leilão especificado.|
|Histórico de Lances|GET|/api/bids/auctions/{auctionId}|Não|Lista o histórico de lances para um leilão (ordenado por valor decrescente).|
|Meus Lances|GET|/api/bids/bidder|Sim|Lista todos os lances feitos pelo usuário autenticado.|

📦 Produtos (/api/products)
| Funcionalidade | Método | Endpoint (Exemplo) | Requer Token? | Descrição |
|:-:|:-:|:-:|:-:|:-:|
|Criar Produto|POST|/api/products/create/sellers|Sim|Cria um novo produto (requer autenticação do tipo Vendedor).|
|Buscar Produto|GET|/api/products?name={nome}|Não|Busca produtos por name ou category (requer pelo menos um parâmetro).|
|Meus Produtos/Vendedor|GET|/api/products/seller?param={login}|Sim|Lista produtos: sem parâmetro, lista os do usuário autenticado. Com param, lista os do vendedor com esse login.|

🔔 Comunicação em Tempo Real (WebSocket)
| Funcionalidade | Método | Endpoint (Exemplo) | Requer Token? | Descrição |
|:-:|:-:|:-:|:-:|:-:|
|Conexão STOMP|WS|/ws|Sim|Endpoint para iniciar a conexão WebSocket/STOMP. O token JWT é enviado no header Authorization no comando CONNECT.|


________________________________________
# 🖼️ Capturas de Tela/GIFs
| ![0](https://github.com/user-attachments/assets/2eec55fc-86d3-427e-9061-8883c31803e7) | ![1](https://github.com/user-attachments/assets/5104d5a5-bd01-46da-b277-fd65046b3939) | ![2](https://github.com/user-attachments/assets/4c145ef6-d35b-4c0c-a9d5-904be0b14faa) |
|:-------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------:|
| ![3](https://github.com/user-attachments/assets/2be1e9bb-010a-43a4-a123-d10057491ce7) | ![4](https://github.com/user-attachments/assets/08fc699d-b825-4038-8789-da927ddca051) | ![5](https://github.com/user-attachments/assets/389f48a6-e0c5-4c13-8d23-e3a383099425) |
| ![6](https://github.com/user-attachments/assets/fae2fcf0-5250-40ec-98d6-294259970372) | ![7](https://github.com/user-attachments/assets/c91793d7-60b2-4b9c-a01d-1c5940ec25f7) | ![8](https://github.com/user-attachments/assets/1a97c6be-7489-4823-8da5-aaa85d61dd22) | 
| ![9](https://github.com/user-attachments/assets/1626bd61-b9c2-496d-98b2-d8e76d71f138) | ![10](https://github.com/user-attachments/assets/5b0dbbb8-2ff8-488c-a5d1-ad89644e3d92) | ![11](https://github.com/user-attachments/assets/638278ec-3f42-4586-8581-5f2ce9719fa1)
________________________________________

## 🧑‍💻 Autor
###	Matheus Wendell Dantas Bezerra
- [LinkedIn](https://www.linkedin.com/in/mwdb1703)
- [Portfólio]( https://matheus-wendell.onrender.com/)
