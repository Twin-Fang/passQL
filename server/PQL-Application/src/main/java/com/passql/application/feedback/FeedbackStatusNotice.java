package com.passql.application.feedback;

import com.passql.meta.constant.FeedbackStatus;

import java.util.Optional;

/**
 * 의견 상태 변경 알림 문구: 상태 > 작성자에게 보낼 문구
 * 대기(PENDING)로 되돌린 경우는 알림 없음
 */
public final class FeedbackStatusNotice {

    private FeedbackStatusNotice() {
    }

    public static Optional<String> messageFor(FeedbackStatus status) {
        return switch (status) {
            case REVIEWED -> Optional.of("보내 주신 의견을 확인했어요");
            case APPLIED -> Optional.of("보내 주신 의견이 앱에 반영됐어요");
            case PENDING -> Optional.empty();
        };
    }
}
