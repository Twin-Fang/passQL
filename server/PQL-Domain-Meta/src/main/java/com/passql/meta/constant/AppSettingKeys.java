package com.passql.meta.constant;

import java.util.Set;

/**
 * app_setting.setting_key 단일 원본 (DB 행은 Flyway 마이그레이션이 생성, AI 서버도 같은 키로 조회)
 */
public final class AppSettingKeys {

    // app_setting: Google Gemini API 키 (SECRET, 암호문 저장, 관리자 화면에서 변경, 비면 yml gemini.api-key 를 암호화해 채움)
    public static final String AI_GEMINI_API_KEY = "ai.gemini_api_key";
    // app_setting: 모델별 단가표 (JSON {"모델":{"inputUsdPerMillion":0.10,"outputUsdPerMillion":0.40}}, USD / 1M 토큰)
    public static final String AI_MODEL_PRICE_TABLE = "ai.model_price_table";
    // app_setting: AI 월 예산 (USD, 대시보드 예산 사용률 기준)
    public static final String AI_MONTHLY_BUDGET_USD = "ai.monthly_budget_usd";

    // app_setting: 샌드박스 동시 실행 슬롯 수 (개수, 기동 시 1회 읽음, 초과 요청은 대기)
    public static final String SANDBOX_POOL_CONCURRENCY = "sandbox.pool.concurrency";
    // app_setting: 샌드박스 슬롯 대기 최대 시간 (초, 초과 시 SANDBOX_SETUP_FAILED)
    public static final String SANDBOX_POOL_WAIT_SECONDS = "sandbox.pool.wait_seconds";
    // app_setting: 사용자 SQL 입력 최대 길이 (문자 수, 초과 시 TOO_LONG)
    public static final String SANDBOX_SQL_MAX_LENGTH = "sandbox.sql_max_length";

    // app_setting: Google Play 링크 (https URL, 비우면 웹 안내 숨김)
    public static final String STORE_ANDROID_URL = "store.android_url";
    // app_setting: App Store 링크 (https URL, 비우면 웹 안내 숨김)
    public static final String STORE_IOS_URL = "store.ios_url";

    // app_setting: 시험 일정 공식 공고 마지막 확인 날짜 (yyyy-MM-dd, 비면 미확인)
    public static final String EXAM_ANNOUNCEMENT_CHECKED_AT = "exam.announcement_checked_at";

    // 기동 시 1회만 읽는 키 (저장해도 서버 재시작 후 반영, 관리자 화면에 표시)
    public static final Set<String> RESTART_REQUIRED_KEYS = Set.of(SANDBOX_POOL_CONCURRENCY);

    public static boolean isRestartRequired(String key) {
        return RESTART_REQUIRED_KEYS.contains(key);
    }

    // app_setting: 앱 최소 지원 버전 (x.y.z, 미만이면 업데이트 전까지 사용 차단, 0.0.0 이면 차단 없음)
    public static final String APP_MINIMUM_VERSION_IOS = "app.minimum_version.ios";
    public static final String APP_MINIMUM_VERSION_ANDROID = "app.minimum_version.android";
    // app_setting: 앱 권장 버전 (x.y.z, 미만이면 닫을 수 있는 업데이트 안내, 0.0.0 이면 안내 없음)
    public static final String APP_RECOMMENDED_VERSION_IOS = "app.recommended_version.ios";
    public static final String APP_RECOMMENDED_VERSION_ANDROID = "app.recommended_version.android";
    // app_setting: 점검 여부 (true 점검 중, false 정상)
    public static final String APP_MAINTENANCE_ENABLED = "app.maintenance.enabled";
    // app_setting: 점검 화면 문구 (비면 앱 기본 문구)
    public static final String APP_MAINTENANCE_MESSAGE = "app.maintenance.message";

    // app_setting: 알림함 일반 알림 보관 기간 (일, 지난 알림은 매일 새벽 삭제)
    public static final String NOTIFICATION_RETENTION_DAYS = "notification.retention_days";
    // app_setting: 신고 처리 결과 자동 알림 (true 사용, false 미사용)
    public static final String NOTIFICATION_REPORT_RESOLVED_ENABLED = "notification.report_resolved.enabled";
    // app_setting: 오늘의 세트 리마인드 자동 알림 (true 사용, false 미사용, 발송은 후속 이슈)
    public static final String NOTIFICATION_DAILY_SET_REMINDER_ENABLED = "notification.daily_set_reminder.enabled";

    // app_setting: Android 결제 스위치 (true 무료/프로 제한 적용과 결제 UI 노출, false 모든 기능 허용)
    public static final String BILLING_ANDROID_ENABLED = "billing.android.enabled";
    // app_setting: 결제 미리보기 회원 UUID 목록 (쉼표 구분, 스위치 꺼짐이어도 목록 회원만 결제 켜짐 취급, 빈 값 대상 없음)
    public static final String BILLING_PREVIEW_MEMBER_UUIDS = "billing.preview_member_uuids";
    // app_setting: Play Developer API 서비스 계정 키 JSON (SECRET, 암호문 저장, 관리자 화면에서 변경, 비면 결제 확인 불가)
    public static final String BILLING_PLAY_SERVICE_ACCOUNT_JSON = "billing.play_service_account_json";

    // app_setting: 장애 알림 사용 여부 (true 사용, false 미사용, 웹훅 URL 이 비면 발송 안 함)
    public static final String MONITOR_ALERT_ENABLED = "monitor.alert.enabled";
    // app_setting: 장애 알림 Slack Incoming Webhook URL (SECRET, 암호문 저장)
    public static final String MONITOR_ALERT_SLACK_WEBHOOK_URL = "monitor.alert.slack_webhook_url";
    // app_setting: 장애 판정 집계 구간 (분)
    public static final String MONITOR_ALERT_WINDOW_MINUTES = "monitor.alert.window_minutes";
    // app_setting: 서버 오류(5xx) 알림 기준 (건, 집계 구간 합)
    public static final String MONITOR_ALERT_SERVER_ERROR_THRESHOLD_COUNT = "monitor.alert.server_error_threshold_count";
    // app_setting: AI 호출 실패율 알림 기준 (%, 집계 구간 호출 5건 이상일 때)
    public static final String MONITOR_ALERT_AI_FAILURE_RATE_THRESHOLD_PERCENT = "monitor.alert.ai_failure_rate_threshold_percent";
    // app_setting: AI 월 예산 사용률 알림 기준 (%, 달마다 1회)
    public static final String MONITOR_ALERT_AI_BUDGET_THRESHOLD_PERCENT = "monitor.alert.ai_budget_threshold_percent";
    // app_setting: 같은 종류 알림 재발송 대기 (분)
    public static final String MONITOR_ALERT_COOLDOWN_MINUTES = "monitor.alert.cooldown_minutes";

    private AppSettingKeys() {
    }
}
