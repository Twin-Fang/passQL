package com.passql.application.entitlement;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.member.constant.EntitlementSource;
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
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 내 구매 내역 (계정·이용권 화면, #816): 스토어 구매 이력 + 운영 지급(관리자 프로 부여 감사 로그) > 최신순
 * 구매 토큰·주문 번호·관리자 아이디·지급 사유는 응답에 넣지 않음, 관리자 회수는 내역에 넣지 않음
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberPurchaseHistoryService {

    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final AdminAuditLogRepository adminAuditLogRepository;
    private final ObjectMapper objectMapper;

    /** 스토어 구매 전체 + 최근 감사 로그 50건 중 운영 지급 > 최신순 */
    public List<PurchaseHistoryEntryResponse> getPurchaseHistory(UUID memberUuid) {
        List<PurchaseHistoryEntryResponse> entries = new ArrayList<>();

        // 스토어 구매 (검증·회수 모두)
        for (EntitlementPurchase purchase : entitlementPurchaseRepository
                .findByMemberUuid(memberUuid, Sort.by(Sort.Direction.DESC, "purchasedAt"))) {
            entries.add(toStorePurchaseEntry(purchase));
        }

        // 운영 지급 (관리자 프로 부여 감사 로그만)
        for (AdminAuditLog auditLog : adminAuditLogRepository
                .findTop50ByTargetTypeAndTargetIdOrderByOccurredAtDesc(AdminAuditTargetType.MEMBER, memberUuid.toString())) {
            toAdminGrantEntry(auditLog).ifPresent(entries::add);
        }

        return entries.stream()
                .sorted(Comparator.comparing(PurchaseHistoryEntryResponse::purchasedAt).reversed())
                .toList();
    }

    private PurchaseHistoryEntryResponse toStorePurchaseEntry(EntitlementPurchase purchase) {
        return new PurchaseHistoryEntryResponse(
                PurchaseHistoryKind.STORE_PURCHASE,
                purchase.getPurchasedAt(),
                purchase.getProductId(),
                purchase.getStore(),
                purchase.getStatus(),
                purchase.getGrantedExpiresAt(),
                purchase.getGrantedDays(),
                purchase.getPriceAmountMicros(),
                purchase.getCurrencyCode());
    }

    /**
     * 감사 로그 > 운영 지급 1건 (UPDATE + 요약 after.source = ADMIN_GRANT 만, 해석 불가면 empty)
     * 더한 일수: 이어 붙인 기준일(지급 전 만료일이 지급 시각 이후면 그날, 아니면 지급일) > 새 만료일
     */
    private Optional<PurchaseHistoryEntryResponse> toAdminGrantEntry(AdminAuditLog auditLog) {
        String changeSummaryJson = auditLog.getChangeSummaryJson();
        if (auditLog.getAction() != AdminAuditAction.UPDATE || changeSummaryJson == null
                || !changeSummaryJson.contains(EntitlementSource.ADMIN_GRANT.name())) {
            return Optional.empty();
        }
        try {
            JsonNode root = objectMapper.readTree(changeSummaryJson);
            JsonNode after = root.path("after");
            if (!EntitlementSource.ADMIN_GRANT.name().equals(after.path(EntitlementAdminService.SOURCE_SUMMARY_KEY).asText())) {
                return Optional.empty();
            }
            LocalDateTime grantedExpiresAt = parseDateTime(after.path(EntitlementAdminService.EXPIRES_AT_SUMMARY_KEY));
            LocalDateTime previousExpiresAt = parseDateTime(
                    root.path("before").path(EntitlementAdminService.EXPIRES_AT_SUMMARY_KEY));
            return Optional.of(new PurchaseHistoryEntryResponse(
                    PurchaseHistoryKind.ADMIN_GRANT,
                    auditLog.getOccurredAt(),
                    null, null, null,
                    grantedExpiresAt,
                    toGrantedDays(auditLog.getOccurredAt(), previousExpiresAt, grantedExpiresAt),
                    null, null));
        } catch (Exception exception) {
            // 요약이 잘려 JSON 이 깨진 옛 행은 건너뜀
            log.debug("[billing] purchase history audit log skipped : {}", exception.getClass().getSimpleName());
            return Optional.empty();
        }
    }

    /** 이어 붙인 기준일 > 새 만료일 일수 (단축·모름이면 null) */
    static Integer toGrantedDays(LocalDateTime grantedAt, LocalDateTime previousExpiresAt, LocalDateTime grantedExpiresAt) {
        if (grantedAt == null || grantedExpiresAt == null) {
            return null;
        }
        LocalDateTime baseAt = previousExpiresAt != null && previousExpiresAt.isAfter(grantedAt) ? previousExpiresAt : grantedAt;
        long days = ChronoUnit.DAYS.between(baseAt.toLocalDate(), grantedExpiresAt.toLocalDate());
        return days > 0 ? (int) days : null;
    }

    /** 요약 날짜 값 > LocalDateTime (null·빈 값 > null) */
    private static LocalDateTime parseDateTime(JsonNode node) {
        if (node.isMissingNode() || node.isNull() || node.asText().isBlank()) {
            return null;
        }
        return LocalDateTime.parse(node.asText());
    }
}
