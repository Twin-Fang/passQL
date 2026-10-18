package com.passql.common.util;

import java.util.Optional;

/**
 * WebP 헤더 판별: RIFF....WEBP 매직바이트 확인 > 형식별(VP8, VP8L, VP8X) 가로·세로 읽기
 * 디코딩·재인코딩 없이 앞 30바이트만 읽음, Content-Type·확장자는 보지 않음
 */
public final class WebpImageHeader {

    // 헤더 최소 길이: RIFF(4) + 크기(4) + WEBP(4) + 청크명(4) + 청크크기(4) + 형식별 헤더
    private static final int MINIMUM_HEADER_BYTES = 30;
    private static final int RIFF_SIZE_FIELD_OFFSET = 4;
    private static final int RIFF_PREFIX_BYTES = 8;
    private static final int CHUNK_NAME_OFFSET = 12;

    private WebpImageHeader() {
    }

    /** 판별 결과: 가로·세로 픽셀 */
    public record Dimensions(int widthPixels, int heightPixels) {
        public int longSidePixels() {
            return Math.max(widthPixels, heightPixels);
        }
    }

    /** WebP 가 아니거나 헤더가 깨졌거나 잘렸으면 빈 값 */
    public static Optional<Dimensions> parse(byte[] bytes) {
        if (bytes == null || bytes.length < MINIMUM_HEADER_BYTES
                || !hasAscii(bytes, 0, "RIFF") || !hasAscii(bytes, 8, "WEBP")) {
            return Optional.empty();
        }
        // RIFF 크기 필드가 실제 길이보다 크면 잘린 파일
        long riffPayloadBytes = readUnsignedLittleEndian(bytes, RIFF_SIZE_FIELD_OFFSET, 4);
        if (riffPayloadBytes + RIFF_PREFIX_BYTES > bytes.length) {
            return Optional.empty();
        }
        int width;
        int height;
        if (hasAscii(bytes, CHUNK_NAME_OFFSET, "VP8 ")) {
            // 손실 압축: 프레임 시작 코드 9d 01 2a 뒤에 14비트 가로·세로
            if ((bytes[23] & 0xFF) != 0x9d || (bytes[24] & 0xFF) != 0x01 || (bytes[25] & 0xFF) != 0x2a) {
                return Optional.empty();
            }
            width = (int) (readUnsignedLittleEndian(bytes, 26, 2) & 0x3FFF);
            height = (int) (readUnsignedLittleEndian(bytes, 28, 2) & 0x3FFF);
        } else if (hasAscii(bytes, CHUNK_NAME_OFFSET, "VP8L")) {
            // 무손실: 시그니처 0x2f 뒤에 (가로-1) 14비트, (세로-1) 14비트
            if ((bytes[20] & 0xFF) != 0x2f) {
                return Optional.empty();
            }
            long packed = readUnsignedLittleEndian(bytes, 21, 4);
            width = (int) (packed & 0x3FFF) + 1;
            height = (int) ((packed >> 14) & 0x3FFF) + 1;
        } else if (hasAscii(bytes, CHUNK_NAME_OFFSET, "VP8X")) {
            // 확장 형식: 캔버스 (가로-1), (세로-1) 각 24비트
            width = (int) readUnsignedLittleEndian(bytes, 24, 3) + 1;
            height = (int) readUnsignedLittleEndian(bytes, 27, 3) + 1;
        } else {
            return Optional.empty();
        }
        if (width < 1 || height < 1) {
            return Optional.empty();
        }
        return Optional.of(new Dimensions(width, height));
    }

    private static boolean hasAscii(byte[] bytes, int offset, String expected) {
        for (int index = 0; index < expected.length(); index++) {
            if (bytes[offset + index] != (byte) expected.charAt(index)) {
                return false;
            }
        }
        return true;
    }

    private static long readUnsignedLittleEndian(byte[] bytes, int offset, int length) {
        long value = 0;
        for (int index = length - 1; index >= 0; index--) {
            value = (value << 8) | (bytes[offset + index] & 0xFF);
        }
        return value;
    }
}
