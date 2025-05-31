package br.com.hematsu.lance_certo.exception.auction;

public class NotAuctionOwnerException extends RuntimeException {

    public NotAuctionOwnerException(){
        super("Somente o dono do leilão pode cancelá-lo!");
    }
    
    public NotAuctionOwnerException(String msg){
        super(msg);
    }
}
