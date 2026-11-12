package com.passql.application.controltower;

import com.passql.application.billing.PlayRefundCheckService;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.ServiceTimeZone;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.service.AppSettingService;
import com.passql.meta.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.info.BuildProperties;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

/**
 * 관제소 확인할 일(attention v1) 연동: 수집 요청 검증, 의견함·환불 회수 확인 스냅샷 생성, 관리자 화면 상태
 * 스냅샷 = 의견 상태별 개수 집계 1회 (GROUP BY) + 결제 켜짐이면 환불 회수 확인 상태, 마지막 수집 시각은 메모리 보관 (재시작 시 비움)
 */
@Service
@RequiredArgsConstructor
public class ControlTowerAttentionService {

    // attention source.app: 관제소 화면·로그 표시용 앱 이름
    static final String SOURCE_APP_NAME = "passql-server";
    // attention source.environment 값 (production 이 아니면 관제소가 알림을 보내지 않음)
    static final String ENVIRONMENT_PRODUCTION = "production";
    static final String ENVIRONMENT_DEVELOPMENT = "development";
    // 운영 Spring 프로필 이름 (CICD SPRING_PROFILE)
    private static final String PRODUCTION_PROFILE = "prod";
    private static final String HTTPS_SCHEME_PREFIX = "https://";

    // 항목 key (관제소 표준 key, 바꾸면 관제소에서 새 항목으로 취급)
    static final String FEEDBACK_NEW_KEY = "feedback.new";
    static final String FEEDBACK_IN_PROGRESS_KEY = "feedback.in_progress";
    private static final String FEEDBACK_NEW_LABEL = "새 의견";
    private static final String FEEDBACK_IN_PROGRESS_LABEL = "확인 중 의견";
    private static final String FEEDBACK_GROUP = "의견함";
    // 관리자 의견 목록 상태 필터: /admin/feedbacks?status=PENDING (admin_base_url 뒤에 붙음)
    private static final String FEEDBACK_ADMIN_PATH_FORMAT = "/admin/feedbacks?status=%s";
    // 환불 회수 확인 (#984): 최근 실행 실패 또는 26시간 안에 성공 없음 > 1
    static final String BILLING_REFUND_CHECK_KEY = "billing.refund_check_failed";
    private static final String BILLING_REFUND_CHECK_LABEL = "환불 회수 확인 실패";
    private static final String BILLING_GROUP = "결제";
    private static final String BILLING_REFUND_CHECK_ADMIN_PATH = "/admin/subscriptions";

    private final ControlTowerAttentionProperties properties;
    private final ControlTowerAttentionTokenVerifier tokenVerifier;
    private final FeedbackService feedbackService;
    private final AppSettingService appSettingService;
    private final FeatureAccessPolicy featureAccessPolicy;
    private final PlayRefundCheckService playRefundCheckService;
    private final Environment environment;
    private final ObjectProvider<BuildProperties> buildPropertiesProvider;

    private final AtomicReference<Instant> lastCollectedAt = new AtomicReference<>();

