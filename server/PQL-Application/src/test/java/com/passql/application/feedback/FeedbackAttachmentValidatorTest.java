package com.passql.application.feedback;

import static com.passql.application.feedback.FeedbackAttachmentValidator.MAX_IMAGE_COUNT;
import static com.passql.application.feedback.FeedbackAttachmentValidator.parseDiagnostics;
import static com.passql.application.feedback.FeedbackAttachmentValidator.validateImage;
import static com.passql.application.feedback.FeedbackAttachmentValidator.validateImageCount;
import static com.passql.application.feedback.FeedbackAttachmentValidator.validateLog;
import static java.nio.charset.StandardCharsets.UTF_8;
import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import org.junit.jupiter.api.Test;

/** 첨부 검증 판정: 이미지 장수·형식·용량·긴 변, 진단 JSON, 로그 gzip */
class FeedbackAttachmentValidatorTest {

    private final ObjectMapper mapper = new ObjectMapper();

    @Test void 이미지_6장이면_거절() { assertCode(() -> validateImageCount(6), ErrorCode.FEEDBACK_IMAGE_TOO_MANY); }
    @Test void 이미지_5장은_통과() { assertDoesNotThrow(() -> validateImageCount(5)); }
    @Test void 장수_초과_문구가_한도와_같음() { assertTrue(ErrorCode.FEEDBACK_IMAGE_TOO_MANY.getMessage().contains("최대 " + MAX_IMAGE_COUNT + "장")); }
    @Test void PNG_바이트는_거절() { assertCode(() -> validateImage(pngBytes()), ErrorCode.FEEDBACK_IMAGE_INVALID); }
    @Test void 용량_300KB_초과_거절() { assertCode(() -> validateImage(webpOf(100, 100, 300 * 1024 + 1)), ErrorCode.FEEDBACK_ATTACHMENT_TOO_LARGE); }
    @Test void 긴변_1281px_거절() { assertCode(() -> validateImage(webpOf(1281, 10, 1024)), ErrorCode.FEEDBACK_IMAGE_INVALID); }
    @Test void 긴변_1280px_통과() { assertEquals(1280, validateImage(webpOf(1280, 10, 1024)).widthPixels()); }
    @Test void 진단_배열이면_거절() { assertCode(() -> parseDiagnostics("[1]".getBytes(UTF_8), mapper), ErrorCode.FEEDBACK_ATTACHMENT_INVALID); }
    @Test void 진단_깨진JSON_거절() { assertCode(() -> parseDiagnostics("{".getBytes(UTF_8), mapper), ErrorCode.FEEDBACK_ATTACHMENT_INVALID); }
    @Test void 로그_gzip_아니면_거절() { assertCode(() -> validateLog("plain".getBytes(UTF_8)), ErrorCode.FEEDBACK_ATTACHMENT_INVALID); }
    @Test void 로그_512KB_초과_거절() { assertCode(() -> validateLog(gzipMagicPadded(512 * 1024 + 1)), ErrorCode.FEEDBACK_ATTACHMENT_TOO_LARGE); }

    private static void assertCode(Runnable action, ErrorCode expected) {
        CustomException thrown = assertThrows(CustomException.class, action::run);
        assertEquals(expected, thrown.getErrorCode());
    }

    // PNG 시그니처 + 패딩 (WebP 아님)
    private static byte[] pngBytes() {
        byte[] bytes = new byte[64];
        byte[] signature = {(byte) 0x89, 'P', 'N', 'G', 0x0d, 0x0a, 0x1a, 0x0a};
        System.arraycopy(signature, 0, bytes, 0, signature.length);
        return bytes;
    }

    // VP8X WebP 헤더: RIFF + 크기(총길이-8) + WEBP + VP8X + 청크크기 10 + 플래그 4 + (가로-1, 세로-1 각 24비트 LE), 나머지 0 패딩
    private static byte[] webpOf(int widthPixels, int heightPixels, int totalBytes) {
        byte[] bytes = new byte[totalBytes];
        putAscii(bytes, 0, "RIFF");
        putLittleEndian(bytes, 4, totalBytes - 8, 4);
        putAscii(bytes, 8, "WEBP");
        putAscii(bytes, 12, "VP8X");
        putLittleEndian(bytes, 16, 10, 4);
        putLittleEndian(bytes, 24, widthPixels - 1, 3);
        putLittleEndian(bytes, 27, heightPixels - 1, 3);
        return bytes;
    }

    private static byte[] gzipMagicPadded(int totalBytes) {
        byte[] bytes = new byte[totalBytes];
        bytes[0] = 0x1f;
        bytes[1] = (byte) 0x8b;
        return bytes;
    }

    private static void putAscii(byte[] bytes, int offset, String text) {
        for (int index = 0; index < text.length(); index++) {
            bytes[offset + index] = (byte) text.charAt(index);
        }
    }

    private static void putLittleEndian(byte[] bytes, int offset, int value, int length) {
        for (int index = 0; index < length; index++) {
            bytes[offset + index] = (byte) ((value >> (8 * index)) & 0xFF);
        }
    }
}
