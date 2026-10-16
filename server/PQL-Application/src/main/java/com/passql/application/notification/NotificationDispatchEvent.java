package com.passql.application.notification;

import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;

import java.util.UUID;

/**
 * 커밋 뒤 처리 요청: 전체 팬아웃(알림함 저장) > 푸시 전달 (NotificationDispatcher 가 비동기 실행)
 * targetMemberUuid null = 전체 회원, pushSendHistoryUuid null = 관리자 발송이 아닌 자동 알림
 * isFanoutRequired: 전체 회원 알림함 저장이 아직 안 됨 (단일 회원은 요청 안에서 이미 저장)
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
        boolean isPushRequired
) {
}
