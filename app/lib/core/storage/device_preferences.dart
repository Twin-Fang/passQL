import 'package:shared_preferences/shared_preferences.dart';

/// 기기 단위 일반 저장소(SharedPreferences) 공통 지점: 계정과 무관한 기기 설정·기록
/// 키는 StorageKeys 에서만. 토큰·회원 정보는 두지 않음 (보안 저장소 TokenStore)
abstract final class DevicePreferences {
  static Future<int?> readInt(String key) async => (await _open()).getInt(key);

  static Future<String?> readString(String key) async =>
      (await _open()).getString(key);

  static Future<bool?> readBool(String key) async =>
      (await _open()).getBool(key);

  static Future<void> writeInt(String key, int value) async {
    await (await _open()).setInt(key, value);
  }

  static Future<void> writeString(String key, String value) async {
    await (await _open()).setString(key, value);
  }

  static Future<void> writeBool(String key, bool value) async {
    await (await _open()).setBool(key, value);
  }

  // SDK 가 인스턴스를 캐시 > 호출마다 열어도 디스크 재읽기 없음
  static Future<SharedPreferences> _open() => SharedPreferences.getInstance();
}
