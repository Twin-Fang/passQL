import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/member/ad_bonus_request.dart';
import '../models/member/choice_mode_models.dart';
import '../models/member/credit_history_response.dart';
import '../models/member/member_me_response.dart';
import '../models/member/member_plan_response.dart';
import '../models/member/nickname_models.dart';
import '../models/member/nickname_regenerate_response.dart';
import '../models/member/purchase_history_entry_response.dart';

part 'member_api.g.dart';

@RestApi()
abstract class MemberApiClient {
  factory MemberApiClient(Dio dio, {String baseUrl}) = _MemberApiClient;

  /// 닉네임 조회.
  @GET('/members/me')
  Future<MemberMeResponse> getMe();

  /// 내 등급: 프로 여부·만료일·오늘 푼 랜덤 문제 수·무료 한도.
  @GET('/members/me/plan')
  Future<MemberPlanResponse> getMyPlan();

  /// 내 구매 내역: 스토어 구매 + 운영 지급, 최신순 (#816)
  @GET('/members/me/purchases')
  Future<List<PurchaseHistoryEntryResponse>> getMyPurchases();

  /// 내 크레딧 내역: 날짜별 받은 수·쓴 수·남은 수, 오늘 먼저 (days: 오늘 포함 조회 일수 1~30, #974)
  @GET('/members/me/credit-history')
  Future<CreditHistoryResponse> getMyCreditHistory(@Query('days') int days);

  /// 보상형 광고 시청 뒤 무료 한도 +5 (횟수 제한 없음, 하루 200문제 공정 사용 상한이면 429 FAIR_USE_DAILY_LIMIT_REACHED, #808 #963)
  /// 서버 검증 켜짐이면 AdMob 콜백 기록 확인만 (도착 전 409 AD_BONUS_VERIFICATION_PENDING, #860)
  @POST('/members/me/plan/ad-bonus')
  Future<MemberPlanResponse> grantAdBonus(@Body() AdBonusRequest body);

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
