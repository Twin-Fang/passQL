import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/api_providers.dart';
import '../../data/models/member/choice_generation_mode.dart';
import '../../data/models/member/choice_mode_models.dart';
import '../../data/models/member/nickname_models.dart';
import 'auth_provider.dart';

/// 닉네임 재생성/변경 결과를 캐시하는 키.
const _kNickname = 'member_nickname';

/// 설정 화면 데이터 집계 모델
class SettingsData {
  final String memberUuid;
  final String nickname;
  final String version;
  final ChoiceGenerationMode choiceMode;

  const SettingsData({
    required this.memberUuid,
    required this.nickname,
    required this.version,
    required this.choiceMode,
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
    choiceMode: me.choiceGenerationMode ?? ChoiceGenerationMode.practice,
  );
});

/// 닉네임 Notifier. 재생성·직접 변경 결과를 한곳에서 반영한다.
///
/// 서버가 거절하면(중복, 쿨다운, 형식 등) [AppException] 을 던져
/// 화면이 `message` 를 그대로 보여줄 수 있게 한다.
class NicknameNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // 초기값은 캐시에서 로드, 없으면 로그인 세션의 닉네임
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kNickname);
    if (cached != null) return cached;
    return (await ref.read(authProvider.future))?.nickname;
  }

  /// 서버가 만든 랜덤 닉네임으로 교체한다.
  Future<void> regenerate() async {
    final client = ref.read(memberApiProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await client.regenerateNickname();
      await _cache(response.nickname);
      return response.nickname;
    });
  }

  /// 닉네임 사용 가능 여부. 이미 쓰는 닉네임이면 false.
  Future<bool> isAvailable(String nickname) async {
    try {
      final res = await ref.read(memberApiProvider).checkNickname(nickname);
      return res.available;
    } on DioException catch (e) {
      throw e.asAppException;
    }
  }

  /// 닉네임 직접 변경. 성공하면 상태와 캐시를 새 값으로 바꾼다.
  Future<void> change(String nickname) async {
    try {
      final res = await ref
          .read(memberApiProvider)
          .changeNickname(NicknameChangeRequest(nickname));
      await _cache(res.nickname);
      state = AsyncData(res.nickname);
    } on DioException catch (e) {
      throw e.asAppException;
    }
  }

  Future<void> _cache(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNickname, nickname);
  }
}

final nicknameNotifierProvider =
    AsyncNotifierProvider<NicknameNotifier, String?>(NicknameNotifier.new);

/// 선택지 생성 모드 Notifier.
///
/// 토글이 즉시 반응하도록 먼저 화면 상태를 바꾸고, 서버 저장이 실패하면 되돌린다.
class ChoiceModeNotifier extends AsyncNotifier<ChoiceGenerationMode> {
  @override
  Future<ChoiceGenerationMode> build() async =>
      (await ref.watch(settingsDataProvider.future)).choiceMode;

  /// 변경 실패 시 이전 값으로 되돌리고 [AppException] 을 던진다.
  /// (`update` 는 AsyncNotifier 의 기본 메서드 이름이라 `setMode` 로 한다.)
  Future<void> setMode(ChoiceGenerationMode mode) async {
    final previous = state.valueOrNull;
    if (previous == mode) return;

    state = AsyncData(mode);
    try {
      await ref
          .read(memberApiProvider)
          .updateChoiceGenerationMode(ChoiceModeRequest(mode));
    } on DioException catch (e) {
      if (previous != null) state = AsyncData(previous);
      throw e.asAppException;
    }
  }
}

final choiceModeProvider =
    AsyncNotifierProvider<ChoiceModeNotifier, ChoiceGenerationMode>(
      ChoiceModeNotifier.new,
    );
