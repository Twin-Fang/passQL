package com.coldredrice.passql.lockscreen

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * 재부팅·앱 업데이트 > 켜져 있고 필수 권한이 있으면 잠금화면 서비스 다시 시작
 * 업데이트 설치 때 프로세스가 종료돼 서비스도 멈춤 (두 방송 모두 백그라운드 포그라운드 서비스 시작 예외)
 */
class LockScreenBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in restartActions) return
        val isEnabled = LockScreenPreferences(context).isEnabled
        if (!isEnabled || !LockScreenPermissions.hasRequiredPermissions(context)) return
        runCatching { LockScreenService.start(context) }
    }

    private companion object {
        // AndroidManifest.xml LockScreenBootReceiver intent-filter 와 같은 목록
        val restartActions = setOf(Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED)
    }
}
