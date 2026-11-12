package com.coldredrice.passql.lockscreen

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * 재부팅 > 켜져 있고 필수 권한이 있으면 잠금화면 서비스 다시 시작
 */
class LockScreenBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val isEnabled = LockScreenPreferences(context).isEnabled
        if (!isEnabled || !LockScreenPermissions.hasRequiredPermissions(context)) return
        runCatching { LockScreenService.start(context) }
    }
}
