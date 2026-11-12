package com.passql.application.billing;

import com.passql.application.entitlement.AdBonusGrantService;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.UuidUtils;
import com.passql.member.dto.MemberAdminListResponse;
import com.passql.member.service.MemberAdminService;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.dto.AppOperationSettingsResponse;
import com.passql.meta.service.AppOperationService;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.info.BuildProperties;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 결제 운영 (#961): 결제 스위치 전환, 미리보기 회원 추가·삭제, 켜기 전 점검표
 * 저장은 AppSettingService.save 경유 (감사 로그·캐시 반영 공통), 점검표는 막지 않고 상태만 알림
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BillingOperationService {

    // 점검표 항목 이름 (화면 표·켜기 확인 창 공통)
    static final String PLAY_SERVICE_ACCOUNT_LABEL = "Play 서비스 계정 키";
    static final String SSV_AD_UNIT_IDS_LABEL = "광고 서버 검증 단위 ID";
    static final String SSV_REQUIRED_LABEL = "광고 서버 검증 필수";
    static final String IOS_MINIMUM_VERSION_LABEL = "iOS 최소 버전";
    static final String ANDROID_MINIMUM_VERSION_LABEL = "Android 최소 버전";
    static final String PREVIEW_MEMBERS_LABEL = "미리보기 회원";
    // 상태 문구
    private static final String CONFIGURED_TEXT = "설정됨";
    private static final String NOT_CONFIGURED_TEXT = "미설정";

    private final AppSettingService appSettingService;
    private final AppOperationService appOperationService;
    private final FeatureAccessPolicy featureAccessPolicy;
    private final MemberAdminService memberAdminService;
    private final ObjectProvider<BuildProperties> buildPropertiesProvider;

    /** 결제 영역 화면 값: 스위치 + 미리보기 회원 + 점검표 + 서버 빌드 버전 */
    public BillingOperationView getBillingOperationView() {
        List<String> previewMemberEntries = readPreviewMemberEntriesOrEmpty();
        return new BillingOperationView(
                featureAccessPolicy.isBillingEnabled(),
                previewMemberEntries.stream().map(this::toPreviewMember).toList(),
                buildReadinessItems(previewMemberEntries.size()),
                findReleaseVersionOrNull());
    }

    /**
     * 켜기 전 점검표 6개: Play 서비스 계정 키, 광고 서버 검증 단위 ID, 광고 서버 검증 필수, 최소 버전(iOS·Android), 미리보기 회원 수
     * 비밀 값은 저장 여부만 확인 (복호화하지 않음)
     */
    List<BillingReadinessItem> buildReadinessItems(int previewMemberCount) {
        boolean hasPlayServiceAccount = StringUtils.hasText(readTextOrEmpty(AppSettingKeys.BILLING_PLAY_SERVICE_ACCOUNT_JSON));
        int ssvAdUnitIdCount = splitEntries(readTextOrEmpty(AppSettingKeys.ADS_REWARD_SSV_AD_UNIT_IDS),
                AdBonusGrantService.AD_UNIT_ID_DELIMITER).size();
        boolean isSsvRequired = Boolean.parseBoolean(readTextOrEmpty(AppSettingKeys.ADS_REWARD_SSV_REQUIRED).trim());
        AppOperationSettingsResponse operationSettings = appOperationService.getOperationSettings();
        return List.of(
                new BillingReadinessItem(PLAY_SERVICE_ACCOUNT_LABEL, hasPlayServiceAccount,
                        hasPlayServiceAccount ? CONFIGURED_TEXT : NOT_CONFIGURED_TEXT),
                new BillingReadinessItem(SSV_AD_UNIT_IDS_LABEL, ssvAdUnitIdCount > 0,
                        ssvAdUnitIdCount > 0 ? CONFIGURED_TEXT + " (" + ssvAdUnitIdCount + "개)" : NOT_CONFIGURED_TEXT),
                new BillingReadinessItem(SSV_REQUIRED_LABEL, isSsvRequired, isSsvRequired ? "켜짐" : "꺼짐"),
                toMinimumVersionItem(IOS_MINIMUM_VERSION_LABEL, operationSettings.iosMinimumVersion()),
                toMinimumVersionItem(ANDROID_MINIMUM_VERSION_LABEL, operationSettings.androidMinimumVersion()),
                new BillingReadinessItem(PREVIEW_MEMBERS_LABEL, previewMemberCount > 0, previewMemberCount + "명"));
    }

    /** 결제 스위치 전환 (점검표 미충족이어도 저장, 확인은 화면 확인 창) */
    @Transactional
    public void changeBillingEnabled(boolean isEnabled) {
        boolean wasEnabled = featureAccessPolicy.isBillingEnabled();
        appSettingService.save(AppSettingKeys.BILLING_ANDROID_ENABLED, String.valueOf(isEnabled));
        log.info("[billing operation] switch changed : {} -> {}", wasEnabled, isEnabled);
    }

    /** 미리보기 회원 추가: UUID 형식 > 회원 존재 > 중복 확인 > 저장 */
    @Transactional
    public void addPreviewMember(String memberUuidText) {
        UUID memberUuid = UuidUtils.parseOrEmpty(memberUuidText == null ? null : memberUuidText.trim())
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT_VALUE, "회원 UUID 형식이 아닙니다."));
        if (memberAdminService.findMemberListItem(memberUuid).isEmpty()) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }
        List<String> entries = new ArrayList<>(readPreviewMemberEntries());
        if (entries.stream().anyMatch(entry -> entry.equalsIgnoreCase(memberUuid.toString()))) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "이미 미리보기 목록에 있는 회원입니다.");
        }
        entries.add(memberUuid.toString());
        savePreviewMemberEntries(entries);
        log.info("[billing operation] preview member added : member={}, count={}", UuidUtils.toShortForm(memberUuid), entries.size());
    }

    /** 미리보기 항목 삭제: 저장된 항목 원문 일치 (형식이 틀린 옛 항목도 지울 수 있게 UUID 변환 없이 비교) */
    @Transactional
    public void removePreviewMember(String entryText) {
        String targetEntry = entryText == null ? "" : entryText.trim();
        List<String> entries = new ArrayList<>(readPreviewMemberEntries());
        if (!entries.removeIf(entry -> entry.equalsIgnoreCase(targetEntry))) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "미리보기 목록에 없는 항목입니다.");
        }
        savePreviewMemberEntries(entries);
        log.info("[billing operation] preview member removed : count={}", entries.size());
    }

    private BillingReadinessItem toMinimumVersionItem(String label, String minimumVersion) {
        // 0.0.0: 결제 화면이 없는 옛 앱도 막지 않는 상태
        boolean hasMinimumVersion = !AppOperationService.NO_REQUIREMENT_VERSION.equals(minimumVersion);
        return new BillingReadinessItem(label, hasMinimumVersion,
                hasMinimumVersion ? minimumVersion : minimumVersion + " (차단 없음)");
    }

    /** 목록 항목 > 화면 항목 (닉네임은 탈퇴 제외 회원만) */
    private BillingPreviewMember toPreviewMember(String entry) {
        String nickname = UuidUtils.parseOrEmpty(entry)
                .flatMap(memberAdminService::findMemberListItem)
                .map(MemberAdminListResponse::nickname)
                .orElse(null);
        return new BillingPreviewMember(entry, nickname);
    }

    /** 화면용 미리보기 목록 (행 없음·저장소 장애 > 빈 목록) */
    private List<String> readPreviewMemberEntriesOrEmpty() {
        try {
            return readPreviewMemberEntries();
        } catch (RuntimeException e) {
            log.warn("[billing operation] preview members read failed, showing empty : reason={}", e.getClass().getSimpleName());
            return List.of();
        }
    }

    /** 저장용 미리보기 목록 (읽기 실패는 그대로 던짐: 빈 목록으로 덮어쓰지 않게) */
    private List<String> readPreviewMemberEntries() {
        return splitEntries(appSettingService.getString(AppSettingKeys.BILLING_PREVIEW_MEMBER_UUIDS),
                FeatureAccessPolicy.PREVIEW_MEMBER_UUID_DELIMITER);
    }

    private void savePreviewMemberEntries(List<String> entries) {
        appSettingService.save(AppSettingKeys.BILLING_PREVIEW_MEMBER_UUIDS,
                String.join(FeatureAccessPolicy.PREVIEW_MEMBER_UUID_DELIMITER, entries));
    }

    /** 구분자로 이어진 설정값 > 항목 목록 (공백 정리, 빈 항목 제외) */
    private static List<String> splitEntries(String delimitedText, String delimiter) {
        if (!StringUtils.hasText(delimitedText)) {
            return List.of();
        }
        return Arrays.stream(delimitedText.split(delimiter))
                .map(String::trim)
                .filter(entry -> !entry.isEmpty())
                .toList();
    }

    /** 점검표용 설정 원문 (행 없음·저장소 장애 > 빈 값, 미설정으로 표시) */
    private String readTextOrEmpty(String key) {
        try {
            String value = appSettingService.getString(key);
            return value == null ? "" : value;
        } catch (RuntimeException e) {
            log.warn("[billing operation] setting read failed, treating as empty : key={}, reason={}", key, e.getClass().getSimpleName());
            return "";
        }
    }

    private String findReleaseVersionOrNull() {
        BuildProperties buildProperties = buildPropertiesProvider.getIfAvailable();
        return buildProperties == null ? null : buildProperties.getVersion();
    }
}
