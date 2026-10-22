import 'package:dio/dio.dart';
import 'package:passql_app/data/models/member/choice_mode_models.dart';
import 'package:passql_app/data/models/member/member_me_response.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
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
    this.regenerateNicknameError,
    this.meAuthProvider,
    this.meProviderUserId,
    this.plan = const MemberPlanResponse(),
    this.planError,
  });

  bool isNicknameAvailable;
  DioException? changeNicknameError;
  DioException? choiceModeError;
  DioException? withdrawError;
  DioException? regenerateNicknameError;

  /// GET /members/me 응답의 authProvider (null 이면 서버가 안 내려준 경우)
  String? meAuthProvider;

  /// GET /members/me 응답의 providerUserId (GOOGLE·APPLE 은 Firebase uid)
  String? meProviderUserId;

  /// GET /members/me/plan 응답과 실패(설정하면 던짐)
  MemberPlanResponse plan;
  Object? planError;

  /// 호출 기록 (check:닉네임, change:닉네임, mode:값)
  final calls = <String>[];
  int withdrawCalls = 0;
  int getMeCalls = 0;

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
  Future<MemberMeResponse> getMe() async {
    getMeCalls++;
    return MemberMeResponse(
      memberUuid: 'member-me',
      nickname: '회원',
      authProvider: meAuthProvider,
      providerUserId: meProviderUserId,
    );
  }

  @override
  Future<MemberPlanResponse> getMyPlan() async {
    calls.add('plan');
    if (planError != null) throw planError!;
    return plan;
  }

  @override
  Future<NicknameRegenerateResponse> regenerateNickname() async {
    calls.add('regenerate');
    if (regenerateNicknameError != null) throw regenerateNicknameError!;
    return const NicknameRegenerateResponse(nickname: '랜덤닉네임');
  }
}
