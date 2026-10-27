package com.passql.application.storage;

import lombok.Getter;

/**
 * 오브젝트 저장소 실패: 비활성 또는 SDK 오류
 * 업무별 ErrorCode 변환은 호출하는 쪽 책임
 */
@Getter
public class ObjectStorageException extends RuntimeException {

    // 실패한 동작 (put, read, copy)
    private final String operationName;
    private final String objectKey;

    public ObjectStorageException(String operationName, String objectKey, Throwable cause) {
        super("object storage " + operationName + " failed : key=" + objectKey, cause);
        this.operationName = operationName;
        this.objectKey = objectKey;
    }
}
