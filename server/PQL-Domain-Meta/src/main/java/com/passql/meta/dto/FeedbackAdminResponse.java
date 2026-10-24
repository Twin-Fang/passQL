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
    // 회원 닉네임 (member 행이 없으면 null, 서비스가 채움)
    private String memberNickname;
    private String content;
    private String status;
    private LocalDateTime createdAt;
    private String adminMemo;
    // 메모·상태를 마지막으로 바꾼 관리자 (BaseEntity.updatedBy)
    private String updatedBy;
    // 회원에게 보낸 답변과 시각 (없으면 null)
    private String replyMessage;
    private LocalDateTime repliedAt;

    public static FeedbackAdminResponse from(Feedback f, String memberNickname) {
        return new FeedbackAdminResponse(
            f.getFeedbackUuid(),
            f.getMemberUuid(),
            memberNickname,
            f.getContent(),
            f.getStatus().name(),
            f.getCreatedAt(),
            f.getAdminMemo(),
            f.getUpdatedBy(),
            f.getReplyMessage(),
            f.getRepliedAt()
        );
    }
}
