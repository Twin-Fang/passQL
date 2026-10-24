package com.passql.application.entitlement;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.meta.entity.AdminAuditLog;
import com.passql.meta.repository.AdminAuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 회원 이용권 변동 타임라인: 구매 이력 + 구매 회수 + 관리자 부여·회수 감사 로그를 최신순으로 합침
 * 관리자 변경 사유는 감사 로그 요약의 reason 키
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class EntitlementTimelineService {

    // 타임라인 최대 표시 건수
    static final int MAX_TIMELINE_EVENT_COUNT = 50;
    // 감사 로그 요약에서 이용권 변경을 알아보는 키 (EntitlementAdminService 가 기록)
    private static final String EXPIRES_AT_SUMMARY_KEY = "proExpiresAt";
    private static final String ORDER_SUMMARY_KEY = "order";
    private static final String EMPTY_VALUE_TEXT = "-";

    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final AdminAuditLogRepository adminAuditLogRepository;
    private final ObjectMapper objectMapper;

    /** 구매·회수 이벤트 + 관리자 변경 이벤트 > 최신순 최대 50건 */
    public List<TimelineEvent> getTimeline(UUID memberUuid) {
        List<TimelineEvent> events = new ArrayList<>();

        // 구매 이력 (구매, 회수된 구매)
        for (EntitlementPurchase purchase : entitlementPurchaseRepository
                .findByMemberUuid(memberUuid, Sort.by(Sort.Direction.DESC, "purchasedAt"))) {
            events.add(toPurchaseEvent(purchase));
            if (purchase.getStatus() == PurchaseStatus.REVOKED) {
                events.add(toPurchaseRevokedEvent(purchase));
            }
        }

        // 관리자 부여·회수 (이용권 키가 있는 감사 로그만)
        for (AdminAuditLog auditLog : adminAuditLogRepository
                .findTop50ByTargetTypeAndTargetIdOrderByOccurredAtDesc(AdminAuditTargetType.MEMBER, memberUuid.toString())) {
            toAdminChangeEvent(auditLog).ifPresent(events::add);
        }

        return events.stream()
                .sorted(Comparator.comparing(TimelineEvent::occurredAt).reversed())
                .limit(MAX_TIMELINE_EVENT_COUNT)
                .toList();
    }

    private TimelineEvent toPurchaseEvent(EntitlementPurchase purchase) {
        String priceText = EntitlementAdminService.toPriceText(purchase.getPriceAmountMicros(), purchase.getCurrencyCode());
        String detail = purchase.getProductId() + " · " + (priceText != null ? priceText : "금액 미기록")
                + " · 만료 " + formatDateTime(purchase.getGrantedExpiresAt());
        return new TimelineEvent(purchase.getPurchasedAt(), "구매", detail, purchase.getStore().name());
    }

    // 회수 시각은 구매 행 수정 시각 (없으면 구매 시각)
    private TimelineEvent toPurchaseRevokedEvent(EntitlementPurchase purchase) {
        LocalDateTime occurredAt = purchase.getUpdatedAt() != null ? purchase.getUpdatedAt() : purchase.getPurchasedAt();
        return new TimelineEvent(occurredAt, "구매 회수", "주문 " + purchase.getOrderId(), "환불·관리자");
    }

    /** 감사 로그 > 이벤트 (이용권 변경이 아니거나 해석할 수 없으면 empty) */
    private Optional<TimelineEvent> toAdminChangeEvent(AdminAuditLog auditLog) {
        String changeSummaryJson = auditLog.getChangeSummaryJson();
        if (changeSummaryJson == null || !changeSummaryJson.contains(EXPIRES_AT_SUMMARY_KEY)) {
            return Optional.empty();
        }
        try {
            JsonNode root = objectMapper.readTree(changeSummaryJson);
            JsonNode before = root.path("before");
            JsonNode after = root.path("after");
            boolean isPurchaseRevoke = after.has(ORDER_SUMMARY_KEY);
            String eventLabel = auditLog.getAction() == AdminAuditAction.RETRACT
                    ? (isPurchaseRevoke ? "관리자 구매 회수" : "관리자 프로 회수")
                    : "관리자 프로 부여";
            String reason = after.path(EntitlementAdminService.REASON_SUMMARY_KEY).asText("");
            String detail = "만료일 " + before.path(EXPIRES_AT_SUMMARY_KEY).asText(EMPTY_VALUE_TEXT).replace('T', ' ')
                    + " > " + after.path(EXPIRES_AT_SUMMARY_KEY).asText(EMPTY_VALUE_TEXT).replace('T', ' ')
                    + (reason.isBlank() ? " · 사유 미기록" : " · 사유: " + reason);
            return Optional.of(new TimelineEvent(auditLog.getOccurredAt(), eventLabel, detail, auditLog.getAdminUsername()));
        } catch (Exception exception) {
            // 요약이 잘려 JSON 이 깨진 옛 행은 건너뜀
            log.debug("[billing] timeline audit log skipped : {}", exception.getClass().getSimpleName());
            return Optional.empty();
        }
    }

    private static String formatDateTime(LocalDateTime dateTime) {
        return dateTime == null ? EMPTY_VALUE_TEXT : dateTime.toString().replace('T', ' ').substring(0, 16);
    }

    /** 타임라인 1건 (actorLabel: 관리자 아이디 또는 스토어) */
    public record TimelineEvent(LocalDateTime occurredAt, String eventLabel, String detail, String actorLabel) {}
}
