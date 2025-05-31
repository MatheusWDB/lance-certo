package br.com.hematsu.lance_certo.exception.auction;

public class AuctionCannotBeCancelledException extends RuntimeException {
    
    public AuctionCannotBeCancelledException(){
        super("Não é possível cancelar um leilão que não esteja com Status PENDENTE ou que tenha algum lance!");
    }
    
    public AuctionCannotBeCancelledException(String msg){
        super(msg);
    }
}
