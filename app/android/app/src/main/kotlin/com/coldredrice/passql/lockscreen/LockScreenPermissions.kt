package com.coldredrice.passql.lockscreen

import android.Manifest
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

/**
 * 잠금화면 권한 조회: 필수 3개(다른 앱 위에 표시, 알림, 배터리 최적화 제외) + 삼성 기기 여부
 * 서비스 시작 방어·Dart 권한 단계가 같은 판정을 씀
 */
object LockScreenPermissions {
    fun canDrawOverlays(context: Context): Boolean = Settings.canDrawOverlays(context)

    fun hasNotificationPermission(context: Context): Boolean {
        val isRuntimeGranted = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        val notificationManager = context.getSystemService(NotificationManager::class.java)
        return isRuntimeGranted && notificationManager.areNotificationsEnabled()
    }

    fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        val powerManager = context.getSystemService(PowerManager::class.java)
        return powerManager.isIgnoringBatteryOptimizations(context.packageName)
    }

    fun isSamsung(): Boolean = Build.MANUFACTURER.equals("samsung", ignoreCase = true)

    /** 필수 3개 모두 켜짐 (하나라도 없으면 서비스 시작 안 함) */
    fun hasRequiredPermissions(context: Context): Boolean =
        canDrawOverlays(context) &&
            hasNotificationPermission(context) &&
            isIgnoringBatteryOptimizations(context)

    fun toStatusMap(context: Context): Map<String, Boolean> = mapOf(
        "canDrawOverlays" to canDrawOverlays(context),
        "hasNotificationPermission" to hasNotificationPermission(context),
        "isIgnoringBatteryOptimizations" to isIgnoringBatteryOptimizations(context),
        "isSamsung" to isSamsung(),
    )
}
