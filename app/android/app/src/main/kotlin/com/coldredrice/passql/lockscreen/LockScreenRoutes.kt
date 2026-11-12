package com.coldredrice.passql.lockscreen

/**
 * 잠금화면 > 앱 이동 경로: MainActivity intent extra 키와 값 (Dart lock_screen_bridge.dart 와 같은 값)
 * 값 4종: credit_reward, pass_sheet, question:<uuid>, settings_lock_screen
 */
object LockScreenRoutes {
    const val EXTRA_ROUTE = "passql_lock_screen_route"
    const val ROUTE_SETTINGS = "settings_lock_screen"

    // 앱 엔진이 아직 안 받은 경로 (Dart takePendingRoute 가 꺼내 감, 꺼내면 비움)
    @Volatile
    var pendingRoute: String? = null

    fun takePendingRoute(): String? {
        val route = pendingRoute
        pendingRoute = null
        return route
    }
}
