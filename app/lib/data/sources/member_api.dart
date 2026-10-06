import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/member/choice_mode_models.dart';
import '../models/member/member_me_response.dart';
import '../models/member/nickname_models.dart';
import '../models/member/nickname_regenerate_response.dart';

part 'member_api.g.dart';

@RestApi()
abstract class MemberApiClient {
  factory MemberApiClient(Dio dio, {String baseUrl}) = _MemberApiClient;

  /// 닉네임 조회.
  @GET('/members/me')
  Future<MemberMeResponse> getMe();

  /// 회원 탈퇴. 성공하면 서버가 204 를 돌려주고 이후 이 계정의 토큰은 쓸 수 없다.
  @DELETE('/members/me')
  Future<void> withdraw();

  /// 닉네임 사용 가능 여부(중복) 확인.
  @GET('/members/me/nickname/check')
  Future<NicknameCheckResponse> checkNickname(
    @Query('nickname') String nickname,
  );

  /// 닉네임 직접 변경. 변경 후 3일간 재변경 불가(서버가 NICKNAME_COOLDOWN 으로 거절).
  @PATCH('/members/me/nickname')
  Future<NicknameChangeResponse> changeNickname(
    @Body() NicknameChangeRequest body,
  );

  /// 선택지 생성 모드 변경.
  @PATCH('/members/me/settings/choice-generation-mode')
  Future<void> updateChoiceGenerationMode(@Body() ChoiceModeRequest body);

  /// 닉네임 재생성.
  @POST('/members/me/regenerate-nickname')
  Future<NicknameRegenerateResponse> regenerateNickname();
}
