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
import com.passql.member.dto.PushHistorySearchCondition;
import com.passql.member.service.PushAudienceResolver;
import com.passql.member.service.PushNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.List;

/**
 * 알림 생성의 유일한 입구: 회원 1명·전체·세그먼트 알림 저장, 관리자 발송(예약·테스트 포함)·회수·예약 취소, 보관 기간 정리
 * 저장은 요청 안(단일) 또는 커밋 뒤 비동기(전체·세그먼트) > 푸시 전달은 NotificationDispatcher
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberNotificationService {

    // 보관 기간 정리 한 번에 지우는 행 수
    static final int PURGE_BATCH_SIZE = 5_000;
    // 세그먼트 알림함 저장 한 번에 넣는 행 수
    private static final int SEGMENT_FANOUT_CHUNK_SIZE = 1_000;
    // 열람률 통계 기본 기간 (일)
    public static final int DEFAULT_STATS_DAYS = 30;
    // 관리자 회원 상세에 보여 주는 최근 알림 수
    private static final int ADMIN_MEMBER_NOTIFICATION_LIMIT = 50;

    private final MemberNotificationRepository memberNotificationRepository;
    private final PushNotificationService pushNotificationService;
    private final PushAudienceResolver pushAudienceResolver;
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

    /** 관리자 발송 (테스트 아님) */
    @Transactional
    public PushSendAcceptedResponse sendAdminMessage(PushSendRequest request, String sentByAdmin) {
        return sendAdminMessage(request, sentByAdmin, false);
    }

    /**
     * 관리자 발송: 접수(검증 > 이력) > 예약이면 대기, 즉시면 대상별 저장·전달 요청 > 감사 로그
     * 응답 수: 즉시 = 알림함 대상 회원 수, 예약 = 지금 기준 예상 회원 수 (발송 시각에 다시 계산)
     */
    @Transactional
    public PushSendAcceptedResponse sendAdminMessage(PushSendRequest request, String sentByAdmin, boolean isTest) {
        PushSendHistory history = pushNotificationService.acceptSend(request, sentByAdmin, isTest);
        long targetMemberCount = history.isScheduled()
                ? countTargetMembers(history.getAudience(), history.getInactiveDays()) : dispatchNow(history);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTIFICATION, history.getPushSendHistoryUuid(),
                AdminAuditAction.SEND, null, AdminAuditEvent.summary("title", history.getTitle(),
                        "audience", history.getAudience(), "deliveryMode", history.getDeliveryMode(),
                        "linkTarget", history.getLinkTarget(), "targetMemberCount", targetMemberCount,
                        "scheduledAt", history.getScheduledAt(), "isTest", history.getIsTest())));
        log.info("[notification send] accepted : history={}, audience={}, mode={}, scheduledAt={}, test={}, by={}",
                history.getPushSendHistoryUuid(), history.getAudience(), history.getDeliveryMode(),
                history.getScheduledAt(), history.getIsTest(), sentByAdmin);
        return new PushSendAcceptedResponse(history.getPushSendHistoryUuid(), targetMemberCount);
    }

    /** 발송 시각이 된 예약 건 처리 (스케줄러가 매분 호출): 건별 선점 > 발송, 한 건 실패가 다른 건을 막지 않음 */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public int dispatchDueScheduledSends() {
        int dispatchedCount = 0;
        for (PushSendHistory dueHistory : pushNotificationService.findDueScheduledHistories(LocalDateTime.now())) {
            try {
                Boolean isDispatched = transactionTemplate.execute(status -> dispatchClaimedSchedule(dueHistory.getPushSendHistoryUuid()));
                if (Boolean.TRUE.equals(isDispatched)) {
                    dispatchedCount++;
                }
            } catch (RuntimeException e) {
                log.error("[notification schedule] dispatch failed : history={}", dueHistory.getPushSendHistoryUuid(), e);
            }
        }
        return dispatchedCount;
    }

    /** 예약 취소 + 감사 로그 (이미 발송 시작·취소된 건은 PUSH_NOT_SCHEDULED) */
    @Transactional
    public void cancelScheduledSend(UUID pushSendHistoryUuid) {
        PushSendHistory history = pushNotificationService.cancelScheduledHistory(pushSendHistoryUuid);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTIFICATION, pushSendHistoryUuid,
                AdminAuditAction.CANCEL, null, AdminAuditEvent.summary("title", history.getTitle(), "scheduledAt", history.getScheduledAt())));
        log.info("[notification schedule] canceled : history={}", pushSendHistoryUuid);
    }

    /** 예약 선점에 성공하면 발송 시작 > 감사 로그 (다른 서버가 먼저 선점했으면 false) */
    private boolean dispatchClaimedSchedule(UUID pushSendHistoryUuid) {
        if (!pushNotificationService.claimScheduledHistory(pushSendHistoryUuid)) {
            return false;
        }
        PushSendHistory history = pushNotificationService.findHistory(pushSendHistoryUuid);
        long targetMemberCount = dispatchNow(history);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTIFICATION, pushSendHistoryUuid,
                AdminAuditAction.SEND, null, AdminAuditEvent.summary("title", history.getTitle(), "audience", history.getAudience(),
                        "targetMemberCount", targetMemberCount, "scheduledAt", history.getScheduledAt(), "isScheduledDispatch", true)));
        log.info("[notification schedule] dispatched : history={}, audience={}, targetMembers={}",
                pushSendHistoryUuid, history.getAudience(), targetMemberCount);
        return true;
    }

    /** 대상별 즉시 발송: ALL 전체 팬아웃 / MEMBER 즉시 저장 / 세그먼트 회원 조회 > 팬아웃 > 대상 회원 수 */
    private long dispatchNow(PushSendHistory history) {
        PushAudience audience = history.getAudience();
        boolean isPushIncluded = history.getDeliveryMode().isPushIncluded();
        if (audience.isSegment()) {
            List<UUID> memberUuids = pushAudienceResolver.resolveMemberUuids(audience, history.getInactiveDays());
            eventPublisher.publishEvent(new NotificationDispatchEvent(history.getPushSendHistoryUuid(), null,
                    MemberNotificationType.ADMIN_MESSAGE, history.getTitle(), history.getBody(), history.getLinkTarget(),
                    history.getLinkQuestionUuid(), true, isPushIncluded, memberUuids, pushAudienceResolver.findPlatformFilter(audience)));
            return memberUuids.size();
        }
        boolean isAllAudience = audience == PushAudience.ALL;
        long targetMemberCount = 1;
        if (isAllAudience) {
            targetMemberCount = pushNotificationService.countAllInboxRecipients();
        } else {
            saveMemberNotification(history);
        }
        eventPublisher.publishEvent(new NotificationDispatchEvent(history.getPushSendHistoryUuid(),
                history.getTargetMemberUuid(), MemberNotificationType.ADMIN_MESSAGE, history.getTitle(), history.getBody(),
                history.getLinkTarget(), history.getLinkQuestionUuid(), isAllAudience, isPushIncluded));
        return targetMemberCount;
    }

    /** 지금 기준 대상 회원 수 (ALL 전체 회원, MEMBER 1명, 세그먼트 조회): 발송 전 안내와 예약 접수 응답용 */
    public long countTargetMembers(PushAudience audience, Integer inactiveDays) {
        if (audience.isSegment()) {
            return pushAudienceResolver.resolveMemberUuids(audience, inactiveDays).size();
        }
        return audience == PushAudience.ALL ? pushNotificationService.countAllInboxRecipients() : 1;
    }

    /** 세그먼트 팬아웃(커밋 뒤 비동기 호출): 대상 회원에 1,000명씩 저장 > 받은 수 기록 > 회원별 캐시 삭제 > 만든 행 수 */
    @Transactional
    public int fanOutToMembers(NotificationDispatchEvent event) {
        List<UUID> memberUuids = event.segmentMemberUuids();
        for (int start = 0; start < memberUuids.size(); start += SEGMENT_FANOUT_CHUNK_SIZE) {
            List<MemberNotification> notificationChunk = new ArrayList<>();
            for (UUID memberUuid : memberUuids.subList(start, Math.min(start + SEGMENT_FANOUT_CHUNK_SIZE, memberUuids.size()))) {
                notificationChunk.add(MemberNotification.create(memberUuid, event.notificationType(), event.title(), event.body(),
                        event.linkTarget(), event.linkQuestionUuid(), event.pushSendHistoryUuid()));
            }
            memberNotificationRepository.saveAll(notificationChunk);
        }
        if (event.pushSendHistoryUuid() != null) {
            pushNotificationService.recordRecipientCount(event.pushSendHistoryUuid(), memberUuids.size());
        }
        memberUuids.forEach(unreadNotificationCountCache::evict);
        log.info("[notification fanout] segment inserted : history={}, count={}", event.pushSendHistoryUuid(), memberUuids.size());
        return memberUuids.size();
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

    /** 관리자 발송 이력 한 페이지 (검색 조건 적용) + 발송별 읽은 수 (GROUP BY 1회) */
    public Page<PushHistoryRow> getHistoryRows(PushHistorySearchCondition condition, Pageable pageable) {
        Page<PushSendHistory> histories = pushNotificationService.searchHistories(condition, pageable);
        Map<UUID, Long> readCountByHistory = countReadByHistory(
                histories.stream().map(PushSendHistory::getPushSendHistoryUuid).toList());
        return histories.map(history -> PushHistoryRow.of(history,
                readCountByHistory.getOrDefault(history.getPushSendHistoryUuid(), 0L)));
    }

    /** 최근 N일 열람률 통계: 실제 발송(테스트·회수·예약 제외) 합계 > 알림함 읽음률, 푸시 성공률 */
    public PushStatsSummary getRecentStats(int days) {
        List<PushSendHistory> histories = pushNotificationService.findDispatchedHistoriesSince(LocalDateTime.now().minusDays(days));
        Map<UUID, Long> readCountByHistory = countReadByHistory(
                histories.stream().map(PushSendHistory::getPushSendHistoryUuid).toList());
        return PushStatsSummary.of(days, histories, readCountByHistory);
    }

    /** 발송별 읽은 알림 수 (이력 UUID 목록이 비면 조회하지 않음) */
    private Map<UUID, Long> countReadByHistory(List<UUID> historyUuids) {
        if (historyUuids.isEmpty()) {
            return Map.of();
        }
        return memberNotificationRepository.summarizeReadByPushSendHistory(historyUuids).stream()
                .collect(Collectors.toMap(NotificationReadStatProjection::getPushSendHistoryUuid,
                        NotificationReadStatProjection::getReadCount));
    }

    /** 관리자 회원 상세: 그 회원의 최근 알림 (읽음·회수 여부 포함) */
    public List<AdminNotificationSummaryResponse> findRecentNotificationsOfMember(UUID memberUuid) {
        return memberNotificationRepository
                .findByMemberUuidOrderByCreatedAtDesc(memberUuid, PageRequest.of(0, ADMIN_MEMBER_NOTIFICATION_LIMIT))
                .stream().map(AdminNotificationSummaryResponse::from).toList();
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
