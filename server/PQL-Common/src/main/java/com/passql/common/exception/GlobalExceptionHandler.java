package com.passql.common.exception;

import io.swagger.v3.oas.annotations.Hidden;
import jakarta.servlet.http.HttpServletRequest;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;
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

    // 처리되지 않은 예외 응답 문구 (내부 메시지 노출 방지용 고정값)
    private static final String UNHANDLED_EXCEPTION_MESSAGE = "서버 내부 오류가 발생했습니다";

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
        return toResponse(e.getErrorCode(), e.getMessage());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(
        IllegalArgumentException e, HttpServletRequest request) {
        log.warn("IllegalArgumentException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        return toResponse(ErrorCode.ILLEGAL_ARGUMENT, e.getMessage());
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
        return toResponse(ErrorCode.VALIDATION_ERROR, errorMessage);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleHttpMessageNotReadableException(
        HttpMessageNotReadableException e, HttpServletRequest request) {
        // 파서 메시지에 컨트롤러 시그니처가 섞여 나가므로 응답에는 고정 문구만 쓴다 (#393)
        log.warn("HttpMessageNotReadableException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        return toResponse(ErrorCode.MESSAGE_NOT_READABLE);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ErrorResponse> handleMissingServletRequestParameterException(
        MissingServletRequestParameterException e, HttpServletRequest request)
        throws MissingServletRequestParameterException {
        log.warn("MissingServletRequestParameterException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        return toResponse(ErrorCode.MISSING_PARAMETER,
            ErrorCode.MISSING_PARAMETER.getMessage() + ": " + e.getParameterName());
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<ErrorResponse> handleMaxUploadSizeExceededException(
        MaxUploadSizeExceededException e, HttpServletRequest request) {
        log.warn("MaxUploadSizeExceededException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        return toResponse(ErrorCode.REQUEST_TOO_LARGE);
    }

    @ExceptionHandler(MissingServletRequestPartException.class)
    public ResponseEntity<ErrorResponse> handleMissingServletRequestPartException(
        MissingServletRequestPartException e, HttpServletRequest request) {
        log.warn("MissingServletRequestPartException 발생: path={}, part={}", request.getRequestURI(), e.getRequestPartName());
        return toResponse(ErrorCode.MISSING_PARAMETER,
            ErrorCode.MISSING_PARAMETER.getMessage() + ": " + e.getRequestPartName());
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleMethodArgumentTypeMismatchException(
        MethodArgumentTypeMismatchException e, HttpServletRequest request) {
        log.warn("MethodArgumentTypeMismatchException 발생: path={}, message={}", request.getRequestURI(), e.getMessage());
        return toResponse(ErrorCode.TYPE_MISMATCH,
            String.format("파라미터 '%s'의 값 '%s'가 올바른 형식이 아닙니다", e.getName(), e.getValue()));
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    public ResponseEntity<ErrorResponse> handleNoHandlerFoundException(
        NoHandlerFoundException e, HttpServletRequest request) throws NoHandlerFoundException {
        log.warn("NoHandlerFoundException 발생: {}", e.getMessage());
        return toResponse(ErrorCode.RESOURCE_NOT_FOUND,
            String.format("요청하신 리소스를 찾을 수 없습니다: %s %s", e.getHttpMethod(), e.getRequestURL()));
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleHttpMediaTypeNotSupportedException(
        HttpMediaTypeNotSupportedException e, HttpServletRequest request) {
        // 미지원 Content-Type이 처리되지 않은 예외로 떨어져 500이 나던 문제 (#393)
        log.warn("HttpMediaTypeNotSupportedException 발생: path={}, contentType={}",
            request.getRequestURI(), e.getContentType());
        return toResponse(ErrorCode.UNSUPPORTED_MEDIA_TYPE);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleHttpRequestMethodNotSupportedException(
        HttpRequestMethodNotSupportedException e, HttpServletRequest request) {
        log.warn("HttpRequestMethodNotSupportedException 발생: path={}, method={}",
            request.getRequestURI(), request.getMethod());
        return toResponse(ErrorCode.METHOD_NOT_ALLOWED);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolationException(
        DataIntegrityViolationException e, HttpServletRequest request) {
        log.error("[예외 처리] DataIntegrityViolationException 발생: path={}, method={}",
            request.getRequestURI(), request.getMethod(), e);
        return toResponse(ErrorCode.DATA_INTEGRITY_VIOLATION);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception e, HttpServletRequest request) throws Exception {
        log.error("처리되지 않은 예외 발생: {}", e.getMessage(), e);
        return toResponse(ErrorCode.INTERNAL_SERVER_ERROR, UNHANDLED_EXCEPTION_MESSAGE);
    }

    /** ErrorCode > 상태 코드·기본 메시지 응답 */
    private ResponseEntity<ErrorResponse> toResponse(ErrorCode errorCode) {
        return toResponse(errorCode, errorCode.getMessage());
    }

    /** ErrorCode + 상황별 메시지 > 응답 (상태 코드는 ErrorCode 기준, 본문은 항상 JSON) */
    private ResponseEntity<ErrorResponse> toResponse(ErrorCode errorCode, String message) {
        // Accept 협상 생략: SSE(produces text/event-stream) 진입 전 거부도 JSON 본문 + 원래 상태 (협상 실패 시 500 빈 본문) (#576)
        return ResponseEntity.status(errorCode.getStatus())
            .contentType(MediaType.APPLICATION_JSON)
            .body(ErrorResponse.of(errorCode, message));
    }
}
