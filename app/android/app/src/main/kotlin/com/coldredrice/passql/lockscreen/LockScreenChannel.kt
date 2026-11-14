package com.coldredrice.passql.lockscreen

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 채널 passql/lock_screen 처리 (앱 엔진·잠금화면 엔진 공통): 권한 조회·설정 열기, 켜기·끄기·설정, 상태 알림, 잠금화면 닫기·해제
 * [activityProvider]: 설정 화면을 띄우거나 닫을 활동 (앱 엔진 = MainActivity, 잠금 엔진 = 지금 잠금화면)
 */
class LockScreenChannel(
    private val context: Context,
    private val activityProvider: () -> Activity?,
) : MethodChannel.MethodCallHandler {
    private val preferences = LockScreenPreferences(context)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPermissionStatus" -> result.success(LockScreenPermissions.toStatusMap(context))
            "openOverlaySettings" -> {
                openOverlaySettings()
                result.success(null)
            }
            "openNotificationSettings" -> {
                openSettings(notificationSettingsIntent())
                result.success(null)
            }
            // Play 정책: 직접 요청 다이얼로그(REQUEST_IGNORE_BATTERY_OPTIMIZATIONS) 대신 목록 화면
            "openBatteryOptimizationSettings" -> {
                openSettings(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                result.success(null)
            }
            "openSamsungPowerSettings" -> {
                openSamsungPowerSettings()
                result.success(null)
            }
            "enable" -> result.success(enable(call))
            "disable" -> {
                preferences.isEnabled = false
                LockScreenService.stop(context)
                result.success(null)
            }
            "updateSettings" -> {
                applySettings(call)
                result.success(null)
            }
            "getSettings" -> result.success(
                mapOf(
                    "isEnabled" to preferences.isEnabled,
                    "intervalMinutes" to preferences.intervalMinutes,
                    "isExecutableExcluded" to preferences.isExecutableExcluded,
                    "isFreshChoiceMode" to preferences.isFreshChoiceMode,
                    // 쉬기 끝 시각 (epoch 밀리초, 쉬지 않으면 0)
                    "pauseUntilMillis" to activePauseUntilMillis(),
                ),
            )
            "markExhaustedToday" -> {
                preferences.exhaustedDate = LockScreenPreferences.today()
                result.success(null)
            }
            "updateStatus" -> {
                updateStatus(call)
                result.success(null)
            }
            "consumePendingShow" -> result.success(LockScreenEngine.consumePendingShow())
            "takePendingRoute" -> result.success(LockScreenRoutes.takePendingRoute())
            "dismiss" -> {
                activityProvider()?.finish()
                result.success(null)
            }
            "unlock" -> {
                (activityProvider() as? LockScreenActivity)?.unlockAndOpen(null)
                result.success(null)
            }
            "unlockAndOpen" -> {
                (activityProvider() as? LockScreenActivity)?.unlockAndOpen(call.argument<String>("route"))
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** 켜기: 설정 저장 > 필수 권한 3개 확인(없으면 false) > 쉬기 해제 > 서비스 시작(알림 즉시 갱신) */
    private fun enable(call: MethodCall): Boolean {
        applySettings(call)
        if (!LockScreenPermissions.hasRequiredPermissions(context)) return false
        preferences.isEnabled = true
        preferences.pauseUntilMillis = 0L
        LockScreenService.start(context)
        return true
    }

    // 지난 쉬기 끝 시각은 0 (Dart 가 쉬는 중으로 보지 않게)
    private fun activePauseUntilMillis(): Long {
        val pauseUntilMillis = preferences.pauseUntilMillis
        return if (pauseUntilMillis > System.currentTimeMillis()) pauseUntilMillis else 0L
    }

    /**
     * 다른 앱 위에 표시: passQL 전용 화면 > 권한 목록 화면 > 앱 상세 설정 순서로 시도
     * Android 11+ 는 공개 액션의 package: URI 를 무시하고 목록을 열어서, 앱별 화면 액션을 먼저 시도
     */
    private fun openOverlaySettings() {
        val appOverlayIntent = Intent(ACTION_MANAGE_APP_OVERLAY_PERMISSION, packageUri())
        if (tryStart(appOverlayIntent)) return
        openSettings(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, packageUri()))
    }

    private fun applySettings(call: MethodCall) {
        call.argument<Int>("intervalMinutes")?.let { preferences.intervalMinutes = it }
        call.argument<Boolean>("isExecutableExcluded")?.let { preferences.isExecutableExcluded = it }
        call.argument<Boolean>("isFreshChoiceMode")?.let { preferences.isFreshChoiceMode = it }
    }

    /** 알림 본문 상태 저장 > 켜져 있으면 알림 갱신. 크레딧이 생겼거나 프로면 오늘 소진 표시 해제 */
    private fun updateStatus(call: MethodCall) {
        val remainingCredits = call.argument<Int>("remainingCredits")
        val isPro = call.argument<Boolean>("isPro") == true
        preferences.saveStatus(
            solvedTodayCount = call.argument<Int>("solvedTodayCount") ?: 0,
            remainingCredits = remainingCredits,
            isPro = isPro,
        )
        if (isPro || (remainingCredits ?: 0) > 0) preferences.exhaustedDate = null
        if (preferences.isEnabled && LockScreenService.isRunning) {
            LockScreenNotification.repost(context, preferences)
        }
    }

    private fun packageUri(): Uri = Uri.parse("package:${context.packageName}")

    private fun notificationSettingsIntent(): Intent =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri())
        }

    /** 삼성 배터리 화면 시도 (기기 관리 앱 이름이 버전마다 다름) > 모두 실패면 앱 상세 설정 */
    private fun openSamsungPowerSettings() {
        val candidates = listOf(
            ComponentName("com.samsung.android.lool", "com.samsung.android.sm.battery.ui.BatteryActivity"),
            ComponentName("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity"),
            ComponentName("com.samsung.android.sm", "com.samsung.android.sm.ui.battery.BatteryActivity"),
        )
        for (component in candidates) {
            if (tryStart(Intent().setComponent(component))) return
        }
        openSettings(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri()))
    }

    private fun openSettings(intent: Intent) {
        if (!tryStart(intent)) tryStart(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri()))
    }

    /** 활동이 있으면 그 위에, 없으면 새 태스크로 시작 (없는 화면이면 false) */
    private fun tryStart(intent: Intent): Boolean {
        val activity = activityProvider()
        return try {
            if (activity != null) {
                activity.startActivity(intent)
            } else {
                context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            }
            true
        } catch (_: ActivityNotFoundException) {
            false
        } catch (_: SecurityException) {
            false
        }
    }

    companion object {
        const val CHANNEL_NAME = "passql/lock_screen"
        // 네이티브 > Dart 호출: 잠금화면 표시(잠금 엔진), 경로 열기(앱 엔진)
        const val METHOD_ON_SHOWN = "onShown"
        const val METHOD_OPEN_ROUTE = "openRoute"

        // 설정 앱의 앱별 "다른 앱 위에 표시" 화면 (Settings.ACTION_MANAGE_APP_OVERLAY_PERMISSION, 공개 SDK 밖 상수)
        private const val ACTION_MANAGE_APP_OVERLAY_PERMISSION =
            "android.settings.MANAGE_APP_OVERLAY_PERMISSION"
    }
}
