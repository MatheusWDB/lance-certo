package br.com.hematsu.lance_certo.exception;

import java.util.List;

import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import br.com.hematsu.lance_certo.exception.auction.AuctionCannotBeCancelledException;
import br.com.hematsu.lance_certo.exception.auction.NotAuctionOwnerException;
import br.com.hematsu.lance_certo.exception.auction.ProductAlreadyInAuctionException;
import br.com.hematsu.lance_certo.exception.bid.InvalidBidException;
import br.com.hematsu.lance_certo.exception.user.PhoneAlreadyExistsException;
import br.com.hematsu.lance_certo.exception.user.UserAlreadyExistsException;
import jakarta.servlet.http.HttpServletRequest;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(AuctionCannotBeCancelledException.class)
    public ResponseEntity<StandardError> auctionCannotBeCancelledException(AuctionCannotBeCancelledException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.CONFLICT;
        String error = status.getReasonPhrase();
        StandardError err = new StandardError(status, error, e.getMessage(), request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(NotAuctionOwnerException.class)
    public ResponseEntity<StandardError> notAuctionOwnerException(NotAuctionOwnerException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.FORBIDDEN;
        String error = status.getReasonPhrase();
        StandardError err = new StandardError(status, error, e.getMessage(), request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(ProductAlreadyInAuctionException.class)
    public ResponseEntity<StandardError> productAlreadyInAuctionException(ProductAlreadyInAuctionException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.CONFLICT;
        String error = status.getReasonPhrase();
        StandardError err = new StandardError(status, error, e.getMessage(), request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(InvalidBidException.class)
    public ResponseEntity<StandardError> invalidBidException(InvalidBidException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        String error = status.getReasonPhrase();
        StandardError err = new StandardError(status, error, e.getMessage(), request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(UserAlreadyExistsException.class)
    public ResponseEntity<StandardError> userAlreadyExistsException(UserAlreadyExistsException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.CONFLICT;
        String error = status.getReasonPhrase();
        StandardError err = new StandardError(status, error, e.getMessage(), request.getRequestURI());

        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(PhoneAlreadyExistsException.class)
    public ResponseEntity<StandardError> phoneAlreadyExistsException(PhoneAlreadyExistsException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.CONFLICT;
        String error = status.getReasonPhrase();
        StandardError err = new StandardError(status, error, e.getMessage(), request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<StandardError> resourceNotFoundException(ResourceNotFoundException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.NOT_FOUND;
        String error = status.getReasonPhrase();
        StandardError err = new StandardError(status, error, e.getMessage(), request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<StandardError> authenticationException(AuthenticationException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.UNAUTHORIZED;
        String error = status.getReasonPhrase();
        String message = "Credenciais de login inválidas!";
        StandardError err = new StandardError(status, error, message, request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<StandardError> handleAccessDeniedException(AccessDeniedException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.FORBIDDEN;
        String error = status.getReasonPhrase();
        String message = "Access Denied: You do not have permission to access this resource.";

        StandardError err = new StandardError(status, error, message, request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<StandardError> missingServletRequestParameterException(
            MissingServletRequestParameterException e, HttpServletRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        String error = status.getReasonPhrase();
        String parameterName = e.getParameterName();
        String message = "O parâmetro '" + parameterName + "' é obrigatório.";

        StandardError err = new StandardError(status, error, message, request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<StandardError> illegalArgumentException(
            IllegalArgumentException e, HttpServletRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        String error = status.getReasonPhrase();
        String message = e.getMessage();

        StandardError err = new StandardError(status, error, message, request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<StandardError> methodArgumentNotValidException(MethodArgumentNotValidException e,
            HttpServletRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        String error = status.getReasonPhrase();
        List<String> validationErrors = e.getBindingResult()
                .getAllErrors()
                .stream()
                .map(DefaultMessageSourceResolvable::getDefaultMessage)
                .toList();
        StandardError err = new StandardError(status, error, "Validation Failed", validationErrors,
                request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<StandardError> handleAllOtherExceptions(Exception e, HttpServletRequest request) {

        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        String error = status.getReasonPhrase();

        StandardError err = new StandardError(status, error, "Ocorreu um erro inesperado.", request.getRequestURI());
        return ResponseEntity.status(status).body(err);
    }
}