    /** 관제소 수집: 연동 켜짐 확인(꺼짐 404) > 토큰 검증(실패 401) > 수집 시각 기록 > 스냅샷 */
    public ControlTowerAttentionResponse collectSnapshot(String presentedToken) {
        if (!isIntegrationEnabled()) {
            throw new CustomException(ErrorCode.RESOURCE_NOT_FOUND);
        }
        if (!tokenVerifier.isAcceptedToken(presentedToken)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED);
        }
        lastCollectedAt.set(Instant.now());
        return buildSnapshot();
    }

    /** 관리자 화면 상태: 켜짐, 토큰 설정 여부, 마지막 수집 시각(KST), 실제 응답과 같은 항목 */
    public ControlTowerAttentionAdminStatus getAdminStatus() {
        Instant collectedAt = lastCollectedAt.get();
        LocalDateTime collectedAtInServiceZone = collectedAt == null
            ? null
            : LocalDateTime.ofInstant(collectedAt, ServiceTimeZone.ZONE);
        return new ControlTowerAttentionAdminStatus(isIntegrationEnabled(), tokenVerifier.hasConfiguredToken(),
            tokenVerifier.hasConfiguredPreviousToken(), collectedAtInServiceZone, buildItems());
    }

    /** 연동 켜기 설정 (app_setting, 행 없음은 꺼짐) */
    public boolean isIntegrationEnabled() {
        return appSettingService.getBooleanOrDefault(AppSettingKeys.CONTROL_TOWER_ATTENTION_ENABLED, false);
    }

    ControlTowerAttentionResponse buildSnapshot() {
        return ControlTowerAttentionResponse.of(buildSource(), Instant.now().truncatedTo(ChronoUnit.MILLIS), buildItems());
    }

    /**
     * 항목: 의견 상태별 개수 2개(0건도 포함, total = 전체 의견 수, 의견 행은 지우지 않아 줄지 않음)
     * + 결제 켜짐이면 환불 회수 확인 1개 (결제 꺼짐이면 확인 작업이 의미 없어 생략)
     */
    List<ControlTowerAttentionItem> buildItems() {
        Map<FeedbackStatus, Long> countByStatus = feedbackService.countByStatus();
        long totalFeedbackCount = countByStatus.values().stream().mapToLong(Long::longValue).sum();
        List<ControlTowerAttentionItem> items = new ArrayList<>(List.of(
            ControlTowerAttentionItem.count(FEEDBACK_NEW_KEY, FEEDBACK_NEW_LABEL, FEEDBACK_GROUP,
                toFeedbackAdminPath(FeedbackStatus.PENDING), countByStatus.get(FeedbackStatus.PENDING), totalFeedbackCount),
            ControlTowerAttentionItem.count(FEEDBACK_IN_PROGRESS_KEY, FEEDBACK_IN_PROGRESS_LABEL, FEEDBACK_GROUP,
                toFeedbackAdminPath(FeedbackStatus.REVIEWED), countByStatus.get(FeedbackStatus.REVIEWED), null)));
        if (featureAccessPolicy.isBillingEnabled()) {
            items.add(ControlTowerAttentionItem.warningCount(BILLING_REFUND_CHECK_KEY, BILLING_REFUND_CHECK_LABEL,
                BILLING_GROUP, findHttpsAdminBaseUrl() == null ? null : BILLING_REFUND_CHECK_ADMIN_PATH,
                playRefundCheckService.needsRefundCheckAttention() ? 1 : 0));
        }
        return List.copyOf(items);
    }

    private ControlTowerAttentionSource buildSource() {
        BuildProperties buildProperties = buildPropertiesProvider.getIfAvailable();
        String appVersion = buildProperties == null ? null : buildProperties.getVersion();
        return new ControlTowerAttentionSource(SOURCE_APP_NAME, appVersion, toSourceEnvironment(), findHttpsAdminBaseUrl());
    }

    /** 활성 프로필 > attention environment (prod > production, 그 외 development) */
    private String toSourceEnvironment() {
        return environment.acceptsProfiles(Profiles.of(PRODUCTION_PROFILE)) ? ENVIRONMENT_PRODUCTION : ENVIRONMENT_DEVELOPMENT;
    }

    /** 관리자 기준 주소 (https 만, 끝 / 제거, 아니면 null > 상대 admin_url 도 생략) */
    private String findHttpsAdminBaseUrl() {
        String adminBaseUrl = properties.adminBaseUrl();
        if (adminBaseUrl == null || !adminBaseUrl.trim().startsWith(HTTPS_SCHEME_PREFIX)) {
            return null;
        }
        String trimmedAdminBaseUrl = adminBaseUrl.trim();
        return trimmedAdminBaseUrl.endsWith("/")
            ? trimmedAdminBaseUrl.substring(0, trimmedAdminBaseUrl.length() - 1)
            : trimmedAdminBaseUrl;
    }

    private String toFeedbackAdminPath(FeedbackStatus status) {
        return findHttpsAdminBaseUrl() == null ? null : FEEDBACK_ADMIN_PATH_FORMAT.formatted(status.name());
    }
}
