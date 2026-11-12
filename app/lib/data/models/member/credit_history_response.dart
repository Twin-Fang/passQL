import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_history_response.freezed.dart';
part 'credit_history_response.g.dart';

/// GET /members/me/credit-history 응답 (#974): 날짜별 크레딧 내역, 오늘 먼저
/// 결제 꺼짐·프로 회원이면 빈 목록
@freezed
class CreditHistoryResponse with _$CreditHistoryResponse {
  const factory CreditHistoryResponse({
    @Default(<CreditHistoryDayResponse>[]) List<CreditHistoryDayResponse> days,
  }) = _CreditHistoryResponse;

  factory CreditHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditHistoryResponseFromJson(json);
}

/// 하루치 크레딧 내역: 받은 수(기본·세트 보너스 2종·광고) > 쓴 수 > 남은 수
/// 크레딧 1개 = 랜덤 풀기 1문제
@freezed
class CreditHistoryDayResponse with _$CreditHistoryDayResponse {
  const factory CreditHistoryDayResponse({
    // 날짜 (KST, yyyy-MM-dd)
    required DateTime date,
    // 하루 기본 크레딧
    @Default(0) int baseCredits,
    // 오늘의 세트 완료 보너스로 받은 크레딧 (안 받았으면 0)
    @Default(0) int dailySetCompletionCredits,
    // 오늘의 세트 정답 80% 보너스로 받은 크레딧 (안 받았으면 0)
    @Default(0) int dailySetAccuracyCredits,
    // 광고 보너스 받은 횟수
    @Default(0) int adBonusCount,
    // 광고 보너스로 받은 크레딧 (횟수 x 1회 보너스)
    @Default(0) int adBonusCredits,
    // 그날 쓴 크레딧 (랜덤 풀기로 제출한 서로 다른 문제 수)
    @Default(0) int usedCredits,
    // 남은 크레딧 (받은 합 - 쓴 수, 0 미만은 0, 지난 날짜는 그날이 끝난 시점 값)
    @Default(0) int remainingCredits,
  }) = _CreditHistoryDayResponse;

  factory CreditHistoryDayResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditHistoryDayResponseFromJson(json);
}
