package com.passql.meta.constant;

/**
 * app_setting.setting_key 단일 원본 (DB 행은 Flyway 마이그레이션이 생성, AI 서버도 같은 키로 조회)
 */
public final class AppSettingKeys {

    // app_setting: Google Gemini API 키 (SECRET, 관리자만 입력, 비면 yml gemini.api-key 로 채움)
    public static final String AI_GEMINI_API_KEY = "ai.gemini_api_key";

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

    private AppSettingKeys() {
    }
}
