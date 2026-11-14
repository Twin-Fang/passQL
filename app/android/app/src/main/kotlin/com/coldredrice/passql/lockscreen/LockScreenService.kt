package com.coldredrice.passql.lockscreen

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper

/**
 * 잠금화면 문제 포그라운드 서비스: 상태 알림 유지 > 화면 꺼짐 감지 > 잠금화면 미리 띄움 (켤 때 바로 보임, 엔진은 시작 때 데움)
 * 띄우지 않는 조건 5개: 꺼짐, 쉬는 중, 오늘 크레딧 소진 화면 봄, 통화 중, 간격 안 지남
 */
class LockScreenService : Service() {
    private lateinit var preferences: LockScreenPreferences
    private val mainHandler = Handler(Looper.getMainLooper())

    // 쉬기 끝나면 알림 본문 원복
    private val restoreAfterPause = Runnable { LockScreenNotification.repost(this, preferences) }

    private val screenOffReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_SCREEN_OFF) onScreenOff()
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        preferences = LockScreenPreferences(this)
        startInForeground()
        registerReceiver(screenOffReceiver, IntentFilter(Intent.ACTION_SCREEN_OFF))
        isRunning = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 꺼졌거나 필수 권한이 빠졌으면 멈춤 (Dart 가 막지만 재부팅·시스템 재시작 경로 방어)
        if (!preferences.isEnabled || !LockScreenPermissions.hasRequiredPermissions(this)) {
            stopSelf()
            return START_NOT_STICKY
        }
        // 엔진 미리 데우기 (첫 표시 지연 방지, 이미 있으면 재사용)
        LockScreenEngine.obtain(this)
        when (intent?.action) {
            ACTION_PAUSE_ONE_HOUR -> pauseOneHour()
            ACTION_RESUME -> resume()
            // 켜기·재시작: 쉬기 상태에 맞춰 알림 즉시 갱신 + 남은 쉬기 끝나면 원복 예약
            else -> {
                LockScreenNotification.repost(this, preferences)
                scheduleRestoreAfterPause()
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        mainHandler.removeCallbacks(restoreAfterPause)
        runCatching { unregisterReceiver(screenOffReceiver) }
        super.onDestroy()
    }

    /** 상태 알림과 함께 포그라운드 시작 (Android 14+ 는 specialUse 유형 명시) */
    private fun startInForeground() {
        val notification = LockScreenNotification.build(this, preferences)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                LockScreenNotification.NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(LockScreenNotification.NOTIFICATION_ID, notification)
        }
    }

    /** 1시간 쉬기: 끝 시각 저장 > 알림 "HH:mm까지 쉬는 중"·다시 켜기 > 끝나면 원복 */
    private fun pauseOneHour() {
        preferences.pauseUntilMillis = System.currentTimeMillis() + PAUSE_MILLIS
        LockScreenNotification.repost(this, preferences)
        scheduleRestoreAfterPause()
    }

    /** 다시 켜기: 쉬기 해제 > 원복 예약 취소 > 알림 즉시 원복 */
    private fun resume() {
        preferences.pauseUntilMillis = 0L
        mainHandler.removeCallbacks(restoreAfterPause)
        LockScreenNotification.repost(this, preferences)
    }

    // 남은 쉬기 시간 뒤 알림 원복 (쉬지 않으면 예약 없음)
    private fun scheduleRestoreAfterPause() {
        mainHandler.removeCallbacks(restoreAfterPause)
        val remainingMillis = preferences.pauseUntilMillis - System.currentTimeMillis()
        if (remainingMillis > 0) mainHandler.postDelayed(restoreAfterPause, remainingMillis)
    }

    /** 화면 꺼짐: 알림 재게시(밀어 없앴어도 복구) > 조건 확인 > 잠금화면 시작 */
    private fun onScreenOff() {
        LockScreenNotification.repost(this, preferences)
        if (!shouldShowLockScreen()) return
        preferences.lastShownAtMillis = System.currentTimeMillis()
        val intent = Intent(this, LockScreenActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_ANIMATION)
        runCatching { startActivity(intent) }
    }

    private fun shouldShowLockScreen(): Boolean {
        if (!preferences.isEnabled) return false
        val now = System.currentTimeMillis()
        if (preferences.pauseUntilMillis > now) return false
        if (preferences.isExhaustedToday) return false
        if (isInCall()) return false
        val intervalMillis = preferences.intervalMinutes * MINUTE_MILLIS
        return now - preferences.lastShownAtMillis >= intervalMillis
    }

    // 통화 판정: 오디오 모드 (전화 상태 권한 없이)
    private fun isInCall(): Boolean {
        val audioManager = getSystemService(AudioManager::class.java)
        return audioManager.mode == AudioManager.MODE_IN_CALL ||
            audioManager.mode == AudioManager.MODE_IN_COMMUNICATION
    }

    companion object {
        const val ACTION_PAUSE_ONE_HOUR = "com.coldredrice.passql.lockscreen.PAUSE_ONE_HOUR"
        const val ACTION_RESUME = "com.coldredrice.passql.lockscreen.RESUME"
        private const val MINUTE_MILLIS = 60_000L
        private const val PAUSE_MILLIS = 60 * MINUTE_MILLIS

        @Volatile
        var isRunning = false
            private set

        /** 서비스 시작 (필수 권한·켜짐은 onStartCommand 가 다시 확인) */
        fun start(context: Context) {
            val intent = Intent(context, LockScreenService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        /** 서비스 멈춤 + 엔진 해제 */
        fun stop(context: Context) {
            context.stopService(Intent(context, LockScreenService::class.java))
            LockScreenEngine.release()
        }
    }
}
