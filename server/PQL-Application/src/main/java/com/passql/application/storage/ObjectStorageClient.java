package com.passql.application.storage;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.core.exception.SdkException;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CopyObjectRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

/**
 * 공통 오브젝트 저장소(S3 호환 MinIO) 접근: 저장, 읽기, 복사, 삭제
 * 설정(passql.storage.*)이 없으면 비활성, 호출하면 ObjectStorageException
 */
@Slf4j
@Component
public class ObjectStorageClient {

    private static final String OPERATION_PUT = "put";
    private static final String OPERATION_READ = "read";
    private static final String OPERATION_COPY = "copy";

    private final ObjectProvider<S3Client> s3ClientProvider;
    // passql.storage.bucket: 전용 버킷 이름 (없으면 빈 값 = 기능 비활성)
    private final String bucketName;

    public ObjectStorageClient(ObjectProvider<S3Client> s3ClientProvider,
                               @Value("${passql.storage.bucket:}") String bucketName) {
        this.s3ClientProvider = s3ClientProvider;
        this.bucketName = bucketName;
    }

    public boolean isEnabled() {
        return !bucketName.isBlank() && s3ClientProvider.getIfAvailable() != null;
    }

    public void put(String objectKey, byte[] bytes, String contentType) {
        try {
            requireClient(OPERATION_PUT, objectKey).putObject(PutObjectRequest.builder()
                    .bucket(bucketName).key(objectKey).contentType(contentType).build(), RequestBody.fromBytes(bytes));
        } catch (SdkException e) {
            throw new ObjectStorageException(OPERATION_PUT, objectKey, e);
        }
    }

    public byte[] read(String objectKey) {
        try {
            return requireClient(OPERATION_READ, objectKey)
                    .getObjectAsBytes(GetObjectRequest.builder().bucket(bucketName).key(objectKey).build()).asByteArray();
        } catch (SdkException e) {
            throw new ObjectStorageException(OPERATION_READ, objectKey, e);
        }
    }

    public void copy(String sourceKey, String destinationKey) {
        try {
            requireClient(OPERATION_COPY, sourceKey).copyObject(CopyObjectRequest.builder()
                    .sourceBucket(bucketName).sourceKey(sourceKey).destinationBucket(bucketName).destinationKey(destinationKey).build());
        } catch (SdkException e) {
            throw new ObjectStorageException(OPERATION_COPY, sourceKey, e);
        }
    }

    /** 삭제 실패는 예외 없이 로그만 (남은 객체는 다시 시도하지 않음, 용량 영향 작음) */
    public void deleteQuietly(String objectKey) {
        try {
            S3Client client = s3ClientProvider.getIfAvailable();
            if (client != null && !bucketName.isBlank()) {
                client.deleteObject(DeleteObjectRequest.builder().bucket(bucketName).key(objectKey).build());
            }
        } catch (SdkException e) {
            log.warn("[object storage] delete failed : key={}, cause={}", objectKey, e.getClass().getSimpleName());
        }
    }

    // 비활성이면 ObjectStorageException (원인 없음)
    private S3Client requireClient(String operationName, String objectKey) {
        if (!isEnabled()) {
            throw new ObjectStorageException(operationName, objectKey, null);
        }
        return s3ClientProvider.getObject();
    }
}
