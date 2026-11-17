/// 가답안 화면 표시 규칙 (#1126): 합의율 공개 최소 응답 수, 회차 제목 꼬리말
/// 소개 사이트 exam-answer-table.js 의 MINIMUM_AGREEMENT_VOTE_COUNT 와 같은 값
abstract final class ExamAnswerDisplayRule {
  // 합의율을 보이는 최소 응답 수 (미만이면 "응답 N명"만, 1명 = 합의 100% 오해 방지)
  static const int minimumAgreementVoteCount = 5;

  /// 합의율을 보여도 되는 응답 수인지
  static bool canShowAgreementRate(int voteCount) =>
      voteCount >= minimumAgreementVoteCount;

  /// 회차 제목 + 꼬리말 (`SQLD 제63회` + `가답안`), 제목에 이미 꼬리말이 있으면 그대로
  static String titleWithSuffix(String roundTitle, String suffix) =>
      roundTitle.contains(suffix) ? roundTitle : '$roundTitle $suffix';

  // 시험일 + N일 지나면 지난 회차 (홈 가답안 강조 기간과 같은 값, DEC-0327)
  static const int pastRoundAfterDays = 7;

  /// 지난 회차 + 정답 반영 완료인지: 이 경우 득표·합의율·참여자 수를 숨기고 기출 풀기로 잇는다 (#1151)
  static bool isPastSettledRound({
    required bool isOfficial,
    required String? examDate,
    required DateTime now,
  }) {
    if (!isOfficial) return false;
    final parsedExamDate = DateTime.tryParse(examDate ?? '');
    if (parsedExamDate == null) return false;
    return now.difference(parsedExamDate).inDays > pastRoundAfterDays;
  }
}
