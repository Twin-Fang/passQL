package com.coldredrice.passql.lockscreen

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import com.coldredrice.passql.MainActivity
import com.coldredrice.passql.R
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * 잠금화면 상태 알림: 조용한 채널 > 제목·본문(쉬는 중 > 오늘 0문제 > 푼 수·크레딧) > 탭(설정) + 액션 2개
 * 액션: 지금 한 문제(잠금화면 바로 표시, 간격 무시), 1시간 쉬기 또는 쉬는 중이면 다시 켜기(서비스)
 */
object LockScreenNotification {
    const val NOTIFICATION_ID = 9901
    private const val CHANNEL_ID = "passql_lock_screen"

    // PendingIntent 요청 코드 (같은 코드끼리 덮어쓰므로 용도별로 다르게)
    private const val REQUEST_OPEN_SETTINGS = 1
    private const val REQUEST_SHOW_NOW = 2
    private const val REQUEST_PAUSE = 3
    private const val REQUEST_RESUME = 4

    private const val PENDING_INTENT_FLAGS =
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT

    /** 채널 생성 (IMPORTANCE_LOW: 소리·진동 없음, 이미 있으면 무시됨) */
    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            context.getString(R.string.lock_screen_channel_name),
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            setSound(null, null)
            enableVibration(false)
            setShowBadge(false)
        }
        context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    fun build(context: Context, preferences: LockScreenPreferences): Notification {
        createChannel(context)
        return newBuilder(context)
            .setSmallIcon(R.drawable.ic_stat_passql)
            .setContentTitle(context.getString(R.string.lock_screen_notification_title))
            .setContentText(contentTextOf(context, preferences))
            .setOngoing(true)
            .setShowWhen(false)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .setContentIntent(openSettingsIntent(context))
            .addAction(
                Notification.Action.Builder(
                    null as Icon?,
                    context.getString(R.string.lock_screen_action_show_now),
                    showNowIntent(context),
                ).build(),
            )
            .addAction(pauseOrResumeAction(context, preferences))
            .build()
    }

    /** 쉬는 중이면 다시 켜기(쉬기 해제), 아니면 1시간 쉬기 */
    private fun pauseOrResumeAction(context: Context, preferences: LockScreenPreferences): Notification.Action {
        val isPaused = preferences.pauseUntilMillis > System.currentTimeMillis()
        val (titleResource, pendingIntent) = if (isPaused) {
            R.string.lock_screen_action_resume to serviceActionIntent(
                context,
                REQUEST_RESUME,
                LockScreenService.ACTION_RESUME,
            )
        } else {
            R.string.lock_screen_action_pause to serviceActionIntent(
                context,
                REQUEST_PAUSE,
                LockScreenService.ACTION_PAUSE_ONE_HOUR,
            )
        }
        return Notification.Action.Builder(null as Icon?, context.getString(titleResource), pendingIntent)
            .build()
    }

    // Android 8 미만은 채널 없는 생성자 (minSdk 24)
    @Suppress("DEPRECATION")
    private fun newBuilder(context: Context): Notification.Builder =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            Notification.Builder(context).setPriority(Notification.PRIORITY_LOW)
        }

    /** 알림 다시 게시 (사용자가 밀어 없앴어도 다시 보이게, 같은 ID 라 중복 없음) */
    fun repost(context: Context, preferences: LockScreenPreferences) {
        context.getSystemService(NotificationManager::class.java)
            .notify(NOTIFICATION_ID, build(context, preferences))
    }

    /** 본문: 쉬는 중 > 오늘 0문제 > 프로 푼 수 > 무료 푼 수·크레딧 */
    private fun contentTextOf(context: Context, preferences: LockScreenPreferences): String {
        val pauseUntilMillis = preferences.pauseUntilMillis
        if (pauseUntilMillis > System.currentTimeMillis()) {
            val endTime = SimpleDateFormat("HH:mm", Locale.KOREA).format(Date(pauseUntilMillis))
            return context.getString(R.string.lock_screen_notification_paused, endTime)
        }
        val solvedCount = preferences.solvedTodayCount
        if (solvedCount == 0) return context.getString(R.string.lock_screen_notification_idle)
        val remainingCredits = preferences.remainingCredits
        return if (preferences.isPro || remainingCredits == null) {
            context.getString(R.string.lock_screen_notification_solved, solvedCount)
        } else {
            context.getString(R.string.lock_screen_notification_solved_free, solvedCount, remainingCredits)
        }
    }

    private fun openSettingsIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .putExtra(LockScreenRoutes.EXTRA_ROUTE, LockScreenRoutes.ROUTE_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(context, REQUEST_OPEN_SETTINGS, intent, PENDING_INTENT_FLAGS)
    }

    // 활동을 바로 여는 PendingIntent (Android 12+ 알림 트램펄린 금지: 서비스 거쳐 startActivity 불가)
    private fun showNowIntent(context: Context): PendingIntent {
        val intent = Intent(context, LockScreenActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return PendingIntent.getActivity(context, REQUEST_SHOW_NOW, intent, PENDING_INTENT_FLAGS)
    }

    private fun serviceActionIntent(context: Context, requestCode: Int, action: String): PendingIntent {
        val intent = Intent(context, LockScreenService::class.java).setAction(action)
        return PendingIntent.getService(context, requestCode, intent, PENDING_INTENT_FLAGS)
    }
}
