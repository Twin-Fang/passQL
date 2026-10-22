package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.MemberPlan;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.UUID;

/**
 * 등급 판정 단일 지점: 결제 스위치 확인, 프로 여부, 기능별 잠금
 * 스위치 꺼짐 > 전원 프로 취급, 켜짐 > 등급 행 PRO 이고 만료 전일 때만 프로
 */
@Slf4j
@Service
public class FeatureAccessPolicy {

    // 무료 하루 랜덤 문제 한도 (개)
    public static final int DAILY_FREE_LIMIT = 10;

    // 서비스 기준 시간대 (등급 만료일은 KST 로컬 저장값)
    private static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");
    // 등급 응답 문자열
    private static final String PLAN_PRO = "PRO";
    private static final String PLAN_FREE = "FREE";
    // app_settings: 안드로이드 결제 사용 여부 (1:사용 0:미사용, 행 없으면 미사용)
    private static final boolean DEFAULT_BILLING_ENABLED = false;

    private final MemberEntitlementRepository memberEntitlementRepository;
    private final AppSettingService appSettingService;
    private final ExamPassExpiryCalculator examPassExpiryCalculator;
    private final Clock clock;

    @Autowired
    public FeatureAccessPolicy(MemberEntitlementRepository memberEntitlementRepository,
                               AppSettingService appSettingService,
                               ExamPassExpiryCalculator examPassExpiryCalculator) {
        this(memberEntitlementRepository, appSettingService, examPassExpiryCalculator, Clock.system(SERVICE_ZONE));
    }

    FeatureAccessPolicy(MemberEntitlementRepository memberEntitlementRepository,
                        AppSettingService appSettingService,
                        ExamPassExpiryCalculator examPassExpiryCalculator, Clock clock) {
        this.memberEntitlementRepository = memberEntitlementRepository;
        this.appSettingService = appSettingService;
        this.examPassExpiryCalculator = examPassExpiryCalculator;
        this.clock = clock;
    }

    /** 결제 스위치 (app_settings billing.android.enabled) */
    public boolean isBillingEnabled() {
        return appSettingService.getBooleanOrDefault(AppSettingKeys.BILLING_ANDROID_ENABLED, DEFAULT_BILLING_ENABLED);
    }

    /** 프로 여부: 스위치 꺼짐 true, 아니면 유효한 프로 등급 행 존재 */
    public boolean isPro(UUID memberUuid) {
        if (!isBillingEnabled()) {
            return true;
        }
        return findActiveProEntitlement(memberUuid) != null;
    }

    /** 기능 사용 가능 여부 (현재 모든 기능이 프로 여부와 동일) */
    public boolean canUse(UUID memberUuid, ProFeature feature) {
        return isPro(memberUuid);
    }

    /** 기능 잠금 검사: 불가 시 PRO_REQUIRED */
    public void requireFeature(UUID memberUuid, ProFeature feature) {
        if (!canUse(memberUuid, feature)) {
            log.info("[pro access] rejected 403 : feature={}", feature);
            throw new CustomException(ErrorCode.PRO_REQUIRED);
        }
    }

    /** 내 등급 응답 (오늘 사용량은 후속 태스크에서 채움, 구매 시 만료일은 결제 켜짐일 때만) */
    public MemberPlanResponse getPlan(UUID memberUuid) {
        boolean isBillingEnabled = isBillingEnabled();
        MemberEntitlement activeProEntitlement = findActiveProEntitlement(memberUuid);
        boolean isPro = !isBillingEnabled || activeProEntitlement != null;
        LocalDateTime activeProExpiresAtOrNull = activeProEntitlement != null ? activeProEntitlement.getExpiresAt() : null;

        // 지금 구매하면 유효한 날짜 (결제 꺼짐이면 없음)
        LocalDateTime purchasableUntil = isBillingEnabled
            ? examPassExpiryCalculator.calculateExpiresAt(LocalDateTime.now(clock), activeProExpiresAtOrNull)
            : null;

        return new MemberPlanResponse(
            isBillingEnabled,
            isPro ? PLAN_PRO : PLAN_FREE,
            activeProExpiresAtOrNull,
            0,
            DAILY_FREE_LIMIT,
            purchasableUntil);
    }

    /** 유효한 프로 등급 행 (PRO 이고 만료일이 지금 이후), 없으면 null */
    private MemberEntitlement findActiveProEntitlement(UUID memberUuid) {
        LocalDateTime now = LocalDateTime.now(clock);
        return memberEntitlementRepository.findById(memberUuid)
            .filter(entitlement -> entitlement.getPlan() == MemberPlan.PRO)
            .filter(entitlement -> entitlement.getExpiresAt() != null && entitlement.getExpiresAt().isAfter(now))
            .orElse(null);
    }
}
