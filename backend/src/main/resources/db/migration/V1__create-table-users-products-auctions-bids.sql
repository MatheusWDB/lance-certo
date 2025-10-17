CREATE TABLE
    tb_users (
        id BIGSERIAL PRIMARY KEY,
        username VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        name VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL,
        phone VARCHAR(50) NOT NULL UNIQUE,
        created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL
    );

CREATE TABLE
    tb_products (
        id BIGSERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        image_url VARCHAR(255) NULL,
        category VARCHAR(50) NULL,
        seller_id BIGINT NOT NULL,
        created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        FOREIGN KEY (seller_id) REFERENCES tb_users (id)
    );

CREATE TABLE
    tb_auctions (
        id BIGSERIAL PRIMARY KEY,
        product_id BIGINT NOT NULL,
        seller_id BIGINT NOT NULL,
        start_date_and_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        end_date_and_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        initial_price DECIMAL(19, 2) NOT NULL,
        minimun_bid_increment DECIMAL(19, 2) NOT NULL,
        current_bid DECIMAL(19, 2) NOT NULL,
        current_bidder_id BIGINT NULL,
        status VARCHAR(50) NOT NULL,
        winner_id BIGINT NULL,
        created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        FOREIGN KEY (product_id) REFERENCES tb_products (id),
        FOREIGN KEY (seller_id) REFERENCES tb_users (id),
        FOREIGN KEY (current_bidder_id) REFERENCES tb_users (id),
        FOREIGN KEY (winner_id) REFERENCES tb_users (id)
    );

CREATE TABLE
    tb_bids (
        id BIGSERIAL PRIMARY KEY,
        auction_id BIGINT NOT NULL,
        bidder_id BIGINT NOT NULL,
        amount DECIMAL(19, 2) NOT NULL,
        created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        FOREIGN KEY (auction_id) REFERENCES tb_auctions (id),
        FOREIGN KEY (bidder_id) REFERENCES tb_users (id)
    );

CREATE INDEX idx_users_username ON tb_users (username);

CREATE INDEX idx_users_email ON tb_users (email);

CREATE INDEX idx_users_role ON tb_users (role);

CREATE INDEX idx_products_seller_id ON tb_products (seller_id);

CREATE INDEX idx_auctions_product_id ON tb_auctions (product_id);

CREATE INDEX idx_auctions_seller_id ON tb_auctions (seller_id);

CREATE INDEX idx_auctions_status ON tb_auctions (status);

CREATE INDEX idx_auctions_start_date_and_time ON tb_auctions (start_date_and_time);

CREATE INDEX idx_auctions_end_date_and_time ON tb_auctions (end_date_and_time);

CREATE INDEX idx_bids_auction_id ON tb_bids (auction_id);

CREATE INDEX idx_bids_bidder_id ON tb_bids (bidder_id);

CREATE INDEX idx_bids_created_at ON tb_bids (created_at);

CREATE INDEX idx_bids_amount ON tb_bids (amount);  