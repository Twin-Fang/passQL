package com.passql.application.billing;

import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.service.MemberAdminService;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.dto.AppOperationSettingsResponse;
import com.passql.meta.service.AppOperationService;
import com.passql.meta.service.AppSettingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.ObjectProvider;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 결제 켜기 전 점검표 판정 (#961): 항목별 충족 여부, 비밀 값 미노출, 읽기 실패 시 목록 보존
 */
class BillingOperationServiceTest {

    // 저장된 서비스 계정 키 자리 값 (실제 키 아님)
    private static final String STORED_SERVICE_ACCOUNT_VALUE = "stored-service-account-placeholder";

    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final AppOperationService appOperationService = mock(AppOperationService.class);
    private BillingOperationService billingOperationService;

    @BeforeEach
    @SuppressWarnings("unchecked")
    void setUp() {
        billingOperationService = new BillingOperationService(appSettingService, appOperationService,
                mock(FeatureAccessPolicy.class), mock(MemberAdminService.class), mock(ObjectProvider.class));
    }

    @Test
    void 모든_값이_준비되면_점검표_전_항목이_충족이다() {
        givenSettings(STORED_SERVICE_ACCOUNT_VALUE, "ca-app-pub-1/1, ca-app-pub-1/2", "true");
        givenMinimumVersions("1.90.0", "1.91.0");

        List<BillingReadinessItem> readinessItems = billingOperationService.buildReadinessItems(2);

        assertThat(readinessItems).hasSize(6).allMatch(BillingReadinessItem::isReady);
    }

    @Test
    void 비어_있는_값과_차단_없는_최소_버전은_미충족으로_판정한다() {
        givenSettings("", " , ", "false");
        givenMinimumVersions(AppOperationService.NO_REQUIREMENT_VERSION, "1.91.0");

        List<BillingReadinessItem> readinessItems = billingOperationService.buildReadinessItems(0);

        assertThat(readinessItems).filteredOn(readinessItem -> !readinessItem.isReady())
                .extracting(BillingReadinessItem::label)
                .containsExactly(
                        BillingOperationService.PLAY_SERVICE_ACCOUNT_LABEL,
                        BillingOperationService.SSV_AD_UNIT_IDS_LABEL,
                        BillingOperationService.SSV_REQUIRED_LABEL,
                        BillingOperationService.IOS_MINIMUM_VERSION_LABEL,
                        BillingOperationService.PREVIEW_MEMBERS_LABEL);
    }

    @Test
    void 설정_행이_없으면_미설정으로_판정한다() {
        when(appSettingService.getString(any())).thenThrow(new CustomException(ErrorCode.SETTING_NOT_FOUND));
        givenMinimumVersions("1.90.0", "1.91.0");

        List<BillingReadinessItem> readinessItems = billingOperationService.buildReadinessItems(1);

        assertThat(readinessItems).filteredOn(readinessItem -> !readinessItem.isReady())
                .extracting(BillingReadinessItem::label)
                .containsExactly(
                        BillingOperationService.PLAY_SERVICE_ACCOUNT_LABEL,
                        BillingOperationService.SSV_AD_UNIT_IDS_LABEL,
                        BillingOperationService.SSV_REQUIRED_LABEL);
    }

    @Test
    void 점검표_문구에_비밀_값을_담지_않는다() {
        givenSettings(STORED_SERVICE_ACCOUNT_VALUE, "ca-app-pub-1/1", "true");
        givenMinimumVersions("1.90.0", "1.91.0");

        List<BillingReadinessItem> readinessItems = billingOperationService.buildReadinessItems(1);

        assertThat(readinessItems).extracting(BillingReadinessItem::statusText)
                .noneMatch(statusText -> statusText.contains(STORED_SERVICE_ACCOUNT_VALUE));
    }

    @Test
    void 미리보기_목록을_읽지_못하면_삭제_요청이_목록을_덮어쓰지_않는다() {
        when(appSettingService.getString(AppSettingKeys.BILLING_PREVIEW_MEMBER_UUIDS))
                .thenThrow(new IllegalStateException("store unavailable"));

        assertThatThrownBy(() -> billingOperationService.removePreviewMember("any-entry"))
                .isInstanceOf(IllegalStateException.class);
        verify(appSettingService, never()).save(any(), any());
    }

    private void givenSettings(String playServiceAccountValue, String ssvAdUnitIdsText, String ssvRequiredText) {
        when(appSettingService.getString(AppSettingKeys.BILLING_PLAY_SERVICE_ACCOUNT_JSON)).thenReturn(playServiceAccountValue);
        when(appSettingService.getString(AppSettingKeys.ADS_REWARD_SSV_AD_UNIT_IDS)).thenReturn(ssvAdUnitIdsText);
        when(appSettingService.getString(AppSettingKeys.ADS_REWARD_SSV_REQUIRED)).thenReturn(ssvRequiredText);
    }

    private void givenMinimumVersions(String iosMinimumVersion, String androidMinimumVersion) {
        when(appOperationService.getOperationSettings()).thenReturn(new AppOperationSettingsResponse(
                iosMinimumVersion, "0.0.0", androidMinimumVersion, "0.0.0", false, "", null, null, false));
    }
}
