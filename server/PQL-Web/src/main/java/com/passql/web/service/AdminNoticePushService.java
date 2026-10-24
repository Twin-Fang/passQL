package com.passql.web.service;

import com.passql.application.notification.MemberNotificationService;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.entity.PushSendHistory;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneId;

/**
 * 공지 등록 시 푸시 발송 옵션: 활성 공지 > 전체 회원 푸시 (노출 시작이 미래면 그 시각으로 예약)
 * 공지 저장과 별도 처리라 푸시 실패가 공지 등록을 되돌리지 않음 (결과는 NoticePushResult 로 화면에 알림)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminNoticePushService {

    /** 공지 푸시 결과: 즉시 발송, 예약, 건너뜀(비활성 공지), 실패 */
    public enum NoticePushResult { SENT, SCHEDULED, SKIPPED, FAILED }

    // 공지 노출 시각은 KST 입력, 예약 비교도 KST (서버 시간대와 무관)
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    // 푸시 본문 말줄임 기준 (PushSendHistory.MAX_BODY_LENGTH 이내로 자르고 말줄임 1자)
    private static final String ELLIPSIS = "…";

    private final MemberNotificationService memberNotificationService;

    /** 공지 > 전체 푸시 (예약 시각이 지금 + 2분 이내면 즉시 발송) */
    public NoticePushResult sendNoticePush(AppNoticeResponse notice, String adminUsername) {
        if (!Boolean.TRUE.equals(notice.isActive())) {
            return NoticePushResult.SKIPPED;
        }
        LocalDateTime scheduledAt = resolveScheduledAt(notice.startsAt());
        try {
            memberNotificationService.sendAdminMessage(new PushSendRequest(notice.title(), toPushBody(notice.body()),
                    PushAudience.ALL.name(), null, PushLinkTarget.HOME.name(), null, null, null, scheduledAt), adminUsername);
            return scheduledAt == null ? NoticePushResult.SENT : NoticePushResult.SCHEDULED;
        } catch (RuntimeException e) {
            log.warn("[notice push] failed : notice={}, reason={}", notice.noticeUuid(), e.getClass().getSimpleName());
            return NoticePushResult.FAILED;
        }
    }

    /** 노출 시작이 먼 미래일 때만 예약 (곧 시작이거나 이미 시작이면 null = 즉시) */
    private static LocalDateTime resolveScheduledAt(LocalDateTime startsAt) {
        if (startsAt == null || !startsAt.isAfter(LocalDateTime.now(KST).plusMinutes(2))) {
            return null;
        }
        return startsAt;
    }

    /** 공지 본문(최대 2000자) > 푸시 본문(최대 500자, 넘으면 말줄임) */
    private static String toPushBody(String noticeBody) {
        String body = noticeBody.trim();
        if (body.length() <= PushSendHistory.MAX_BODY_LENGTH) {
            return body;
        }
        return body.substring(0, PushSendHistory.MAX_BODY_LENGTH - ELLIPSIS.length()) + ELLIPSIS;
    }
}
