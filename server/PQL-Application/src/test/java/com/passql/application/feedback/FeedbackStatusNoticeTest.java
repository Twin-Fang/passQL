package com.passql.application.feedback;

import com.passql.meta.constant.FeedbackStatus;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class FeedbackStatusNoticeTest {

    @Test
    void 확인됨_문구() {
        assertEquals(Optional.of("보내 주신 의견을 확인했어요"), FeedbackStatusNotice.messageFor(FeedbackStatus.REVIEWED));
    }

    @Test
    void 반영됨_문구() {
        assertEquals(Optional.of("보내 주신 의견이 앱에 반영됐어요"), FeedbackStatusNotice.messageFor(FeedbackStatus.APPLIED));
    }

    @Test
    void 대기는_알림없음() {
        assertTrue(FeedbackStatusNotice.messageFor(FeedbackStatus.PENDING).isEmpty());
    }
}
