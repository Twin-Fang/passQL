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
    // 진단 요약 (없으면 null): 플랫폼, 앱 버전
    private String platform;
    private String appVersion;
    // 첨부 이미지 수, 앱 로그 유무
    private int imageCount;
    private boolean hasLog;

    public static FeedbackAdminResponse from(Feedback f, String memberNickname, int imageCount) {
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
            f.getRepliedAt(),
            f.getPlatform(),
            f.getAppVersion(),
            imageCount,
            f.hasLog()
        );
    }
}
