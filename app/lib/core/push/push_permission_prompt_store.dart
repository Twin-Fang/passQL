import 'package:shared_preferences/shared_preferences.dart';

/// 알림 권한을 자동으로 물어본 적 있는지 (기기 설정이라 일반 저장소, 앱 삭제 시 초기화)
class PushPermissionPromptStore {
  const PushPermissionPromptStore();

  // SharedPreferences: 자동 권한 요청 여부 (true: 이미 물어봄)
  static const String _hasPromptedKey = 'push_permission_prompted';

  Future<bool> hasPrompted() async =>
      (await SharedPreferences.getInstance()).getBool(_hasPromptedKey) ?? false;

  Future<void> markPrompted() async =>
      (await SharedPreferences.getInstance()).setBool(_hasPromptedKey, true);
}
