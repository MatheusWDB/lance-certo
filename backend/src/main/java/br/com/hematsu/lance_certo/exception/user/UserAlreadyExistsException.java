package br.com.hematsu.lance_certo.exception.user;

public class UserAlreadyExistsException extends RuntimeException {
    
    public UserAlreadyExistsException(){
        super("Email ou username já cadastrados!");
    }
    
    public UserAlreadyExistsException(String msg){
        super(msg);
    }
}
