import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';

/// 알림 권한 안내 기록 (기기 설정이라 일반 저장소, 앱 삭제 시 초기화)
class PushPermissionPromptStore {
  const PushPermissionPromptStore();

  // "나중에" 뒤 다시 묻지 않는 기간 (7일)
  static const Duration promptDeferDuration = Duration(days: 7);

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
}
