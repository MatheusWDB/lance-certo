package br.com.hematsu.lance_certo.exception.auction;

public class ProductAlreadyInAuctionException extends RuntimeException {

    public ProductAlreadyInAuctionException(){
        super("O produto já está vinculado a um leilão em andamento!");
    }
    
    public ProductAlreadyInAuctionException(String msg){
        super(msg);
    }
}
