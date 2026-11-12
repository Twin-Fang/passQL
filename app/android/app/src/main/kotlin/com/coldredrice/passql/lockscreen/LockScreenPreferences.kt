package com.coldredrice.passql.lockscreen

import android.content.Context
import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * 잠금화면 문제 설정 원본 (네이티브 SharedPreferences): 켜짐·간격·유형, 표시 기록, 쉬기, 알림 상태
 * Dart 는 채널로만 읽고 씀 (두 엔진·서비스가 같은 값을 보게)
 */
class LockScreenPreferences(context: Context) {
    private val preferences: SharedPreferences =
        context.applicationContext.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

    var isEnabled: Boolean
        get() = preferences.getBoolean(KEY_IS_ENABLED, false)
        set(value) = preferences.edit().putBoolean(KEY_IS_ENABLED, value).apply()

    // 마지막 표시 후 최소 간격 (분, 0 = 화면 켤 때마다)
    var intervalMinutes: Int
        get() = preferences.getInt(KEY_INTERVAL_MINUTES, DEFAULT_INTERVAL_MINUTES)
        set(value) = preferences.edit().putInt(KEY_INTERVAL_MINUTES, value).apply()

    // true = 객관식만 (실행형 SQL 제외)
    var isExecutableExcluded: Boolean
        get() = preferences.getBoolean(KEY_IS_EXECUTABLE_EXCLUDED, false)
        set(value) = preferences.edit().putBoolean(KEY_IS_EXECUTABLE_EXCLUDED, value).apply()

    // 선택지 방식: true = AI로 새로 만들기(SSE 대기), false = 기본(준비된 세트 재사용). 앱 보기 방식 설정과 별개
    var isFreshChoiceMode: Boolean
        get() = preferences.getBoolean(KEY_IS_FRESH_CHOICE_MODE, false)
        set(value) = preferences.edit().putBoolean(KEY_IS_FRESH_CHOICE_MODE, value).apply()

    var lastShownAtMillis: Long
        get() = preferences.getLong(KEY_LAST_SHOWN_AT, 0L)
        set(value) = preferences.edit().putLong(KEY_LAST_SHOWN_AT, value).apply()

    // 크레딧 소진 화면을 보인 날 (yyyy-MM-dd, 그날은 다시 안 띄움)
    var exhaustedDate: String?
        get() = preferences.getString(KEY_EXHAUSTED_DATE, null)
        set(value) = preferences.edit().putString(KEY_EXHAUSTED_DATE, value).apply()

    // 알림 "1시간 쉬기" 끝나는 시각 (epoch 밀리초, 0 = 쉬지 않음)
    var pauseUntilMillis: Long
        get() = preferences.getLong(KEY_PAUSE_UNTIL, 0L)
        set(value) = preferences.edit().putLong(KEY_PAUSE_UNTIL, value).apply()

    /** 알림 본문용 상태 저장 (Dart updateStatus): 날짜 함께 저장 > 날짜 바뀌면 0문제로 봄 */
    fun saveStatus(solvedTodayCount: Int, remainingCredits: Int?, isPro: Boolean) {
        preferences.edit()
            .putInt(KEY_SOLVED_TODAY_COUNT, solvedTodayCount)
            .putInt(KEY_REMAINING_CREDITS, remainingCredits ?: UNKNOWN_CREDITS)
            .putBoolean(KEY_IS_PRO, isPro)
            .putString(KEY_STATUS_DATE, today())
            .apply()
    }

    /** 오늘 푼 문제 수 (저장 날짜가 오늘이 아니면 0) */
    val solvedTodayCount: Int
        get() = if (preferences.getString(KEY_STATUS_DATE, null) == today()) {
            preferences.getInt(KEY_SOLVED_TODAY_COUNT, 0)
        } else {
            0
        }

    /** 남은 크레딧 (모름·프로·날짜 바뀜이면 null) */
    val remainingCredits: Int?
        get() {
            if (preferences.getString(KEY_STATUS_DATE, null) != today()) return null
            val value = preferences.getInt(KEY_REMAINING_CREDITS, UNKNOWN_CREDITS)
            return if (value == UNKNOWN_CREDITS) null else value
        }

    val isPro: Boolean
        get() = preferences.getBoolean(KEY_IS_PRO, false)

    val isExhaustedToday: Boolean
        get() = exhaustedDate == today()

    companion object {
        private const val FILE_NAME = "passql_lock_screen"
        private const val KEY_IS_ENABLED = "is_enabled"
        private const val KEY_INTERVAL_MINUTES = "interval_minutes"
        private const val KEY_IS_EXECUTABLE_EXCLUDED = "is_executable_excluded"
        private const val KEY_IS_FRESH_CHOICE_MODE = "is_fresh_choice_mode"
        private const val KEY_LAST_SHOWN_AT = "last_shown_at_ms"
        private const val KEY_EXHAUSTED_DATE = "exhausted_date"
        private const val KEY_PAUSE_UNTIL = "pause_until_ms"
        private const val KEY_SOLVED_TODAY_COUNT = "solved_today_count"
        private const val KEY_REMAINING_CREDITS = "remaining_credits"
        private const val KEY_IS_PRO = "is_pro"
        private const val KEY_STATUS_DATE = "status_date"

        // 서버 기본값과 같은 값 (Dart 가 enable 때 서버값으로 덮음)
        private const val DEFAULT_INTERVAL_MINUTES = 30
        private const val UNKNOWN_CREDITS = -1

        /** 기기 날짜 (yyyy-MM-dd) */
        fun today(): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
    }
}
