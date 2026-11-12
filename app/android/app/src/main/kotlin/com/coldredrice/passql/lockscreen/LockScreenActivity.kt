package com.coldredrice.passql.lockscreen

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.coldredrice.passql.MainActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.lang.ref.WeakReference

/**
 * 잠금화면 위 문제 화면: 잠금 위 표시·화면 켜기 > 캐시 엔진(lockScreenMain) 붙이기 > 보일 때마다 Dart 에 알림
 * 해제는 KeyguardManager 로 잠금을 풀고(사용자 인증) 나서 앱 열기 (Play 정책: 광고·결제는 잠금 해제 후 앱에서)
 */
class LockScreenActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        showOverKeyguard()
        super.onCreate(savedInstanceState)
        currentActivityReference = WeakReference(this)
        onShown()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        onShown()
    }

    override fun onDestroy() {
        if (current === this) currentActivityReference = null
        super.onDestroy()
    }

    // 엔진은 서비스와 함께 사는 캐시 엔진 (활동이 닫혀도 유지)
    override fun provideFlutterEngine(context: Context): FlutterEngine = LockScreenEngine.obtain(context)

    override fun shouldDestroyEngineWithHost(): Boolean = false

    /** 표시 기록(알림 "지금 한 문제" 경로 포함) > Dart 에 새로 보임 알림 */
    private fun onShown() {
        LockScreenPreferences(this).lastShownAtMillis = System.currentTimeMillis()
        LockScreenEngine.notifyShown()
    }

    @Suppress("DEPRECATION")
    private fun showOverKeyguard() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }
    }

    /** 잠금 해제 요청 > 성공하면 [route] 로 앱 열기(null 이면 해제만) > 닫기. 잠겨 있지 않으면 바로 */
    fun unlockAndOpen(route: String?) {
        val keyguardManager = getSystemService(KeyguardManager::class.java)
        if (!keyguardManager.isKeyguardLocked) {
            openAppAndFinish(route)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            keyguardManager.requestDismissKeyguard(this, object : KeyguardManager.KeyguardDismissCallback() {
                override fun onDismissSucceeded() = openAppAndFinish(route)
            })
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
            openAppAndFinish(route)
        }
    }

    private fun openAppAndFinish(route: String?) {
        if (route != null) {
            val intent = Intent(this, MainActivity::class.java)
                .putExtra(LockScreenRoutes.EXTRA_ROUTE, route)
                .addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
            startActivity(intent)
        }
        finish()
    }

    companion object {
        private var currentActivityReference: WeakReference<LockScreenActivity>? = null

        /** 지금 떠 있는 잠금화면 (채널 dismiss·unlock 대상) */
        val current: Activity?
            get() = currentActivityReference?.get()
    }
}
