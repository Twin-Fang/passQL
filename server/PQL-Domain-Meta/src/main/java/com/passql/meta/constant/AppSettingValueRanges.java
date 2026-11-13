package com.passql.meta.constant;

import java.math.BigDecimal;
import java.util.Map;
import java.util.Optional;

/**
 * app_setting 키별 허용 범위 단일 원본: 관리자 저장 검증, 설정 표 입력 min·max
 * 목록에 없는 키는 검증 없음 (value_type 형식 검사만), 코드가 읽는 숫자 키만 정의
 */
public final class AppSettingValueRanges {

    // 알림 보관 기간 (일, 알림 설정 화면과 공통)
    public static final int NOTIFICATION_RETENTION_DAYS_MINIMUM = 7;
    public static final int NOTIFICATION_RETENTION_DAYS_MAXIMUM = 365;
    // 잠금화면 기본 표시 간격 (분, 0 은 화면 켤 때마다, 앱 운영 화면 요청 검증과 공통)
    public static final int LOCKSCREEN_INTERVAL_MINUTES_MINIMUM = 0;
    public static final int LOCKSCREEN_INTERVAL_MINUTES_MAXIMUM = 1440;
    // 하루 (분, 집계 구간·재발송 대기 상한)
    private static final int ONE_DAY_MINUTES = 1440;

    private static final Map<String, AppSettingValueRange> RANGE_BY_KEY = Map.ofEntries(
            // 샌드박스 슬롯 수: 0 이면 Semaphore 가 전부 막음, 슬롯마다 임시 DB 1개라 100 상한 (기본 30)
            Map.entry(AppSettingKeys.SANDBOX_POOL_CONCURRENCY, AppSettingValueRange.between(1, 100)),
            // 슬롯 대기 (초): 0 이면 즉시 실패, 요청 스레드 점유 5분 상한 (기본 60)
            Map.entry(AppSettingKeys.SANDBOX_POOL_WAIT_SECONDS, AppSettingValueRange.between(1, 300)),
            // SQL 입력 길이 (문자): 정답 SQL 도 막히지 않을 하한, 2만 자 상한 (기본 2000)
            Map.entry(AppSettingKeys.SANDBOX_SQL_MAX_LENGTH, AppSettingValueRange.between(100, 20000)),
            // AI 월 예산 (USD): 0 은 예산 알림 끔 (MonitorAlertService), 오타 방지 상한 (기본 10)
            Map.entry(AppSettingKeys.AI_MONTHLY_BUDGET_USD, AppSettingValueRange.between(0, 10000)),
            // 스토어 수수료율·부가세율 (%): PayoutSettings 요청 검증과 같은 0~100
            Map.entry(AppSettingKeys.BILLING_FEE_RATE_PERCENT_PLAY, AppSettingValueRange.between(0, 100)),
            Map.entry(AppSettingKeys.BILLING_FEE_RATE_PERCENT_APP_STORE, AppSettingValueRange.between(0, 100)),
            Map.entry(AppSettingKeys.BILLING_KRW_VAT_RATE_PERCENT, AppSettingValueRange.between(0, 100)),
            Map.entry(AppSettingKeys.NOTIFICATION_RETENTION_DAYS, AppSettingValueRange.between(
                    NOTIFICATION_RETENTION_DAYS_MINIMUM, NOTIFICATION_RETENTION_DAYS_MAXIMUM)),
            // 무료 개념 단원 수: 0 은 전부 프로, 단원 수보다 크면 전부 무료라 100 상한 (기본 2)
            Map.entry(AppSettingKeys.CONCEPT_FREE_TOPIC_COUNT, AppSettingValueRange.between(0, 100)),
            Map.entry(AppSettingKeys.LOCKSCREEN_DEFAULT_INTERVAL_MINUTES, AppSettingValueRange.between(
                    LOCKSCREEN_INTERVAL_MINUTES_MINIMUM, LOCKSCREEN_INTERVAL_MINUTES_MAXIMUM)),
            // 장애 알림 (기본 10분, 10건, 50%, 100%, 60분)
            Map.entry(AppSettingKeys.MONITOR_ALERT_WINDOW_MINUTES, AppSettingValueRange.between(1, ONE_DAY_MINUTES)),
            Map.entry(AppSettingKeys.MONITOR_ALERT_SERVER_ERROR_THRESHOLD_COUNT, AppSettingValueRange.between(1, 10000)),
            Map.entry(AppSettingKeys.MONITOR_ALERT_AI_FAILURE_RATE_THRESHOLD_PERCENT, AppSettingValueRange.between(1, 100)),
            // 예산 사용률은 100% 를 넘을 수 있어 10배까지
            Map.entry(AppSettingKeys.MONITOR_ALERT_AI_BUDGET_THRESHOLD_PERCENT, AppSettingValueRange.between(1, 1000)),
            // 재발송 대기 0 이면 스케줄 주기마다 같은 알림 발송
            Map.entry(AppSettingKeys.MONITOR_ALERT_COOLDOWN_MINUTES, AppSettingValueRange.between(1, ONE_DAY_MINUTES)));

    public static Optional<AppSettingValueRange> findRange(String key) {
        return Optional.ofNullable(RANGE_BY_KEY.get(key));
    }

    /**
     * 저장 값 > 거부 사유 (범위 밖만 사유, 범위 없는 키·숫자 아닌 값은 empty — 형식은 value_type 검사 몫)
     */
    public static Optional<String> findRejectionReason(String key, String value) {
        Optional<AppSettingValueRange> range = findRange(key);
        Optional<BigDecimal> number = parseNumberOrEmpty(value);
        if (range.isEmpty() || number.isEmpty() || range.get().contains(number.get())) {
            return Optional.empty();
        }
        return Optional.of(key + " 값은 " + range.get().toMinimumText() + "~" + range.get().toMaximumText()
                + " 범위여야 합니다.");
    }

    private static Optional<BigDecimal> parseNumberOrEmpty(String value) {
        if (value == null) return Optional.empty();
        try {
            return Optional.of(new BigDecimal(value.trim()));
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }

    private AppSettingValueRanges() {
    }
}
