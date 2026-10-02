import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_providers.dart';
import 'auth_provider.dart';

/// 닉네임 재생성 결과를 캐시하는 키.
const _kNickname = 'member_nickname';

/// 설정 화면 데이터 집계 모델
class SettingsData {
  final String memberUuid;
  final String nickname;
  final String version;

  const SettingsData({
    required this.memberUuid,
    required this.nickname,
    required this.version,
  });
}

/// 설정 화면 초기 데이터 로딩 Provider
///
/// 회원 정보는 GET /members/me, 버전은 PackageInfo에서 조회.
final settingsDataProvider = FutureProvider<SettingsData>((ref) async {
  final client = ref.read(memberApiProvider);

  // 타입 안전한 개별 await — Future.wait + dynamic 캐스트 패턴 제거
  final me = await client.getMe();
  final info = await PackageInfo.fromPlatform();

  return SettingsData(
    memberUuid: me.memberUuid,
    nickname: me.nickname,
    version: info.version,
  );
});

/// 닉네임 재생성 Notifier
///
/// regenerate() 호출 시 서버에서 새 닉네임 받아 SharedPreferences 업데이트.
class NicknameNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // 초기값은 캐시에서 로드
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kNickname);
    if (cached != null) return cached;
    return (await ref.read(authProvider.future))?.nickname;
  }

  Future<void> regenerate() async {
    final client = ref.read(memberApiProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await client.regenerateNickname();
      // 로컬 캐시 업데이트
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kNickname, response.nickname);
      return response.nickname;
    });
  }
}

final nicknameNotifierProvider =
    AsyncNotifierProvider<NicknameNotifier, String?>(NicknameNotifier.new);
