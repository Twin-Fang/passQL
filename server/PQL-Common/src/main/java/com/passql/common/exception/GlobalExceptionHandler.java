package com.passql.common.exception;

import io.swagger.v3.oas.annotations.Hidden;
import jakarta.servlet.http.HttpServletRequest;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.NoHandlerFoundException;

import java.util.stream.Collectors;

/**
 * 전역 예외 처리 핸들러 애플리케이션에서 발생하는 다양한 예외를 처리하고 일관된 응답 형식으로 변환
 */
@Slf4j
@Hidden
@RestControllerAdvice(basePackages = "com.passql")
public class GlobalExceptionHandler {

    /**
     * 5xx 로 응답한 예외의 요약을 담는 요청 속성. 핸들러가 응답을 만들면 예외가 필터까지 올라가지 않으므로
     * RequestTraceFilter 가 서버 오류 기록(#440)에 원인을 남길 수 있도록 여기서 넘겨준다.
     */
    public static final String ERROR_DETAIL_ATTR = "passql.error.detail";

    @ExceptionHandler(CustomException.class)
    public ResponseEntity<ErrorResponse> handleCustomException(CustomException e, HttpServletRequest request) {
        String errorCode = e.getErrorCode() != null ? e.getErrorCode().name() : null;
        // 4xx는 클라이언트 요청 문제라 WARN, 5xx만 ERROR — 실제 장애가 묻히지 않게 한다 (#395)
        if (e.getStatus() != null && e.getStatus().is5xxServerError()) {
            log.error("[예외 처리] CustomException 발생: errorCode={}, message={}, path={}, method={}",
                errorCode, e.getMessage(), request.getRequestURI(), request.getMethod());
            request.setAttribute(ERROR_DETAIL_ATTR, errorCode + ": " + e.getMessage());
        } else {
            log.warn("[예외 처리] CustomException 발생: errorCode={}, message={}, path={}, method={}",
                errorCode, e.getMessage(), request.getRequestURI(), request.getMethod());
        }
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode(errorCode)
            .message(e.getMessage())
            .build();
        return ResponseEntity.status(e.getStatus()).body(errorResponse);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(
        IllegalArgumentException e, HttpServletRequest request) {
        log.warn("IllegalArgumentException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode("ILLEGAL_ARGUMENT")
            .message(e.getMessage())
            .build();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
        MethodArgumentNotValidException e, HttpServletRequest request) {
        String errorMessage = e.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(DefaultMessageSourceResolvable::getDefaultMessage)
            .collect(Collectors.joining(", "));
        log.warn("[예외 처리] Validation 실패: message={}, path={}, method={}",
            errorMessage, request.getRequestURI(), request.getMethod());
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode("VALIDATION_ERROR")
            .message(errorMessage)
            .build();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleHttpMessageNotReadableException(
        HttpMessageNotReadableException e, HttpServletRequest request) {
        // 파서 메시지에 컨트롤러 시그니처가 섞여 나가므로 응답에는 고정 문구만 쓴다 (#393)
        log.warn("HttpMessageNotReadableException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode("MESSAGE_NOT_READABLE")
            .message("요청 본문을 읽을 수 없습니다. 형식을 확인해주세요")
            .build();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ErrorResponse> handleMissingServletRequestParameterException(
        MissingServletRequestParameterException e, HttpServletRequest request)
        throws MissingServletRequestParameterException {
        log.warn("MissingServletRequestParameterException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode("MISSING_PARAMETER")
            .message("필수 파라미터가 누락되었습니다: " + e.getParameterName())
            .build();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleMethodArgumentTypeMismatchException(
        MethodArgumentTypeMismatchException e, HttpServletRequest request) {
        log.warn("MethodArgumentTypeMismatchException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode("TYPE_MISMATCH")
            .message(String.format("파라미터 '%s'의 값 '%s'가 올바른 형식이 아닙니다", e.getName(), e.getValue()))
            .build();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    public ResponseEntity<ErrorResponse> handleNoHandlerFoundException(
        NoHandlerFoundException e, HttpServletRequest request) throws NoHandlerFoundException {
        log.warn("NoHandlerFoundException 발생: {}", e.getMessage());
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode("NOT_FOUND")
            .message(String.format("요청하신 리소스를 찾을 수 없습니다: %s %s", e.getHttpMethod(), e.getRequestURL()))
            .build();
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleHttpMediaTypeNotSupportedException(
        HttpMediaTypeNotSupportedException e, HttpServletRequest request) {
        // 미지원 Content-Type이 처리되지 않은 예외로 떨어져 500이 나던 문제 (#393)
        log.warn("HttpMediaTypeNotSupportedException 발생: path={}, contentType={}",
            request.getRequestURI(), e.getContentType());
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode(ErrorCode.UNSUPPORTED_MEDIA_TYPE.name())
            .message(ErrorCode.UNSUPPORTED_MEDIA_TYPE.getMessage())
            .build();
        return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE).body(errorResponse);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleHttpRequestMethodNotSupportedException(
        HttpRequestMethodNotSupportedException e, HttpServletRequest request) {
        log.warn("HttpRequestMethodNotSupportedException 발생: path={}, method={}",
            request.getRequestURI(), request.getMethod());
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode(ErrorCode.METHOD_NOT_ALLOWED.name())
            .message(ErrorCode.METHOD_NOT_ALLOWED.getMessage())
            .build();
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED).body(errorResponse);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolationException(
        DataIntegrityViolationException e, HttpServletRequest request) {
        log.error("[예외 처리] DataIntegrityViolationException 발생: path={}, method={}",
            request.getRequestURI(), request.getMethod(), e);
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode("DATA_INTEGRITY_VIOLATION")
            .message("데이터 무결성 제약을 위반했습니다")
            .build();
        return ResponseEntity.status(HttpStatus.CONFLICT).body(errorResponse);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception e, HttpServletRequest request) throws Exception {
        log.error("처리되지 않은 예외 발생: {}", e.getMessage(), e);
        ErrorResponse errorResponse = ErrorResponse.builder()
            .errorCode("INTERNAL_SERVER_ERROR")
            .message("서버 내부 오류가 발생했습니다")
            .build();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
    }
}
