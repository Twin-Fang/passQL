import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';
import 'auth_session.dart';

/// 최근 로그인 제공자 기록 (#908): 로그인 성공 때 저장 > 로그인 화면 "최근 로그인" 표시
/// 계정이 아니라 기기 기록 > 로그아웃해도 유지, 탈퇴 때만 삭제
abstract final class RecentLoginProviderStore {
  /// 저장된 제공자 (없음·모르는 값이면 null)
  static Future<SocialProvider?> read() async => SocialProvider.fromServerValue(
    await DevicePreferences.readString(StorageKeys.recentLoginProvider),
  );

  static Future<void> save(SocialProvider provider) =>
      DevicePreferences.writeString(
        StorageKeys.recentLoginProvider,
        provider.serverValue,
      );

  static Future<void> clear() =>
      DevicePreferences.remove(StorageKeys.recentLoginProvider);
}
