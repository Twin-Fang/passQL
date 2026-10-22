package com.passql.application.entitlement;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.member.repository.MemberRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 프로 수동 부여·회수, 회원 상세용 등급·구매 이력 조회
 * 부여: 검증(회원, 날짜) > 등급 행 연장 또는 생성(ADMIN_GRANT) > 감사 기록
 */
@Slf4j
@Service
public class EntitlementAdminService {

    // 서비스 기준 시간대 (만료일·오늘 판정은 KST 로컬)
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");
    // 부여 만료 시각: 선택한 날짜의 마지막 순간 (23:59:59)
    private static final LocalTime GRANT_EXPIRES_TIME = LocalTime.of(23, 59, 59);

    private final MemberRepository memberRepository;
    private final MemberEntitlementRepository memberEntitlementRepository;
    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final Clock clock;

    @Autowired
    public EntitlementAdminService(MemberRepository memberRepository,
                                   MemberEntitlementRepository memberEntitlementRepository,
                                   EntitlementPurchaseRepository entitlementPurchaseRepository,
                                   ApplicationEventPublisher eventPublisher) {
        this(memberRepository, memberEntitlementRepository, entitlementPurchaseRepository,
            eventPublisher, Clock.system(SERVICE_ZONE));
    }

    EntitlementAdminService(MemberRepository memberRepository,
                            MemberEntitlementRepository memberEntitlementRepository,
                            EntitlementPurchaseRepository entitlementPurchaseRepository,
                            ApplicationEventPublisher eventPublisher, Clock clock) {
        this.memberRepository = memberRepository;
        this.memberEntitlementRepository = memberEntitlementRepository;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
        this.eventPublisher = eventPublisher;
        this.clock = clock;
    }

    /** 프로 부여: 회원·날짜 검증 > 행 잠금 조회 > 연장 또는 생성(ADMIN_GRANT) > 감사 기록 */
    @Transactional
    public void grantPro(UUID memberUuid, LocalDate expiresDate) {
        // 요청 검증 (회원 존재, 오늘 이후 날짜)
        if (!memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }
        if (expiresDate == null || expiresDate.isBefore(LocalDate.now(clock))) {
            log.info("[billing] admin grant rejected 400 : expires date is before today, member={}", memberUuid);
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "expiresDate must be today or later");
        }
        LocalDateTime newExpiresAt = expiresDate.atTime(GRANT_EXPIRES_TIME);

        // 등급 행 연장 또는 생성
        MemberEntitlement existing = memberEntitlementRepository.findForUpdateByMemberUuid(memberUuid).orElse(null);
        LocalDateTime previousExpiresAt = existing != null ? existing.getExpiresAt() : null;
        if (existing != null) {
            existing.extendTo(newExpiresAt, EntitlementSource.ADMIN_GRANT);
        } else {
            memberEntitlementRepository.save(
                MemberEntitlement.of(memberUuid, MemberPlan.PRO, newExpiresAt, EntitlementSource.ADMIN_GRANT));
        }

        log.info("[billing] admin grant : member={}, expires {} -> {}", memberUuid, previousExpiresAt, newExpiresAt);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.MEMBER, memberUuid, AdminAuditAction.UPDATE,
            AdminAuditEvent.summary("proExpiresAt", previousExpiresAt),
            AdminAuditEvent.summary("proExpiresAt", newExpiresAt, "source", EntitlementSource.ADMIN_GRANT)));
    }

    /** 프로 회수: 등급 행이 있을 때만 FREE 로 (없으면 아무것도 하지 않음) */
    @Transactional
    public void revokePro(UUID memberUuid) {
        MemberEntitlement existing = memberEntitlementRepository.findForUpdateByMemberUuid(memberUuid).orElse(null);
        if (existing == null) {
            log.info("[billing] admin revoke skipped : no entitlement row, member={}", memberUuid);
            return;
        }
        LocalDateTime previousExpiresAt = existing.getExpiresAt();
        existing.revoke();

        log.info("[billing] admin revoke : member={}, expires {} -> null", memberUuid, previousExpiresAt);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.MEMBER, memberUuid, AdminAuditAction.RETRACT,
            AdminAuditEvent.summary("proExpiresAt", previousExpiresAt),
            AdminAuditEvent.summary("proExpiresAt", null)));
    }

    /** 회원 상세용: 현재 등급 행 > 유효 프로 여부, 구매 이력 최신순 */
    @Transactional(readOnly = true)
    public MemberEntitlementAdminView getEntitlementView(UUID memberUuid) {
        MemberEntitlement entitlement = memberEntitlementRepository.findById(memberUuid).orElse(null);
        boolean isActivePro = entitlement != null
            && entitlement.getPlan() == MemberPlan.PRO
            && entitlement.getExpiresAt() != null
            && entitlement.getExpiresAt().isAfter(LocalDateTime.now(clock));

        List<MemberEntitlementAdminView.PurchaseRow> purchaseRows = entitlementPurchaseRepository
            .findByMemberUuid(memberUuid, Sort.by(Sort.Direction.DESC, "purchasedAt"))
            .stream()
            .map(this::toPurchaseRow)
            .toList();

        return new MemberEntitlementAdminView(
            isActivePro,
            entitlement != null ? entitlement.getExpiresAt() : null,
            entitlement != null ? entitlement.getSource() : null,
            purchaseRows);
    }

    /** 구매 > 화면 행 (구매 토큰 제외) */
    private MemberEntitlementAdminView.PurchaseRow toPurchaseRow(EntitlementPurchase purchase) {
        return new MemberEntitlementAdminView.PurchaseRow(
            purchase.getStore(),
            purchase.getProductId(),
            purchase.getOrderId(),
            purchase.getPurchasedAt(),
            purchase.getStatus(),
            purchase.getGrantedExpiresAt(),
            Boolean.TRUE.equals(purchase.getIsConsumed()));
    }
}
