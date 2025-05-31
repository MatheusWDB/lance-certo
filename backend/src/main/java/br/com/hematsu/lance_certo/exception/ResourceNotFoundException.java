package br.com.hematsu.lance_certo.exception;

public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String resource) {
        super(resource + ", não encontrado!");
    }
}
