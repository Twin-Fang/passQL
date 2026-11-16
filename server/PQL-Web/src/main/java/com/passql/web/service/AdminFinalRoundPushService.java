package com.passql.web.service;

import com.passql.application.notification.MemberNotificationService;
import com.passql.common.util.ServiceTimeZone;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushSendRequest;
import com.passql.submission.constant.MockExamRoundType;
import com.passql.submission.dto.mockexam.AdminMockExamPublishResult;
import com.passql.submission.service.MockExamFinalRoundSchedule;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * FINAL 회차 공개 알림 (#1084): 새로 공개된 FINAL > 여는 날 09:00 전체 회원 예약 푸시 (이미 열렸으면 즉시)
 * 시험일 지난 회차·예약 가능 기간(90일) 밖은 건너뜀, 회차 공개와 별도 처리라 푸시 실패가 공개를 되돌리지 않음
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminFinalRoundPushService {

    /** 공개 알림 결과: 즉시 발송, 예약, 건너뜀, 실패 */
    public enum FinalRoundPushResult { SENT, SCHEDULED, SKIPPED, FAILED }

    // 예약 가능한 최대 기간 (PushNotificationService 예약 상한과 같음)
    private static final int MAX_SCHEDULE_LEAD_DAYS = 90;
    // 예약 시각이 지금 + 2분 이내면 즉시 발송 (예약 최소 간격 회피)
    private static final int IMMEDIATE_SEND_THRESHOLD_MINUTES = 2;
    private static final String PUSH_TITLE = "FINAL 모의고사가 열렸어요";
    private static final String PUSH_BODY = "시험 직전 마지막 점검, 고난도 50문항으로 실력을 확인해 보세요.";

    private final MemberNotificationService memberNotificationService;

    public FinalRoundPushResult notifyIfFinalOpened(AdminMockExamPublishResult publishResult, String adminUsername) {
        // 대상 조건 3개: 새로 공개, FINAL, 시험일 있음
        if (!publishResult.isNewlyPublished() || publishResult.roundType() != MockExamRoundType.FINAL
            || publishResult.examDate() == null) {
            return FinalRoundPushResult.SKIPPED;
        }
        LocalDateTime now = LocalDateTime.now(ServiceTimeZone.ZONE);
        if (publishResult.examDate().isBefore(now.toLocalDate())) {
            return FinalRoundPushResult.SKIPPED;
        }
        LocalDateTime openNotificationAt = MockExamFinalRoundSchedule.toOpenNotificationAt(publishResult.examDate());
        if (openNotificationAt.isAfter(now.plusDays(MAX_SCHEDULE_LEAD_DAYS))) {
            log.info("[final round push] skipped : round={}, reason=too far ({})", publishResult.roundUuid(), openNotificationAt);
            return FinalRoundPushResult.SKIPPED;
        }
        LocalDateTime scheduledAt = openNotificationAt.isAfter(now.plusMinutes(IMMEDIATE_SEND_THRESHOLD_MINUTES))
            ? openNotificationAt : null;
        try {
            memberNotificationService.sendAdminMessage(new PushSendRequest(PUSH_TITLE, PUSH_BODY, PushAudience.ALL.name(),
                null, PushLinkTarget.MOCK_EXAM.name(), null, null, null, scheduledAt), adminUsername);
            return scheduledAt == null ? FinalRoundPushResult.SENT : FinalRoundPushResult.SCHEDULED;
        } catch (RuntimeException e) {
            log.warn("[final round push] failed : round={}, reason={}", publishResult.roundUuid(), e.getClass().getSimpleName());
            return FinalRoundPushResult.FAILED;
        }
    }
}
