import 'package:dio/dio.dart';
import 'package:passql_app/data/models/member/choice_mode_models.dart';
import 'package:passql_app/data/models/member/member_me_response.dart';
import 'package:passql_app/data/models/member/nickname_models.dart';
import 'package:passql_app/data/models/member/nickname_regenerate_response.dart';
import 'package:passql_app/data/sources/member_api.dart';

/// 서버 대신 응답·실패를 정해 둘 수 있는 회원 API. 부른 순서를 [calls] 에 남긴다.
class FakeMemberApi implements MemberApiClient {
  FakeMemberApi({
    this.isNicknameAvailable = true,
    this.changeNicknameError,
    this.choiceModeError,
    this.withdrawError,
  });

  bool isNicknameAvailable;
  DioException? changeNicknameError;
  DioException? choiceModeError;
  DioException? withdrawError;

  /// 호출 기록 (check:닉네임, change:닉네임, mode:값)
  final calls = <String>[];
  int withdrawCalls = 0;

  @override
  Future<NicknameCheckResponse> checkNickname(String nickname) async {
    calls.add('check:$nickname');
    return NicknameCheckResponse(available: isNicknameAvailable);
  }

  @override
  Future<NicknameChangeResponse> changeNickname(
    NicknameChangeRequest body,
  ) async {
    calls.add('change:${body.nickname}');
    if (changeNicknameError != null) throw changeNicknameError!;
    return NicknameChangeResponse(nickname: body.nickname);
  }

  @override
  Future<void> updateChoiceGenerationMode(ChoiceModeRequest body) async {
    calls.add('mode:${body.mode.serverValue}');
    if (choiceModeError != null) throw choiceModeError!;
  }

  @override
  Future<void> withdraw() async {
    withdrawCalls++;
    if (withdrawError != null) throw withdrawError!;
  }

  @override
  Future<MemberMeResponse> getMe() => throw UnimplementedError();

  @override
  Future<NicknameRegenerateResponse> regenerateNickname() =>
      throw UnimplementedError();
}
