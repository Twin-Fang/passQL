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
}
