package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.WebpImageHeader;

/**
 * 업로드 규격 검증: 크기 상한 > WebP 매직바이트·헤더 > 긴 변 상한 (디코딩·재인코딩 없음)
 * Content-Type·확장자는 믿지 않음
 */
public final class CommunityImageValidator {

    // 원본 최대 바이트 (500KB)
    public static final int MAX_IMAGE_BYTES = 500 * 1024;
    // 썸네일 최대 바이트 (60KB)
    public static final int MAX_THUMBNAIL_BYTES = 60 * 1024;
    // 긴 변 최대 픽셀
    public static final int MAX_LONG_SIDE_PIXELS = 1600;

    private CommunityImageValidator() {
    }

    /** 규격 안이면 가로·세로 반환, 아니면 400/413 */
    public static WebpImageHeader.Dimensions validate(byte[] bytes, int maxBytes) {
        if (bytes == null || bytes.length == 0) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_INVALID_FORMAT);
        }
        if (bytes.length > maxBytes) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_TOO_LARGE);
        }
        WebpImageHeader.Dimensions dimensions = WebpImageHeader.parse(bytes)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_IMAGE_INVALID_FORMAT));
        if (dimensions.longSidePixels() > MAX_LONG_SIDE_PIXELS) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_DIMENSION_EXCEEDED);
        }
        return dimensions;
    }
}
