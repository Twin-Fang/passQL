// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_plan_response.freezed.dart';
part 'member_plan_response.g.dart';

/// 회원 등급: 무료, 프로(이용권 보유), 모름(앱이 모르는 새 서버 등급 > 무료와 같게 판정)
/// JSON 값 = [wireValue] (서버 MemberPlan enum FREE·PRO 와 같은 글자)
@JsonEnum(valueField: 'wireValue')
enum MemberPlanType {
  free('FREE'),
  pro('PRO'),
  // 서버에 새 등급이 생겨도 깨지지 않게 받는 자리 (서버가 보내지 않는 값)
  unknown('UNKNOWN');

  const MemberPlanType(this.wireValue);

  /// 서버 JSON 글자
  final String wireValue;

  /// 프로(이용권 보유)인가
  bool get isPro => this == MemberPlanType.pro;

  /// 무료로 판정하는가 (모르는 등급 포함)
  bool get isFree => !isPro;
}

/// GET /members/me/plan 응답 (구매 확인 응답도 같은 형태)
/// 기본값 = 결제 꺼짐 + 무료: 잠금 UI 를 그리지 않는 안전한 상태
@freezed
class MemberPlanResponse with _$MemberPlanResponse {
  const factory MemberPlanResponse({
    // 서버 결제 스위치 (false 면 서버가 모든 회원을 프로처럼 취급)
    @Default(false) bool isBillingEnabled,
    // 서버에 새 등급이 생겨도 깨지지 않게 모르는 값은 unknown (판정은 무료)
    @JsonKey(unknownEnumValue: MemberPlanType.unknown)
    @Default(MemberPlanType.free)
    MemberPlanType plan,
    // 프로 만료 시각 (KST, 무료면 null)
    DateTime? proExpiresAt,
    // 오늘 제출한 서로 다른 랜덤 문제 수 (오늘의 문제 제외)
    @Default(0) int todayRandomSolvedCount,
    // 무료 하루 랜덤 문제 한도
    @Default(0) int dailyFreeLimit,
    // deprecated: 옛 앱(1.36·1.37) 호환용 3개월권 예상 만료일. 화면은 passOptions 사용
    DateTime? purchasableUntil,
    // 구매할 수 있는 이용권 (서버 순서: 3개월 먼저, 결제 꺼짐·상품 없음이면 빈 목록)
    @Default(<PassOption>[]) List<PassOption> passOptions,
    // 가장 최근 검증 구매 시각 (KST, 구매 없음·관리자 부여만 있으면 null)
    DateTime? lastPurchasedAt,
    // 가장 최근 검증 구매의 Play 주문 번호 (구매 없음·관리자 부여만 있으면 null)
    String? lastOrderId,
  }) = _MemberPlanResponse;

  factory MemberPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$MemberPlanResponseFromJson(json);
}

/// 이용권 1종: 스토어 상품 ID, 이용 일수, 지금 사면 될 만료일 (KST)
@freezed
class PassOption with _$PassOption {
  const factory PassOption({
    // Play 일회성 상품 ID (예: pro_pass_3m)
    required String productId,
    // 이용 일수 (30 = 1개월, 90 = 3개월)
    required int durationDays,
    // 지금 구매하면 될 만료 시각 (보유 중이면 현재 만료일에 이어 붙인 값)
    required DateTime expiresAtIfPurchased,
  }) = _PassOption;

  factory PassOption.fromJson(Map<String, dynamic> json) =>
      _$PassOptionFromJson(json);
}
