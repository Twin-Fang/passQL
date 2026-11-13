package com.coldredrice.passql.lockscreen

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * 잠금화면 전용 Flutter 엔진: 서비스 시작 때 미리 데워 캐시 > 활동이 재사용 (콜드 스타트 지연 방지)
 * Dart 진입점 lockScreenMain, 채널 passql/lock_screen 은 엔진 생성 때 한 번 등록
 */
object LockScreenEngine {
    // FlutterEngineCache 키 (LockScreenActivity.getCachedEngineId 가 같은 값을 씀)
    const val ENGINE_ID = "passql_lock_screen_engine"
    private const val DART_ENTRYPOINT = "lockScreenMain"
    // 진입점이 main.dart 가 아닌 파일에 있어 라이브러리 경로를 함께 지정 (pubspec name 기준)
    private const val DART_ENTRYPOINT_LIBRARY = "package:passql_app/lock_screen_main.dart"

    private var channel: MethodChannel? = null

    // 표시 요청이 Dart 준비 전에 왔는지 (Dart 시작 시 consumePendingShow 로 꺼내 첫 문제를 받음)
    @Volatile
    private var isShowPending = false

    fun consumePendingShow(): Boolean {
        val wasPending = isShowPending
        isShowPending = false
        return wasPending
    }

    /** 캐시된 엔진, 없으면 생성 > Dart 실행 > 캐시 (메인 스레드에서만 호출) */
    fun obtain(context: Context): FlutterEngine {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { return it }
        val applicationContext = context.applicationContext
        val engine = FlutterEngine(applicationContext)
        val methodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, LockScreenChannel.CHANNEL_NAME)
        methodChannel.setMethodCallHandler(LockScreenChannel(applicationContext) { LockScreenActivity.current })
        channel = methodChannel
        // 진입점 실행은 채널 등록 뒤 (Dart 시작 직후 호출이 빠지지 않게)
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(applicationContext)
        loader.ensureInitializationComplete(applicationContext, null)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(loader.findAppBundlePath(), DART_ENTRYPOINT_LIBRARY, DART_ENTRYPOINT),
        )
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    /** 잠금화면이 새로 보임 > Dart 가 화면을 처음 상태로 되돌리고 문제를 받음 */
    fun notifyShown() {
        isShowPending = true
        channel?.invokeMethod(LockScreenChannel.METHOD_ON_SHOWN, null)
    }

    /** 기능 끔 > 엔진 해제 (메모리 반환) */
    fun release() {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.destroy()
        FlutterEngineCache.getInstance().remove(ENGINE_ID)
        channel = null
    }
}
