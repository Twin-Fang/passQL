package com.passql.application.notification;

import com.passql.member.dto.PushDevice;
import com.passql.member.dto.PushSendResult;
import com.passql.member.push.PushMessage;
import com.passql.member.service.PushAudienceResolver;
import com.passql.member.service.PushNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 알림 커밋 뒤 처리: 팬아웃(전체·세그먼트) > 대상 기기 조회 > 회원별 배지 계산 > 푸시 전달 > 이력 결과 기록
 * 요청 스레드가 아닌 전용 실행기에서 실행, 실패는 로그만 (요청 결과에 영향 없음)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationDispatcher {

    // AsyncConfig 에 등록하는 실행기 이름
    public static final String EXECUTOR_NAME = "notificationTaskExecutor";

    private final MemberNotificationService memberNotificationService;
    private final MemberNotificationQueryService memberNotificationQueryService;
    private final PushNotificationService pushNotificationService;
    private final PushAudienceResolver pushAudienceResolver;

    // 트랜잭션 없이 발행된 이벤트도 처리 (fallbackExecution)
    @Async(EXECUTOR_NAME)
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onDispatchRequested(NotificationDispatchEvent event) {
        dispatch(event);
    }

    /** 팬아웃(필요 시) > 푸시 전달(필요 시), 예외는 삼키고 로그 */
    public void dispatch(NotificationDispatchEvent event) {
        try {
            if (event.isFanoutRequired()) {
                // 세그먼트는 대상 회원 목록만, 그 외는 전체 회원 SQL 1회
                if (event.isSegment()) {
                    memberNotificationService.fanOutToMembers(event);
                } else {
                    memberNotificationService.fanOutToAllMembers(event);
                }
            }
            if (event.isPushRequired()) {
                deliverPush(event);
            }
        } catch (RuntimeException e) {
            log.error("[notification dispatch] failed : history={}, target={}", event.pushSendHistoryUuid(), event.targetMemberUuid(), e);
        }
    }

    /** 푸시: 대상 기기 > 회원별 안 읽은 개수(배지) > 전달 > 관리자 발송이면 결과 기록 */
    private void deliverPush(NotificationDispatchEvent event) {
        List<PushDevice> devices = event.isSegment()
                ? pushAudienceResolver.findDevices(event.segmentMemberUuids(), event.platformFilter())
                : pushNotificationService.findDevices(event.targetMemberUuid());
        if (devices.isEmpty()) {
            return;
        }
        Set<UUID> deviceMemberUuids = devices.stream().map(PushDevice::memberUuid).collect(Collectors.toSet());
        // 전체 발송만 배지를 전체 회원 GROUP BY 1회로 계산, 그 외는 대상 기기 회원만
        boolean isAllMembersTarget = event.targetMemberUuid() == null && !event.isSegment();
        Map<UUID, Integer> badgeByMember = memberNotificationQueryService.countBadgeByMember(
                isAllMembersTarget ? null : deviceMemberUuids);
        PushMessage message = pushNotificationService.toPushMessage(
                event.title(), event.body(), event.linkTarget(), event.linkQuestionUuid());
        PushSendResult result = pushNotificationService.deliver(message, devices, badgeByMember, event.pushSendHistoryUuid());
        if (event.pushSendHistoryUuid() != null) {
            pushNotificationService.recordDeliveryResult(event.pushSendHistoryUuid(), result);
        }
    }
}
