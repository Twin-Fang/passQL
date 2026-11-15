import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/exam_answer_score_report.dart';
import '../../../data/models/exam_answer/exam_answer_enums.dart';
import '../../design/design.dart';

/// 문항 가답안 상태 > 이름·의미색 (가답안 목록·내 결과 공통 원본)
/// 공식·확정 초록, 우세 파랑, 갈림 주황, 미확정 회색
extension ExamAnswerItemStatusStyle on ExamAnswerItemStatus {
  String get label => switch (this) {
    ExamAnswerItemStatus.official => '공식',
    ExamAnswerItemStatus.confirmed => '확정',
    ExamAnswerItemStatus.leading => '우세',
    ExamAnswerItemStatus.disputed => '갈림',
    ExamAnswerItemStatus.undecided || ExamAnswerItemStatus.unknown => '미확정',
  };

  PassqlBadgeKind get badgeKind => switch (this) {
    ExamAnswerItemStatus.official ||
    ExamAnswerItemStatus.confirmed => PassqlBadgeKind.success,
    ExamAnswerItemStatus.leading => PassqlBadgeKind.info,
    ExamAnswerItemStatus.disputed => PassqlBadgeKind.warning,
    ExamAnswerItemStatus.undecided ||
    ExamAnswerItemStatus.unknown => PassqlBadgeKind.neutral,
  };

  /// 막대·동그라미 채움 색 (배지와 같은 의미색)
  Color fillColorOf(PassqlColors colors) =>
      PassqlBadge.tonesOf(badgeKind, colors).$1;

  /// 글자 색 (대비 4.5 이상 글자 토큰)
  Color textColorOf(PassqlColors colors) =>
      PassqlBadge.tonesOf(badgeKind, colors).$2;
}

/// 회차 상태 > 이름
extension ExamAnswerRoundStatusStyle on ExamAnswerRoundStatus {
  String get label => switch (this) {
    ExamAnswerRoundStatus.collecting => '가답안 수집 중',
    ExamAnswerRoundStatus.official => '공식 정답 반영',
    ExamAnswerRoundStatus.closed => '마감',
    ExamAnswerRoundStatus.unknown => '준비 중',
  };
}

/// 가채점 판정 > 문구·의미색
extension ExamAnswerPassStatusStyle on ExamAnswerPassStatus {
  String get label => switch (this) {
    ExamAnswerPassStatus.pass => '합격 예상',
    ExamAnswerPassStatus.fail => '불합격 예상',
    ExamAnswerPassStatus.borderline => '합격선에 걸쳐 있어요',
  };

  PassqlBadgeKind get badgeKind => switch (this) {
    ExamAnswerPassStatus.pass => PassqlBadgeKind.success,
    ExamAnswerPassStatus.fail => PassqlBadgeKind.important,
    ExamAnswerPassStatus.borderline => PassqlBadgeKind.warning,
  };

  Color textColorOf(PassqlColors colors) =>
      PassqlBadge.tonesOf(badgeKind, colors).$2;
}
