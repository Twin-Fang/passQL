package com.passql.meta.dto;

import com.passql.meta.entity.Feedback;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@AllArgsConstructor
public class FeedbackAdminResponse {

    private UUID feedbackUuid;
    private UUID memberUuid;
    private String content;
    private String status;
    private LocalDateTime createdAt;
    private String adminMemo;
    // 메모·상태를 마지막으로 바꾼 관리자 (BaseEntity.updatedBy)
    private String updatedBy;

    public static FeedbackAdminResponse from(Feedback f) {
        return new FeedbackAdminResponse(
            f.getFeedbackUuid(),
            f.getMemberUuid(),
            f.getContent(),
            f.getStatus().name(),
            f.getCreatedAt(),
            f.getAdminMemo(),
            f.getUpdatedBy()
        );
    }
}
