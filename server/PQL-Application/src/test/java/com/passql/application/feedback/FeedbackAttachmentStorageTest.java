package com.passql.application.feedback;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import com.passql.application.feedback.FeedbackAttachmentStorage.StoredObject;
import com.passql.application.storage.ObjectStorageClient;
import com.passql.application.storage.ObjectStorageException;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import java.util.List;
import org.junit.jupiter.api.Test;

/** 첨부 업로드 판정: 중간 실패 시 앞서 올린 객체 정리 > 503 */
class FeedbackAttachmentStorageTest {

    private final ObjectStorageClient client = mock(ObjectStorageClient.class);
    private final FeedbackAttachmentStorage storage = new FeedbackAttachmentStorage(client);

    @Test
    void 세번째_업로드_실패하면_앞서_올린_두개_삭제후_503() {
        doNothing().when(client).put(eq("k1"), any(), any());
        doNothing().when(client).put(eq("k2"), any(), any());
        doThrow(new ObjectStorageException("put", "k3", null)).when(client).put(eq("k3"), any(), any());

        CustomException thrown = assertThrows(CustomException.class,
                () -> storage.uploadAll(List.of(objectOf("k1"), objectOf("k2"), objectOf("k3"))));

        assertEquals(ErrorCode.FEEDBACK_STORAGE_UNAVAILABLE, thrown.getErrorCode());
        verify(client).deleteQuietly("k1");
        verify(client).deleteQuietly("k2");
        verify(client, never()).deleteQuietly("k3");
    }

    private static StoredObject objectOf(String objectKey) {
        return new StoredObject(objectKey, new byte[] {1}, "image/webp");
    }
}
