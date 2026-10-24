package com.passql.application.notification;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.NotificationDeliveryMode;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.AdminNotificationSummaryResponse;
import com.passql.member.dto.PushSendAcceptedResponse;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.entity.MemberNotification;
import com.passql.member.entity.PushSendHistory;
import com.passql.member.repository.MemberNotificationRepository;
import com.passql.member.repository.NotificationReadStatProjection;
import com.passql.member.service.PushNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.List;

/**
 * 알림 생성의 유일한 입구: 회원 1명·전체 알림 저장, 관리자 발송·회수, 보관 기간 정리
 * 저장은 요청 안(단일) 또는 커밋 뒤 비동기(전체) > 푸시 전달은 NotificationDispatcher
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberNotificationService {

    // 보관 기간 정리 한 번에 지우는 행 수
    static final int PURGE_BATCH_SIZE = 5_000;
    // 관리자 회원 상세에 보여 주는 최근 알림 수
    private static final int ADMIN_MEMBER_NOTIFICATION_LIMIT = 50;

    private final MemberNotificationRepository memberNotificationRepository;
    private final PushNotificationService pushNotificationService;
    private final NotificationSettingService notificationSettingService;
    private final UnreadNotificationCountCache unreadNotificationCountCache;
    private final ApplicationEventPublisher eventPublisher;
    private final TransactionTemplate transactionTemplate;

    /** 회원 1명 알림: 저장 > 캐시 삭제 > 커밋 뒤 푸시 전달 요청 */
    @Transactional
    public MemberNotification notifyMember(UUID memberUuid, MemberNotificationType notificationType, String title,
                                           String body, PushLinkTarget linkTarget, UUID linkQuestionUuid) {
        MemberNotification notification = memberNotificationRepository.save(MemberNotification.create(
                memberUuid, notificationType, title, body, linkTarget, linkQuestionUuid, null));
        unreadNotificationCountCache.evict(memberUuid);
        eventPublisher.publishEvent(new NotificationDispatchEvent(null, memberUuid, notificationType, title, body,
                linkTarget, linkQuestionUuid, false, true));
        return notification;
    }

    /** 전체 회원 알림: 커밋 뒤 비동기로 저장(팬아웃) > 푸시 전달 (deliveryMode INBOX_ONLY 면 푸시 생략) */
    @Transactional
    public void notifyAllMembers(MemberNotificationType notificationType, String title, String body,
                                 PushLinkTarget linkTarget, UUID linkQuestionUuid, NotificationDeliveryMode deliveryMode) {
        eventPublisher.publishEvent(new NotificationDispatchEvent(null, null, notificationType, title, body,
                linkTarget, linkQuestionUuid, true, deliveryMode.isPushIncluded()));
    }

    /** 관리자 발송: 접수(검증 > 이력) > 특정 회원은 즉시 저장 > 감사 로그 > 커밋 뒤 저장·전달 요청 */
    @Transactional
    public PushSendAcceptedResponse sendAdminMessage(PushSendRequest request, String sentByAdmin) {
        PushSendHistory history = pushNotificationService.acceptSend(request, sentByAdmin);
        boolean isAllAudience = history.getAudience() == PushAudience.ALL;
        long targetMemberCount = 1;
        if (isAllAudience) {
            targetMemberCount = pushNotificationService.countAllInboxRecipients();
        } else {
            saveMemberNotification(history);
        }
        eventPublisher.publishEvent(new NotificationDispatchEvent(history.getPushSendHistoryUuid(),
                history.getTargetMemberUuid(), MemberNotificationType.ADMIN_MESSAGE, history.getTitle(), history.getBody(),
                history.getLinkTarget(), history.getLinkQuestionUuid(), isAllAudience,
                history.getDeliveryMode().isPushIncluded()));
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTIFICATION, history.getPushSendHistoryUuid(),
                AdminAuditAction.SEND, null, AdminAuditEvent.summary("title", history.getTitle(),
                        "audience", history.getAudience(), "deliveryMode", history.getDeliveryMode(),
                        "linkTarget", history.getLinkTarget(), "targetMemberCount", targetMemberCount)));
        log.info("[notification send] accepted : history={}, audience={}, mode={}, by={}",
                history.getPushSendHistoryUuid(), history.getAudience(), history.getDeliveryMode(), sentByAdmin);
        return new PushSendAcceptedResponse(history.getPushSendHistoryUuid(), targetMemberCount);
    }

    /** 전체 팬아웃(커밋 뒤 비동기 호출): 회원 전체에 INSERT ... SELECT 1회 > 받은 수 기록 > 캐시 전체 삭제 > 만든 행 수 */
    @Transactional
    public int fanOutToAllMembers(NotificationDispatchEvent event) {
        int createdCount = memberNotificationRepository.insertForAllActiveMembers(event.notificationType(),
                event.title(), event.body(), event.linkTarget(), event.linkQuestionUuid(),
                event.pushSendHistoryUuid(), LocalDateTime.now());
        if (event.pushSendHistoryUuid() != null) {
            pushNotificationService.recordRecipientCount(event.pushSendHistoryUuid(), createdCount);
        }
        unreadNotificationCountCache.evictAll();
        log.info("[notification fanout] inserted : history={}, count={}", event.pushSendHistoryUuid(), createdCount);
        return createdCount;
    }

    /** 관리자 회수: 이력 회수 표시 > 그 발송의 알림 숨김 > 캐시 전체 삭제 > 감사 로그 (푸시는 이미 나간 것이라 되돌리지 않음) */
    @Transactional
    public int retractAdminMessage(UUID pushSendHistoryUuid, String retractedByAdmin) {
        PushSendHistory history = pushNotificationService.markRetracted(pushSendHistoryUuid, retractedByAdmin);
        int hiddenCount = memberNotificationRepository.hideByPushSendHistory(pushSendHistoryUuid);
        unreadNotificationCountCache.evictAll();
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTIFICATION, pushSendHistoryUuid,
                AdminAuditAction.RETRACT, null, AdminAuditEvent.summary("title", history.getTitle(), "hiddenCount", hiddenCount)));
        log.info("[notification retract] hidden : history={}, count={}, by={}", pushSendHistoryUuid, hiddenCount, retractedByAdmin);
        return hiddenCount;
    }

    /** 관리자 발송 이력 한 페이지 + 발송별 읽은 수 (GROUP BY 1회) */
    public Page<PushHistoryRow> getHistoryRows(Pageable pageable) {
        Page<PushSendHistory> histories = pushNotificationService.getSendHistories(pageable);
        List<UUID> historyUuids = histories.stream().map(PushSendHistory::getPushSendHistoryUuid).toList();
        Map<UUID, Long> readCountByHistory = historyUuids.isEmpty() ? Map.of()
                : memberNotificationRepository.summarizeReadByPushSendHistory(historyUuids).stream()
                        .collect(Collectors.toMap(NotificationReadStatProjection::getPushSendHistoryUuid,
                                NotificationReadStatProjection::getReadCount));
        return histories.map(history -> PushHistoryRow.of(history,
                readCountByHistory.getOrDefault(history.getPushSendHistoryUuid(), 0L)));
    }

    /** 관리자 회원 상세: 그 회원의 최근 알림 (읽음·회수 여부 포함) */
    public List<AdminNotificationSummaryResponse> findRecentNotificationsOfMember(UUID memberUuid) {
        return memberNotificationRepository
                .findByMemberUuidOrderByCreatedAtDesc(memberUuid, PageRequest.of(0, ADMIN_MEMBER_NOTIFICATION_LIMIT))
                .stream().map(AdminNotificationSummaryResponse::from).toList();
    }

    /** 관리자 회원 상세: 그 회원의 알림 한 페이지 (읽음·회수 여부 포함) */
    public Page<AdminNotificationSummaryResponse> findNotificationPageOfMember(UUID memberUuid, Pageable pageable) {
        return memberNotificationRepository.findPageByMemberUuidOrderByCreatedAtDesc(memberUuid, pageable)
                .map(AdminNotificationSummaryResponse::from);
    }

    /** 보관 기간 지난 알림 삭제 (PURGE_BATCH_SIZE 건씩 별도 트랜잭션 반복) > 지운 행 수 */
    public int purgeExpiredNotifications() {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(notificationSettingService.getRetentionDays());
        int totalDeleted = 0;
        int batchDeleted;
        do {
            batchDeleted = transactionTemplate.execute(status ->
                    memberNotificationRepository.deleteExpiredBatch(cutoff, PURGE_BATCH_SIZE));
            totalDeleted += batchDeleted;
        } while (batchDeleted >= PURGE_BATCH_SIZE);
        return totalDeleted;
    }

    /** 특정 회원 발송: 이력 내용 그대로 알림 1건 저장 > 받은 수 1 > 캐시 삭제 */
    private void saveMemberNotification(PushSendHistory history) {
        memberNotificationRepository.save(MemberNotification.create(history.getTargetMemberUuid(),
                MemberNotificationType.ADMIN_MESSAGE, history.getTitle(), history.getBody(), history.getLinkTarget(),
                history.getLinkQuestionUuid(), history.getPushSendHistoryUuid()));
        history.recordRecipientCount(1);
        unreadNotificationCountCache.evict(history.getTargetMemberUuid());
    }
}
