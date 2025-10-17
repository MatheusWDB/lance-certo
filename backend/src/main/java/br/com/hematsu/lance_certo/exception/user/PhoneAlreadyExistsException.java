package br.com.hematsu.lance_certo.exception.user;

public class PhoneAlreadyExistsException extends RuntimeException {
    public PhoneAlreadyExistsException() {
        super("Telefone já cadastrado.");
    }

    public PhoneAlreadyExistsException(String msg) {
        super(msg);
    }
}