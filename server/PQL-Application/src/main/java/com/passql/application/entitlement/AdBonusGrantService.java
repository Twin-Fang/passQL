package com.passql.application.entitlement;

import com.passql.application.ads.AdMobRewardCallback;
import com.passql.application.ads.AdMobRewardCallbackVerifier;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.UuidUtils;
import com.passql.member.repository.MemberDailyAdBonusRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * 광고 보너스 받기 2경로 (#808, #860): 앱 신고(POST) · AdMob 서버 검증 콜백(SSV), 같은 광고는 보상 표식·거래 ID 로 1회만
 * ads.reward.ssv_required 켜짐 > 앱 신고는 콜백 기록 확인만, 꺼짐 > 앱 신고로도 기록 (출시 앱 호환)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdBonusGrantService {

    // app_settings ads.reward.ssv_required 읽기 실패·행 없음 기본값 (꺼짐 = 앱 신고로도 기록)
    private static final boolean IS_SSV_REQUIRED_BY_DEFAULT = false;
    // app_settings ads.reward.ssv_ad_unit_ids 구분자 (쉼표)
    private static final String AD_UNIT_ID_DELIMITER = ",";
    // 보상 표식 허용 형식 (앱은 UUID, 영문·숫자·하이픈 64자 이하)
    private static final Pattern REWARD_NONCE_PATTERN = Pattern.compile("[0-9A-Za-z-]{1,64}");
    // AdMob 거래 ID 최대 길이 (자, member_daily_ad_bonus.ssv_transaction_id 길이)
    private static final int TRANSACTION_ID_MAX_LENGTH = 128;
    // 외부 값 로그 최대 길이 (자)
    private static final int LOG_VALUE_MAX_LENGTH = 80;

    private final FeatureAccessPolicy featureAccessPolicy;
    private final DailyAdBonusRecorder dailyAdBonusRecorder;
    private final DailyFreeBonusReader dailyFreeBonusReader;
    private final MemberDailyAdBonusRepository memberDailyAdBonusRepository;
    private final AppSettingService appSettingService;
    private final AdMobRewardCallbackVerifier adMobRewardCallbackVerifier;

    /**
     * 앱 신고: 결제 꺼짐·프로 > 현재 등급, 이미 기록된 표식 > 현재 등급, 검증 필수 > 확인 대기·업데이트 안내, 그 외 기록 > 등급
     * 오늘 다 씀 > 409 AD_BONUS_DAILY_LIMIT_REACHED
     */
    public MemberPlanResponse grantByAppReport(UUID memberUuid, String rewardNonce) {
        if (featureAccessPolicy.isPro(memberUuid)) {
            return featureAccessPolicy.getPlan(memberUuid);
        }
        String validRewardNonce = toValidRewardNonceOrNull(rewardNonce);
        if (validRewardNonce != null && memberDailyAdBonusRepository.existsByMemberUuidAndRewardNonce(memberUuid, validRewardNonce)) {
            return featureAccessPolicy.getPlan(memberUuid);
        }
        if (isSsvRequired()) {
            throw toUnverifiedAppReportException(memberUuid, validRewardNonce);
        }
        if (!saveAdBonusWithRetry(memberUuid, validRewardNonce, null)) {
            log.info("[pro access] rejected 409 : ad bonus daily limit, member={}", memberUuid);
            throw new CustomException(ErrorCode.AD_BONUS_DAILY_LIMIT_REACHED);
        }
        return featureAccessPolicy.getPlan(memberUuid);
    }

    /**
     * 서버 검증 콜백: 서명 확인 > 광고 단위·회원·거래 ID 확인 > 결제 꺼짐·프로·이미 기록·오늘 다 씀이면 건너뜀 > 기록
     * 서명 실패만 403 (그 외 건너뜀은 200, AdMob 재전송 불필요)
     */
    public void grantByServerVerification(String rawQueryString) {
        AdMobRewardCallback callback = adMobRewardCallbackVerifier.verify(rawQueryString);
        if (!isAllowedAdUnit(callback.adUnit())) {
            log.warn("[admob ssv] ignored : ad unit not allowed, adUnit={}", sanitizeForLog(callback.adUnit()));
            return;
        }
        UUID memberUuid = UuidUtils.parseOrEmpty(callback.userId()).orElse(null);
        String transactionId = callback.transactionId();
        if (memberUuid == null || transactionId == null || transactionId.isBlank()
            || transactionId.length() > TRANSACTION_ID_MAX_LENGTH) {
            log.info("[admob ssv] ignored : no member or transaction id, transactionId={}", sanitizeForLog(transactionId));
            return;
        }
        if (featureAccessPolicy.isPro(memberUuid) || memberDailyAdBonusRepository.existsBySsvTransactionId(transactionId)) {
            return;
        }
        String validRewardNonce = toValidRewardNonceOrNull(callback.customData());
        if (validRewardNonce != null && memberDailyAdBonusRepository.existsByMemberUuidAndRewardNonce(memberUuid, validRewardNonce)) {
            return;
        }
        if (!saveAdBonusWithRetry(memberUuid, validRewardNonce, transactionId)) {
            log.info("[admob ssv] ignored : ad bonus daily limit, member={}", memberUuid);
        }
    }

    /** 검증 필수인데 콜백 기록이 없는 앱 신고 > 사유 (표식 없음 옛 앱 > 업데이트, 오늘 다 씀 > 409, 그 외 > 확인 대기) */
    private CustomException toUnverifiedAppReportException(UUID memberUuid, String validRewardNonce) {
        if (validRewardNonce == null) {
            log.info("[pro access] rejected 426 : ad bonus without reward nonce, member={}", memberUuid);
            return new CustomException(ErrorCode.AD_BONUS_APP_UPDATE_REQUIRED);
        }
        if (DailyFreeBonusRule.nextAdBonusSlot(dailyFreeBonusReader.countAdBonusUsedToday(memberUuid)).isEmpty()) {
            return new CustomException(ErrorCode.AD_BONUS_DAILY_LIMIT_REACHED);
        }
        return new CustomException(ErrorCode.AD_BONUS_VERIFICATION_PENDING);
    }

    /**
     * 기록 1회 + 실패 시 1회 재시도 (unique 충돌 = 같은 칸·표식·거래 ID 동시 저장)
     * 재시도 전 같은 광고가 이미 기록됐으면 성공 취급
     */
    private boolean saveAdBonusWithRetry(UUID memberUuid, String rewardNonce, String transactionId) {
        if (dailyAdBonusRecorder.saveNextAdBonus(memberUuid, rewardNonce, transactionId)) {
            return true;
        }
        if (isSameAdAlreadyRecorded(memberUuid, rewardNonce, transactionId)) {
            return true;
        }
        return dailyAdBonusRecorder.saveNextAdBonus(memberUuid, rewardNonce, transactionId);
    }

    private boolean isSameAdAlreadyRecorded(UUID memberUuid, String rewardNonce, String transactionId) {
        return (rewardNonce != null && memberDailyAdBonusRepository.existsByMemberUuidAndRewardNonce(memberUuid, rewardNonce))
            || (transactionId != null && memberDailyAdBonusRepository.existsBySsvTransactionId(transactionId));
    }

    /** 서버 검증 필수 스위치 (저장소 장애 > 꺼짐: 출시 앱 보너스가 막히지 않게) */
    private boolean isSsvRequired() {
        try {
            return appSettingService.getBooleanOrDefault(AppSettingKeys.ADS_REWARD_SSV_REQUIRED, IS_SSV_REQUIRED_BY_DEFAULT);
        } catch (RuntimeException e) {
            log.warn("[admob ssv] required switch read failed, treating as disabled : reason={}", e.getClass().getSimpleName());
            return IS_SSV_REQUIRED_BY_DEFAULT;
        }
    }

    /** 허용 광고 단위인가 (목록 비었거나 읽기 실패 > 확인 안 함) */
    private boolean isAllowedAdUnit(String adUnit) {
        Set<String> allowedAdUnitIds = readAllowedAdUnitIds();
        return allowedAdUnitIds.isEmpty() || (adUnit != null && allowedAdUnitIds.contains(adUnit));
    }

    private Set<String> readAllowedAdUnitIds() {
        String adUnitIdsText;
        try {
            adUnitIdsText = appSettingService.getString(AppSettingKeys.ADS_REWARD_SSV_AD_UNIT_IDS);
        } catch (RuntimeException e) {
            log.warn("[admob ssv] ad unit ids read failed, skipping check : reason={}", e.getClass().getSimpleName());
            return Set.of();
        }
        if (adUnitIdsText == null || adUnitIdsText.isBlank()) {
            return Set.of();
        }
        return Arrays.stream(adUnitIdsText.split(AD_UNIT_ID_DELIMITER))
            .map(String::trim)
            .filter(adUnitId -> !adUnitId.isEmpty())
            .collect(Collectors.toUnmodifiableSet());
    }

    /** 표식 형식 확인, 비었거나 형식 밖이면 null */
    private static String toValidRewardNonceOrNull(String rewardNonce) {
        return rewardNonce != null && REWARD_NONCE_PATTERN.matcher(rewardNonce).matches() ? rewardNonce : null;
    }

    /** 로그용 값 정리 (영문·숫자·/-_ 외 > ?, 80자 제한) */
    private static String sanitizeForLog(String value) {
        if (value == null) {
            return "null";
        }
        String limitedValue = value.length() > LOG_VALUE_MAX_LENGTH ? value.substring(0, LOG_VALUE_MAX_LENGTH) : value;
        return limitedValue.replaceAll("[^0-9A-Za-z/_-]", "?");
    }
}
