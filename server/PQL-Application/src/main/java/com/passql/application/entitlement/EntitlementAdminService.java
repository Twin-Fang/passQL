package com.passql.application.entitlement;

import com.passql.application.entitlement.EntitlementPurchaseRevoker.RevocationResult;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.EntitlementSource;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.PurchaseStatus;
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
 * 관리자 프로 수동 부여·회수·구매 1건 회수, 회원 상세용 등급·구매 이력 조회
 * 부여: 검증(회원, 오늘 이후 날짜) > 등급 행 만료일 지정(단축 포함) 또는 생성(ADMIN_GRANT) > 감사 기록
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
    private final EntitlementPurchaseRevoker entitlementPurchaseRevoker;
    private final ApplicationEventPublisher eventPublisher;
    private final Clock clock;

    @Autowired
    public EntitlementAdminService(MemberRepository memberRepository,
                                   MemberEntitlementRepository memberEntitlementRepository,
                                   EntitlementPurchaseRepository entitlementPurchaseRepository,
                                   EntitlementPurchaseRevoker entitlementPurchaseRevoker,
                                   ApplicationEventPublisher eventPublisher) {
        this(memberRepository, memberEntitlementRepository, entitlementPurchaseRepository,
            entitlementPurchaseRevoker, eventPublisher, Clock.system(SERVICE_ZONE));
    }

    EntitlementAdminService(MemberRepository memberRepository,
                            MemberEntitlementRepository memberEntitlementRepository,
                            EntitlementPurchaseRepository entitlementPurchaseRepository,
                            EntitlementPurchaseRevoker entitlementPurchaseRevoker,
                            ApplicationEventPublisher eventPublisher, Clock clock) {
        this.memberRepository = memberRepository;
        this.memberEntitlementRepository = memberEntitlementRepository;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
        this.entitlementPurchaseRevoker = entitlementPurchaseRevoker;
        this.eventPublisher = eventPublisher;
        this.clock = clock;
    }

    /**
     * 프로 부여: 회원·날짜 검증 > 행 잠금 조회 > 만료일 지정 또는 생성(ADMIN_GRANT) > 감사 기록
     * 활성 유료 패스보다 짧은 날짜도 허용 (확인은 관리자 화면 confirm), 지난 날짜는 거절 (회수 사용)
     * 반환: 기존 만료일보다 줄였으면 true
     */
    @Transactional
    public boolean grantPro(UUID memberUuid, LocalDate expiresDate) {
        // 요청 검증 (회원 존재, 오늘 이후 날짜)
        if (!memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }
        if (expiresDate == null || expiresDate.isBefore(todayInServiceZone())) {
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
        return previousExpiresAt != null && previousExpiresAt.isAfter(newExpiresAt);
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

    /**
     * 구매 1건 회수: 회원 소유·검증 상태 확인 > REVOKED + 등급 재계산(환불 작업과 같은 공통 회수기) > 감사 기록
     * 다른 회원 구매 ACCESS_DENIED, 없는 구매 RESOURCE_NOT_FOUND, 이미 회수 INVALID_REQUEST
     * 반환: 재계산 결과 (종류, 회수 전후 만료일)
     */
    @Transactional
    public RevocationResult revokePurchase(UUID memberUuid, UUID entitlementPurchaseUuid) {
        // 요청 검증 (구매 존재, 회원 소유, 검증 상태)
        EntitlementPurchase purchase = entitlementPurchaseRepository.findById(entitlementPurchaseUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        if (!purchase.getMemberUuid().equals(memberUuid)) {
            log.warn("[billing] admin revoke purchase rejected 403 : purchase owned by another member, member={}", memberUuid);
            throw new CustomException(ErrorCode.ACCESS_DENIED);
        }
        if (purchase.getStatus() != PurchaseStatus.VERIFIED) {
            log.info("[billing] admin revoke purchase rejected 400 : not verified, member={}, order={}",
                memberUuid, purchase.getOrderId());
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }

        // 회수 + 등급 재계산
        RevocationResult revocationResult = entitlementPurchaseRevoker.revokeAndRecalculate(purchase, LocalDateTime.now(clock));

        log.info("[billing] admin revoke purchase : member={}, order={}, expires {} -> {}",
            memberUuid, purchase.getOrderId(), revocationResult.beforeExpiresAt(), revocationResult.afterExpiresAt());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.MEMBER, memberUuid, AdminAuditAction.RETRACT,
            AdminAuditEvent.summary("order", purchase.getOrderId(), "purchaseStatus", PurchaseStatus.VERIFIED,
                "proExpiresAt", revocationResult.beforeExpiresAt()),
            AdminAuditEvent.summary("order", purchase.getOrderId(), "purchaseStatus", PurchaseStatus.REVOKED,
                "proExpiresAt", revocationResult.afterExpiresAt())));
        return revocationResult;
    }

    /** 회원 상세용: 현재 등급 행 > 유효 프로 여부, 구매 이력 최신순 */
    @Transactional(readOnly = true)
    public MemberEntitlementAdminView getEntitlementView(UUID memberUuid) {
        MemberEntitlement entitlement = memberEntitlementRepository.findById(memberUuid).orElse(null);

        List<MemberEntitlementAdminView.PurchaseRow> purchaseRows = entitlementPurchaseRepository
            .findByMemberUuid(memberUuid, Sort.by(Sort.Direction.DESC, "purchasedAt"))
            .stream()
            .map(this::toPurchaseRow)
            .toList();

        return new MemberEntitlementAdminView(
            isActivePro(entitlement),
            entitlement != null ? entitlement.getExpiresAt() : null,
            entitlement != null ? entitlement.getSource() : null,
            purchaseRows,
            todayInServiceZone());
    }

    /** KST 오늘 (시계 시간대와 무관) */
    private LocalDate todayInServiceZone() {
        return LocalDate.ofInstant(clock.instant(), SERVICE_ZONE);
    }

    /** 유효한 프로 등급 행인지: PRO 이고 만료일이 지금 이후 (행 없음 false) */
    private boolean isActivePro(MemberEntitlement entitlement) {
        return entitlement != null
            && entitlement.getPlan() == MemberPlan.PRO
            && entitlement.getExpiresAt() != null
            && entitlement.getExpiresAt().isAfter(LocalDateTime.now(clock));
    }

    /** 구매 > 화면 행 (구매 토큰 제외) */
    private MemberEntitlementAdminView.PurchaseRow toPurchaseRow(EntitlementPurchase purchase) {
        return new MemberEntitlementAdminView.PurchaseRow(
            purchase.getEntitlementPurchaseUuid(),
            purchase.getStore(),
            purchase.getProductId(),
            purchase.getOrderId(),
            purchase.getPurchasedAt(),
            purchase.getStatus(),
            purchase.getGrantedExpiresAt(),
            Boolean.TRUE.equals(purchase.getIsConsumed()));
    }
}
