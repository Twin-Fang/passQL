package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.ChoiceGenerationMode;
import com.passql.member.constant.MemberPlan;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.entity.MemberEntitlement;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import com.passql.submission.repository.SubmissionRepository;
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

    // 프로 하루 공정 사용 한도 (개, 화면에 드러내지 않음)
    public static final int DAILY_PRO_FAIR_USE_LIMIT = 200;

    // 서비스 기준 시간대 (등급 만료일·하루 구간은 KST 로컬 저장값)
    static final ZoneId SERVICE_ZONE = ZoneId.of("Asia/Seoul");
    // 등급 응답 문자열
    private static final String PLAN_PRO = "PRO";
    private static final String PLAN_FREE = "FREE";
    // app_settings: 안드로이드 결제 사용 여부 (1:사용 0:미사용, 행 없으면 미사용)
    private static final boolean DEFAULT_BILLING_ENABLED = false;

    private final MemberEntitlementRepository memberEntitlementRepository;
    private final AppSettingService appSettingService;
    private final ExamPassExpiryCalculator examPassExpiryCalculator;
    private final SubmissionRepository submissionRepository;
    private final DailyQuestionCounter dailyQuestionCounter;
    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final Clock clock;

    @Autowired
    public FeatureAccessPolicy(MemberEntitlementRepository memberEntitlementRepository,
                               AppSettingService appSettingService,
                               ExamPassExpiryCalculator examPassExpiryCalculator,
                               SubmissionRepository submissionRepository,
                               DailyQuestionCounter dailyQuestionCounter,
                               EntitlementPurchaseRepository entitlementPurchaseRepository) {
        this(memberEntitlementRepository, appSettingService, examPassExpiryCalculator,
            submissionRepository, dailyQuestionCounter, entitlementPurchaseRepository, Clock.system(SERVICE_ZONE));
    }

    FeatureAccessPolicy(MemberEntitlementRepository memberEntitlementRepository,
                        AppSettingService appSettingService,
                        ExamPassExpiryCalculator examPassExpiryCalculator,
                        SubmissionRepository submissionRepository,
                        DailyQuestionCounter dailyQuestionCounter,
                        EntitlementPurchaseRepository entitlementPurchaseRepository, Clock clock) {
        this.memberEntitlementRepository = memberEntitlementRepository;
        this.appSettingService = appSettingService;
        this.examPassExpiryCalculator = examPassExpiryCalculator;
        this.submissionRepository = submissionRepository;
        this.dailyQuestionCounter = dailyQuestionCounter;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
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

    /** 선택지 생성 모드 보정: 실전 모드 사용 불가(무료)면 PRACTICE 로 취급, 저장값은 그대로 */
    public ChoiceGenerationMode resolveEffectiveChoiceGenerationMode(UUID memberUuid, ChoiceGenerationMode storedMode) {
        if (storedMode == ChoiceGenerationMode.REAL && !canUse(memberUuid, ProFeature.REAL_MODE)) {
            return ChoiceGenerationMode.PRACTICE;
        }
        return storedMode;
    }

    /**
     * 문제 열기 제한: 스위치 > 오늘의 문제 > 예전에 푼 문제 > 오늘 새로 연 수(무료 10, 프로 200)
     * 스위치 꺼짐, 오늘의 문제, 제출 이력 있는 문제는 항상 통과
     */
    public void assertCanOpenQuestion(UUID memberUuid, UUID questionUuid) {
        if (!isBillingEnabled()) {
            return;
        }
        // 오늘의 문제 배정분은 한도와 무관
        if (dailyQuestionCounter.isTodaysDailyChallengeQuestion(questionUuid)) {
            return;
        }
        // 예전에 한 번이라도 제출한 문제는 날짜와 무관하게 다시 열 수 있음
        if (submissionRepository.existsByMemberUuidAndQuestionUuid(memberUuid, questionUuid)) {
            return;
        }

        // 오늘 새로 연 문제 수 <-> 등급별 한도
        int todayRandomSolvedCount = dailyQuestionCounter.countTodayRandomSolved(memberUuid);
        if (isPro(memberUuid)) {
            if (todayRandomSolvedCount >= DAILY_PRO_FAIR_USE_LIMIT) {
                log.info("[pro access] rejected 429 : fair use daily limit, member={}, count={}", memberUuid, todayRandomSolvedCount);
                throw new CustomException(ErrorCode.FAIR_USE_DAILY_LIMIT_REACHED);
            }
            return;
        }
        if (todayRandomSolvedCount >= DAILY_FREE_LIMIT) {
            log.info("[pro access] rejected 403 : free daily limit, member={}, count={}", memberUuid, todayRandomSolvedCount);
            throw new CustomException(ErrorCode.FREE_DAILY_LIMIT_REACHED);
        }
    }

    /** 내 등급 응답 (구매 시 만료일·오늘 사용량·최근 구매는 결제 켜짐일 때만, 최근 구매는 검증 구매 기준) */
    public MemberPlanResponse getPlan(UUID memberUuid) {
        boolean isBillingEnabled = isBillingEnabled();
        MemberEntitlement activeProEntitlement = findActiveProEntitlement(memberUuid);
        boolean isPro = !isBillingEnabled || activeProEntitlement != null;
        LocalDateTime activeProExpiresAtOrNull = activeProEntitlement != null ? activeProEntitlement.getExpiresAt() : null;

        // 지금 구매하면 유효한 날짜 (결제 꺼짐이면 없음)
        LocalDateTime purchasableUntil = isBillingEnabled
            ? examPassExpiryCalculator.calculateExpiresAt(LocalDateTime.now(clock), activeProExpiresAtOrNull)
            : null;

        int todayRandomSolvedCount = isBillingEnabled ? dailyQuestionCounter.countTodayRandomSolved(memberUuid) : 0;

        // 이용권 정보 시트용 최근 검증 구매 (결제 꺼짐·관리자 부여만 있으면 없음)
        EntitlementPurchase lastVerifiedPurchase = isBillingEnabled
            ? entitlementPurchaseRepository
                .findFirstByMemberUuidAndStatusOrderByPurchasedAtDesc(memberUuid, PurchaseStatus.VERIFIED)
                .orElse(null)
            : null;

        return new MemberPlanResponse(
            isBillingEnabled,
            isPro ? PLAN_PRO : PLAN_FREE,
            activeProExpiresAtOrNull,
            todayRandomSolvedCount,
            DAILY_FREE_LIMIT,
            purchasableUntil,
            lastVerifiedPurchase != null ? lastVerifiedPurchase.getPurchasedAt() : null,
            lastVerifiedPurchase != null ? lastVerifiedPurchase.getOrderId() : null);
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
