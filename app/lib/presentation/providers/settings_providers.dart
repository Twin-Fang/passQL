import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/api_call.dart';
import '../../data/sources/api_providers.dart';
import '../../data/models/member/choice_generation_mode.dart';
import '../../data/models/member/choice_mode_models.dart';
import '../../data/models/member/nickname_models.dart';
import 'auth_provider.dart';
import 'session_reset.dart';

/// 설정 화면 데이터 집계 모델
class SettingsData {
  final String memberUuid;
  final String nickname;
  final ChoiceGenerationMode choiceMode;

  const SettingsData({
    required this.memberUuid,
    required this.nickname,
    required this.choiceMode,
  });
}

/// 설정 화면 회원 데이터: GET /members/me > 회원 ID·닉네임·선택지 모드
/// 로그아웃이면 로딩 유지 (API 호출 없음)
final settingsDataProvider = FutureProvider.autoDispose<SettingsData>((
  ref,
) async {
  if (ref.watch(currentMemberUuidProvider) == null) {
    return waitForSignedInMember();
  }
  final me = await ref.read(memberApiProvider).getMe();
  return SettingsData(
    memberUuid: me.memberUuid,
    nickname: me.nickname,
    choiceMode: me.choiceGenerationMode ?? ChoiceGenerationMode.practice,
  );
});

/// 닉네임 Notifier. 재생성·직접 변경 결과를 한곳에서 반영한다.
///
/// 닉네임의 기준은 로그인 세션이다. 따로 캐시하지 않아서 계정을 바꿔도 이전 계정의
/// 닉네임이 남지 않는다. 서버가 거절하면(중복, 쿨다운, 형식 등) [AppException] 을 던져
/// 화면이 `message` 를 그대로 보여줄 수 있게 한다.
class NicknameNotifier extends AutoDisposeAsyncNotifier<String?> {
  @override
  Future<String?> build() async =>
      (await ref.watch(authProvider.future))?.nickname;

  /// 서버가 만든 랜덤 닉네임으로 교체한다.
  /// 실패하면 이전 닉네임으로 되돌리고 [AppException] 을 던져 화면이 문구를 보여 줄 수 있게 한다.
  Future<void> regenerate() async {
    final previousNickname = state.valueOrNull;
    state = const AsyncLoading();
    try {
      final response = await ref.read(memberApiProvider).regenerateNickname();
      await ref.read(authProvider.notifier).updateNickname(response.nickname);
      state = AsyncData(response.nickname);
    } catch (exception) {
      state = AsyncData(previousNickname);
      throw exception.asAppException;
    }
  }

  /// 닉네임 사용 가능 여부. 이미 쓰는 닉네임이면 false.
  Future<bool> isAvailable(String nickname) async {
    final response = await callApiThrowingAppException(
      ref.read(memberApiProvider).checkNickname(nickname),
    );
    return response.available;
  }

  /// 닉네임 직접 변경. 성공하면 로그인 세션의 닉네임을 새 값으로 바꾼다.
  Future<void> change(String nickname) async {
    final response = await callApiThrowingAppException(
      ref.read(memberApiProvider).changeNickname(NicknameChangeRequest(nickname)),
    );
    await ref.read(authProvider.notifier).updateNickname(response.nickname);
  }
}

final nicknameNotifierProvider =
    AsyncNotifierProvider.autoDispose<NicknameNotifier, String?>(
      NicknameNotifier.new,
    );

/// 선택지 생성 모드 Notifier.
///
/// 토글이 즉시 반응하도록 먼저 화면 상태를 바꾸고, 서버 저장이 실패하면 되돌린다.
class ChoiceModeNotifier
    extends AutoDisposeAsyncNotifier<ChoiceGenerationMode> {
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
      await callApiThrowingAppException(
        ref
            .read(memberApiProvider)
            .updateChoiceGenerationMode(ChoiceModeRequest(mode)),
      );
    } on AppException {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }
}

final choiceModeProvider =
    AsyncNotifierProvider.autoDispose<ChoiceModeNotifier, ChoiceGenerationMode>(
      ChoiceModeNotifier.new,
    );
