package com.passql.application.controltower;

import com.passql.application.constant.ControlTowerAttentionLevel;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.service.AppSettingService;
import com.passql.meta.service.FeedbackService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.info.BuildProperties;
import org.springframework.mock.env.MockEnvironment;

import java.util.EnumMap;
import java.util.Map;
import java.util.Properties;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 관제소 attention 스냅샷 (#959): 꺼짐 404 > 토큰 401 > 의견 항목 2개(0건 포함, 0 ok·1 이상 info)
 */
class ControlTowerAttentionServiceTest {

    private static final String TOKEN = "control-token";
    private static final String ADMIN_BASE_URL = "https://api.passql.example/";

    private final FeedbackService feedbackService = mock(FeedbackService.class);
    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final MockEnvironment environment = new MockEnvironment();

    @BeforeEach
    void setUp() {
        givenIntegrationEnabled(true);
        givenFeedbackCounts(0, 0, 0);
    }

    @Test
    void 연동이_꺼져_있으면_토큰이_맞아도_404() {
        givenIntegrationEnabled(false);

        assertThatThrownBy(() -> serviceOf(TOKEN).collectSnapshot(TOKEN))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.RESOURCE_NOT_FOUND));
        verify(feedbackService, never()).countByStatus();
    }

    @Test
    void 토큰이_없거나_틀리거나_서버에_미설정이면_401() {
        assertUnauthorized(serviceOf(TOKEN), null);
        assertUnauthorized(serviceOf(TOKEN), "wrong-token");
        assertUnauthorized(serviceOf(""), "");
        assertThat(serviceOf(TOKEN).getAdminStatus().lastCollectedAt()).isNull();
    }

    @Test
    void 이전_토큰으로도_수집한다() {
        ControlTowerAttentionService service = serviceOf(new ControlTowerAttentionProperties(TOKEN, "old-token", ADMIN_BASE_URL));

        assertThat(service.collectSnapshot("old-token").items()).hasSize(2);
        assertThat(service.getAdminStatus().lastCollectedAt()).isNotNull();
    }

    @Test
    void 영건이어도_두_항목을_ok_로_내보낸다() {
        ControlTowerAttentionResponse response = serviceOf(TOKEN).collectSnapshot(TOKEN);

        assertThat(response.schema()).isEqualTo("attention");
        assertThat(response.version()).isEqualTo("1.0");
        assertThat(response.generatedAt()).isNotNull();
        assertThat(response.items()).extracting(ControlTowerAttentionItem::key)
            .containsExactly("feedback.new", "feedback.in_progress");
        assertThat(response.items()).allSatisfy(item -> {
            assertThat(item.kind()).isEqualTo("count");
            assertThat(item.count()).isZero();
            assertThat(item.level()).isEqualTo(ControlTowerAttentionLevel.OK);
        });
    }

    @Test
    void 개수가_있으면_info_와_누적_개수_관리자_주소를_담는다() {
        givenFeedbackCounts(3, 2, 5);

        ControlTowerAttentionResponse response = serviceOf(TOKEN).collectSnapshot(TOKEN);
        ControlTowerAttentionItem newFeedback = response.items().get(0);
        ControlTowerAttentionItem inProgressFeedback = response.items().get(1);

        assertThat(newFeedback.label()).isEqualTo("새 의견");
        assertThat(newFeedback.count()).isEqualTo(3);
        assertThat(newFeedback.total()).isEqualTo(10);
        assertThat(newFeedback.level()).isEqualTo(ControlTowerAttentionLevel.INFO);
        assertThat(newFeedback.adminUrl()).isEqualTo("/admin/feedbacks?status=PENDING");
        assertThat(inProgressFeedback.label()).isEqualTo("확인 중 의견");
        assertThat(inProgressFeedback.count()).isEqualTo(2);
        assertThat(inProgressFeedback.total()).isNull();
        assertThat(inProgressFeedback.adminUrl()).isEqualTo("/admin/feedbacks?status=REVIEWED");
        assertThat(response.source().adminBaseUrl()).isEqualTo("https://api.passql.example");
    }

    @Test
    void 운영_프로필이면_production_그_외는_development() {
        assertThat(serviceOf(TOKEN).collectSnapshot(TOKEN).source().environment()).isEqualTo("development");

        environment.setActiveProfiles("prod");
        ControlTowerAttentionSource source = serviceOf(TOKEN).collectSnapshot(TOKEN).source();

        assertThat(source.environment()).isEqualTo("production");
        assertThat(source.app()).isEqualTo("passql-server");
        assertThat(source.appVersion()).isEqualTo("1.94.5");
    }

    @Test
    void https_가_아닌_관리자_기준_주소는_링크를_생략한다() {
        ControlTowerAttentionResponse response = serviceOf(
            new ControlTowerAttentionProperties(TOKEN, null, "http://localhost:8080")).collectSnapshot(TOKEN);

        assertThat(response.source().adminBaseUrl()).isNull();
        assertThat(response.items()).allSatisfy(item -> assertThat(item.adminUrl()).isNull());
    }

    private void assertUnauthorized(ControlTowerAttentionService service, String presentedToken) {
        assertThatThrownBy(() -> service.collectSnapshot(presentedToken))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.UNAUTHORIZED));
    }

    private void givenIntegrationEnabled(boolean isEnabled) {
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.CONTROL_TOWER_ATTENTION_ENABLED), anyBoolean()))
            .thenReturn(isEnabled);
    }

    private void givenFeedbackCounts(long pendingCount, long reviewedCount, long appliedCount) {
        Map<FeedbackStatus, Long> countByStatus = new EnumMap<>(FeedbackStatus.class);
        countByStatus.put(FeedbackStatus.PENDING, pendingCount);
        countByStatus.put(FeedbackStatus.REVIEWED, reviewedCount);
        countByStatus.put(FeedbackStatus.APPLIED, appliedCount);
        when(feedbackService.countByStatus()).thenReturn(countByStatus);
    }

    private ControlTowerAttentionService serviceOf(String token) {
        return serviceOf(new ControlTowerAttentionProperties(token, null, ADMIN_BASE_URL));
    }

    @SuppressWarnings("unchecked")
    private ControlTowerAttentionService serviceOf(ControlTowerAttentionProperties properties) {
        Properties buildInfo = new Properties();
        buildInfo.setProperty("version", "1.94.5");
        ObjectProvider<BuildProperties> buildPropertiesProvider = mock(ObjectProvider.class);
        when(buildPropertiesProvider.getIfAvailable()).thenReturn(new BuildProperties(buildInfo));
        return new ControlTowerAttentionService(properties, new ControlTowerAttentionTokenVerifier(properties),
            feedbackService, appSettingService, environment, buildPropertiesProvider);
    }
}
