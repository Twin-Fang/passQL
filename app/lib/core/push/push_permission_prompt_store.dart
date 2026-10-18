import 'package:flutter/foundation.dart';

import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';

/// 알림 권한 안내 기록 (기기 설정이라 일반 저장소, 앱 삭제 시 초기화)
/// 안내 시점 조건 2개: 의미 있는 순간(학습 결과를 본 뒤 또는 두 번째 실행) + "나중에" 후 7일 경과
class PushPermissionPromptStore {
  const PushPermissionPromptStore();

  // "나중에" 뒤 다시 묻지 않는 기간 (7일)
  static const Duration promptDeferDuration = Duration(days: 7);

  // 이번 프로세스가 두 번째 이후 실행인지 (첫 조회 때 확정, 같은 실행 중 재로그인에도 유지)
  static bool? _isReturningLaunchOfProcess;

  /// 지금 안내 시트를 띄워도 되는지 ("나중에" 후 7일이 지났거나 기록 없음)
  Future<bool> canPromptNow({DateTime? now}) async {
    final deferredAtMilliseconds = await DevicePreferences.readInt(
      StorageKeys.pushPermissionPromptDeferredAt,
    );
    if (deferredAtMilliseconds == null) return true;
    final deferredAt = DateTime.fromMillisecondsSinceEpoch(
      deferredAtMilliseconds,
    );
    return (now ?? DateTime.now()).difference(deferredAt) >=
        promptDeferDuration;
  }

  /// "나중에" 선택 기록 (7일간 다시 묻지 않음)
  Future<void> deferPrompt({DateTime? now}) async => DevicePreferences.writeInt(
    StorageKeys.pushPermissionPromptDeferredAt,
    (now ?? DateTime.now()).millisecondsSinceEpoch,
  );

  /// 풀이 결과 화면 진입 기록 (오늘의 세트·챕터 결과)
  Future<void> markStudyResultSeen() async => DevicePreferences.writeBool(
    StorageKeys.pushPermissionPromptStudyResultSeen,
    true,
  );

  /// 안내하기 좋은 순간인지: 학습 결과를 본 적 있음 또는 두 번째 이후 실행
  Future<bool> isMeaningfulMoment({DateTime? now}) async {
    final hasSeenStudyResult = await DevicePreferences.readBool(
      StorageKeys.pushPermissionPromptStudyResultSeen,
    );
    if (hasSeenStudyResult ?? false) return true;
    return _isReturningLaunchOfProcess ??= await _recordFirstShellVisit(
      now ?? DateTime.now(),
    );
  }

  /// 첫 방문 기록이 이미 있으면 true(두 번째 이후 실행), 없으면 지금 기록하고 false
  static Future<bool> _recordFirstShellVisit(DateTime now) async {
    final firstShellVisitAt = await DevicePreferences.readInt(
      StorageKeys.pushPermissionPromptFirstShellVisitAt,
    );
    if (firstShellVisitAt != null) return true;
    await DevicePreferences.writeInt(
      StorageKeys.pushPermissionPromptFirstShellVisitAt,
      now.millisecondsSinceEpoch,
    );
    return false;
  }

  /// 테스트 간 프로세스 캐시 초기화
  @visibleForTesting
  static void resetProcessCacheForTest() => _isReturningLaunchOfProcess = null;
}
