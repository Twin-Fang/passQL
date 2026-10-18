package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CopyObjectRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.core.exception.SdkException;

/**
 * 커뮤니티 이미지 저장소(S3 호환 MinIO) 접근: 저장, 읽기, 복사, 삭제
 * 설정(passql.storage.*)이 없으면 비활성, 호출하면 503 (COMMUNITY_IMAGE_STORAGE_UNAVAILABLE)
 */
@Slf4j
@Component
public class CommunityImageStorageClient {

    private static final String WEBP_CONTENT_TYPE = "image/webp";

    private final ObjectProvider<S3Client> s3ClientProvider;
    // passql.storage.bucket: 전용 버킷 이름 (없으면 빈 값 = 기능 비활성)
    private final String bucketName;

    public CommunityImageStorageClient(ObjectProvider<S3Client> s3ClientProvider,
                                       @Value("${passql.storage.bucket:}") String bucketName) {
        this.s3ClientProvider = s3ClientProvider;
        this.bucketName = bucketName;
    }

    public boolean isEnabled() {
        return !bucketName.isBlank() && s3ClientProvider.getIfAvailable() != null;
    }

    /** 비활성이면 503 */
    public void requireEnabled() {
        if (!isEnabled()) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_STORAGE_UNAVAILABLE);
        }
    }

    public void putWebp(String objectKey, byte[] bytes) {
        execute("put", () -> requireClient().putObject(PutObjectRequest.builder()
                .bucket(bucketName).key(objectKey).contentType(WEBP_CONTENT_TYPE).build(), RequestBody.fromBytes(bytes)));
    }

    public byte[] read(String objectKey) {
        try {
            return requireClient().getObjectAsBytes(GetObjectRequest.builder().bucket(bucketName).key(objectKey).build()).asByteArray();
        } catch (SdkException e) {
            log.error("[community image] storage read failed : key={}, cause={}", objectKey, e.getClass().getSimpleName());
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_STORAGE_UNAVAILABLE);
        }
    }

    public void copy(String sourceKey, String destinationKey) {
        execute("copy", () -> requireClient().copyObject(CopyObjectRequest.builder()
                .sourceBucket(bucketName).sourceKey(sourceKey).destinationBucket(bucketName).destinationKey(destinationKey).build()));
    }

    /** 삭제 실패는 예외 없이 로그만 (남은 객체는 다음 정리 때 다시 시도하지 않음, 용량 영향 작음) */
    public void deleteQuietly(String objectKey) {
        try {
            S3Client client = s3ClientProvider.getIfAvailable();
            if (client != null && !bucketName.isBlank()) {
                client.deleteObject(DeleteObjectRequest.builder().bucket(bucketName).key(objectKey).build());
            }
        } catch (SdkException e) {
            log.warn("[community image] storage delete failed : key={}, cause={}", objectKey, e.getClass().getSimpleName());
        }
    }

    private S3Client requireClient() {
        requireEnabled();
        return s3ClientProvider.getObject();
    }

    private void execute(String operationName, Runnable operation) {
        try {
            operation.run();
        } catch (SdkException e) {
            log.error("[community image] storage {} failed : cause={}", operationName, e.getClass().getSimpleName());
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_STORAGE_UNAVAILABLE);
        }
    }
}
