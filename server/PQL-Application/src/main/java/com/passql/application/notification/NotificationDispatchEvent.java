package com.passql.application.notification;

import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.constant.PushPlatform;

import java.util.List;
import java.util.UUID;

/**
 * 커밋 뒤 처리 요청: 알림함 저장(팬아웃) > 푸시 전달 (NotificationDispatcher 가 비동기 실행)
 * targetMemberUuid null = 전체 회원 또는 세그먼트, pushSendHistoryUuid null = 관리자 발송이 아닌 자동 알림
 * isFanoutRequired: 알림함 저장이 아직 안 됨 (단일 회원은 요청 안에서 이미 저장)
 * segmentMemberUuids: 세그먼트 발송의 대상 회원 (null 이면 세그먼트 아님), platformFilter: 플랫폼 세그먼트의 기기 제한
 */
public record NotificationDispatchEvent(
        UUID pushSendHistoryUuid,
        UUID targetMemberUuid,
        MemberNotificationType notificationType,
        String title,
        String body,
        PushLinkTarget linkTarget,
        UUID linkQuestionUuid,
        boolean isFanoutRequired,
        boolean isPushRequired,
        List<UUID> segmentMemberUuids,
        PushPlatform platformFilter
) {
    /** 세그먼트 없는 요청 (전체·특정 회원) */
    public NotificationDispatchEvent(UUID pushSendHistoryUuid, UUID targetMemberUuid, MemberNotificationType notificationType,
                                     String title, String body, PushLinkTarget linkTarget, UUID linkQuestionUuid,
                                     boolean isFanoutRequired, boolean isPushRequired) {
        this(pushSendHistoryUuid, targetMemberUuid, notificationType, title, body, linkTarget, linkQuestionUuid,
                isFanoutRequired, isPushRequired, null, null);
    }

    public boolean isSegment() {
        return segmentMemberUuids != null;
    }
}
