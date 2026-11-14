/// SQLD 채점 규칙 원본 (#1075): 50문항, 문항당 2점, 총점 60 이상 + 과목별 40% 이상이면 합격
/// 서버 채점 결과가 우선이고, 이 값은 오프라인 대체 계산과 화면 과락선 표시에 씀
abstract final class SqldScoringRule {
  static const int questionCount = 50;
  static const int pointsPerQuestion = 2;
  static const int maxScore = 100;
  static const int passScore = 60;

  // 과목 2개: 1과목 1~10번(20점, 8점 미만 과락), 2과목 11~50번(80점, 32점 미만 과락)
  static const List<SqldSubjectRule> subjects = [
    SqldSubjectRule(
      subjectNo: 1,
      name: '데이터 모델링의 이해',
      firstQuestionNo: 1,
      lastQuestionNo: 10,
      failBelowScore: 8,
    ),
    SqldSubjectRule(
      subjectNo: 2,
      name: 'SQL 기본과 활용',
      firstQuestionNo: 11,
      lastQuestionNo: 50,
      failBelowScore: 32,
    ),
  ];

  // 보기 번호 1~4, 답안 문자열의 모름 자리 '0'
  static const int choiceCount = 4;
  static const int unknownAnswer = 0;

  /// 문항 번호 > 과목 규칙 (범위 밖이면 마지막 과목)
  static SqldSubjectRule subjectOf(int questionNo) => subjects.firstWhere(
    (subject) => subject.containsQuestion(questionNo),
    orElse: () => subjects.last,
  );
}

/// 과목 1개 규칙: 문항 범위·만점·과락 기준 (미만이면 과락)
class SqldSubjectRule {
  const SqldSubjectRule({
    required this.subjectNo,
    required this.name,
    required this.firstQuestionNo,
    required this.lastQuestionNo,
    required this.failBelowScore,
  });

  final int subjectNo;
  final String name;
  final int firstQuestionNo;
  final int lastQuestionNo;
  final int failBelowScore;

  int get questionCount => lastQuestionNo - firstQuestionNo + 1;

  int get maxScore => questionCount * SqldScoringRule.pointsPerQuestion;

  bool containsQuestion(int questionNo) =>
      questionNo >= firstQuestionNo && questionNo <= lastQuestionNo;

  bool isFailCut(int score) => score < failBelowScore;
}
