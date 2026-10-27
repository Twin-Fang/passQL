package com.passql.application.feedback;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.WebpImageHeader;

/**
 * 의견 첨부 검증: 이미지(장수, WebP 헤더, 용량, 긴 변), 진단 JSON(크기, 객체 여부), 로그(크기, gzip 매직바이트)
 * 디코딩·재인코딩 없이 바이트만 판정, Content-Type·확장자는 믿지 않음
 */
public final class FeedbackAttachmentValidator {

    // 이미지 최대 장수
    public static final int MAX_IMAGE_COUNT = 10;
    // 이미지 장당 최대 바이트 (600KB)
    public static final int MAX_IMAGE_BYTES = 600 * 1024;
    // 이미지 긴 변 최대 픽셀
    public static final int MAX_IMAGE_LONG_SIDE_PIXELS = 1920;
    // 진단 JSON 최대 바이트 (32KB)
    public static final int MAX_DIAGNOSTICS_BYTES = 32 * 1024;
    // 로그 gzip 최대 바이트 (2MB)
    public static final int MAX_LOG_BYTES = 2 * 1024 * 1024;

    // gzip 매직바이트: 1f 8b
    private static final int GZIP_MAGIC_FIRST_BYTE = 0x1f;
    private static final int GZIP_MAGIC_SECOND_BYTE = 0x8b;

    private FeedbackAttachmentValidator() {
    }

    /** 이미지 장수 상한 확인 */
    public static void validateImageCount(int imageCount) {
        if (imageCount > MAX_IMAGE_COUNT) {
            throw new CustomException(ErrorCode.FEEDBACK_IMAGE_TOO_MANY);
        }
    }

    /** 이미지 1장 검증: 비어 있음 > 용량 > WebP 헤더 > 긴 변 */
    public static WebpImageHeader.Dimensions validateImage(byte[] bytes) {
        if (bytes == null || bytes.length == 0) {
            throw new CustomException(ErrorCode.FEEDBACK_IMAGE_INVALID);
        }
        if (bytes.length > MAX_IMAGE_BYTES) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_TOO_LARGE);
        }
        WebpImageHeader.Dimensions dimensions = WebpImageHeader.parse(bytes)
                .orElseThrow(() -> new CustomException(ErrorCode.FEEDBACK_IMAGE_INVALID));
        if (dimensions.longSidePixels() > MAX_IMAGE_LONG_SIDE_PIXELS) {
            throw new CustomException(ErrorCode.FEEDBACK_IMAGE_INVALID);
        }
        return dimensions;
    }

    /** 진단 JSON 검증: 용량 > 파싱 > 객체 여부, 통과 시 파싱 결과 반환 */
    public static JsonNode parseDiagnostics(byte[] bytes, ObjectMapper objectMapper) {
        if (bytes == null || bytes.length == 0) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_INVALID);
        }
        if (bytes.length > MAX_DIAGNOSTICS_BYTES) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_TOO_LARGE);
        }
        JsonNode diagnostics;
        try {
            diagnostics = objectMapper.readTree(bytes);
        } catch (java.io.IOException exception) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_INVALID, exception);
        }
        if (diagnostics == null || !diagnostics.isObject()) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_INVALID);
        }
        return diagnostics;
    }

    /** 로그 검증: 용량 > gzip 매직바이트 (압축 해제는 하지 않음) */
    public static void validateLog(byte[] bytes) {
        if (bytes == null || bytes.length == 0) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_INVALID);
        }
        if (bytes.length > MAX_LOG_BYTES) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_TOO_LARGE);
        }
        if (!hasGzipMagicBytes(bytes)) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_INVALID);
        }
    }

    private static boolean hasGzipMagicBytes(byte[] bytes) {
        return bytes.length >= 2
                && (bytes[0] & 0xFF) == GZIP_MAGIC_FIRST_BYTE
                && (bytes[1] & 0xFF) == GZIP_MAGIC_SECOND_BYTE;
    }
}
