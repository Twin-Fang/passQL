import 'package:freezed_annotation/freezed_annotation.dart';

/// 가답안 회차 상태 (#1075): 수집 중, 공식 정답 반영, 닫힘 + 앱이 모르는 값
enum ExamAnswerRoundStatus {
  @JsonValue('COLLECTING')
  collecting,
  @JsonValue('OFFICIAL')
  official,
  @JsonValue('CLOSED')
  closed,
  unknown;

  /// 홈 진입 카드를 보일 기간 (시험일 ~ 공식 발표 반영)
  bool get isOpenForEntry => this == collecting || this == official;
}

/// 문항 가답안 상태 5종: 미확정, 우세, 갈림, 확정, 공식 + 앱이 모르는 값
enum ExamAnswerItemStatus {
  @JsonValue('UNKNOWN')
  undecided,
  @JsonValue('LEADING')
  leading,
  @JsonValue('DISPUTED')
  disputed,
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('OFFICIAL')
  official,
  unknown;

  /// 정답이 정해졌는지 (공식·확정·우세 > 채점 확정, 갈림·미확정 > 점수 범위 가정 대상)
  bool get isSettled =>
      this == official || this == confirmed || this == leading;
}

/// 서버 합격 판정 3종 + 앱이 모르는 값
enum ExamAnswerPassStatusValue {
  @JsonValue('PASS')
  pass,
  @JsonValue('FAIL')
  fail,
  @JsonValue('BORDERLINE')
  borderline,
  unknown,
}

/// 답안 제출 출처 (서버 source: WEB | APP)
abstract final class ExamAnswerSheetSource {
  static const String app = 'APP';
}
