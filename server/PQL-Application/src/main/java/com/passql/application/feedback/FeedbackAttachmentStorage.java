package com.passql.application.feedback;

import com.passql.application.storage.ObjectStorageClient;
import com.passql.application.storage.ObjectStorageException;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * 의견 첨부 업로드: 순서대로 put, 실패 시 앞서 올린 객체 삭제 > 503
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class FeedbackAttachmentStorage {

    /** 업로드할 객체 1건 (키, 바이트, Content-Type) */
    public record StoredObject(String objectKey, byte[] bytes, String contentType) {
    }

    private final ObjectStorageClient objectStorageClient;

    /** 전체 업로드: 하나라도 실패하면 그때까지 올린 객체를 지우고 FEEDBACK_STORAGE_UNAVAILABLE */
    public void uploadAll(List<StoredObject> objects) {
        List<String> uploadedKeys = new ArrayList<>();
        for (StoredObject object : objects) {
            try {
                objectStorageClient.put(object.objectKey(), object.bytes(), object.contentType());
                uploadedKeys.add(object.objectKey());
            } catch (ObjectStorageException e) {
                log.warn("[feedback submit] upload failed : key={}, uploadedCount={}", object.objectKey(), uploadedKeys.size());
                uploadedKeys.forEach(objectStorageClient::deleteQuietly);
                throw new CustomException(ErrorCode.FEEDBACK_STORAGE_UNAVAILABLE, e);
            }
        }
    }
}
