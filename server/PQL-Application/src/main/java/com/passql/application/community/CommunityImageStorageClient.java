package com.passql.application.community;

import com.passql.application.storage.ObjectStorageClient;
import com.passql.application.storage.ObjectStorageException;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 커뮤니티 이미지 저장소 접근: 공통 ObjectStorageClient 위임 + 503 변환
 * 저장소 실패(ObjectStorageException) > COMMUNITY_IMAGE_STORAGE_UNAVAILABLE
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CommunityImageStorageClient {

    private static final String WEBP_CONTENT_TYPE = "image/webp";

    private final ObjectStorageClient objectStorageClient;

    public boolean isEnabled() {
        return objectStorageClient.isEnabled();
    }

    /** 비활성이면 503 */
    public void requireEnabled() {
        if (!isEnabled()) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_STORAGE_UNAVAILABLE);
        }
    }

    public void putWebp(String objectKey, byte[] bytes) {
        try {
            objectStorageClient.put(objectKey, bytes, WEBP_CONTENT_TYPE);
        } catch (ObjectStorageException e) {
            throw toUnavailable(e);
        }
    }

    public byte[] read(String objectKey) {
        try {
            return objectStorageClient.read(objectKey);
        } catch (ObjectStorageException e) {
            throw toUnavailable(e);
        }
    }

    public void copy(String sourceKey, String destinationKey) {
        try {
            objectStorageClient.copy(sourceKey, destinationKey);
        } catch (ObjectStorageException e) {
            throw toUnavailable(e);
        }
    }

    public void deleteQuietly(String objectKey) {
        objectStorageClient.deleteQuietly(objectKey);
    }

    // 원인 로그(활성 상태의 SDK 오류만) > 503
    private CustomException toUnavailable(ObjectStorageException e) {
        if (e.getCause() != null) {
            log.error("[community image] storage {} failed : cause={}", e.getOperationName(), e.getCause().getClass().getSimpleName());
        }
        return new CustomException(ErrorCode.COMMUNITY_IMAGE_STORAGE_UNAVAILABLE);
    }
}
