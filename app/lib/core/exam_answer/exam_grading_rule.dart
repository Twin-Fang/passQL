/// 가채점 규칙 (#1075): 문항 수·배점·합격 총점·과목별 범위와 과락 기준
/// 원본은 서버 회차 응답의 gradingRule, [sqldFallback] 은 응답이 없을 때(오프라인·구버전)만 쓰는 대체값
class ExamGradingRule {
  const ExamGradingRule({
    required this.questionCount,
    required this.pointsPerQuestion,
    required this.maxScore,
    required this.passScore,
    required this.subjects,
  });

  final int questionCount;
  final int pointsPerQuestion;
  final int maxScore;
  final int passScore;
  final List<ExamSubjectRule> subjects;

  // 보기 번호 1~4, 답안 문자열의 모름 자리 '0' (서버 답안 형식 ^[0-4]{50}$)
  static const int choiceCount = 4;
  static const int unknownAnswer = 0;

  /// SQLD 대체 규칙: 50문항, 문항당 2점, 총점 60 이상 + 과목별 40% 이상 (서버 SqldGradingRule 과 같은 값)
  static const ExamGradingRule sqldFallback = ExamGradingRule(
    questionCount: 50,
    pointsPerQuestion: 2,
    maxScore: 100,
    passScore: 60,
    subjects: [
      ExamSubjectRule(
        subjectNo: 1,
        name: '데이터 모델링의 이해',
        firstQuestionNo: 1,
        lastQuestionNo: 10,
        maxScore: 20,
        failBelowScore: 8,
      ),
      ExamSubjectRule(
        subjectNo: 2,
        name: 'SQL 기본과 활용',
        firstQuestionNo: 11,
        lastQuestionNo: 50,
        maxScore: 80,
        failBelowScore: 32,
      ),
    ],
  );

  /// 문항 번호 > 과목 규칙 (범위 밖이면 마지막 과목)
  ExamSubjectRule subjectOf(int questionNo) => subjects.firstWhere(
    (subject) => subject.containsQuestion(questionNo),
    orElse: () => subjects.last,
  );
}

/// 과목 1개 규칙: 문항 범위·만점·과락 기준 (미만이면 과락)
class ExamSubjectRule {
  const ExamSubjectRule({
    required this.subjectNo,
    required this.name,
    required this.firstQuestionNo,
    required this.lastQuestionNo,
    required this.maxScore,
    required this.failBelowScore,
  });

  final int subjectNo;
  final String name;
  final int firstQuestionNo;
  final int lastQuestionNo;
  final int maxScore;
  final int failBelowScore;

  int get questionCount => lastQuestionNo - firstQuestionNo + 1;

  bool containsQuestion(int questionNo) =>
      questionNo >= firstQuestionNo && questionNo <= lastQuestionNo;

  bool isFailCut(int score) => score < failBelowScore;
}
