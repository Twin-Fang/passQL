/// 가채점 판정 3종: 합격, 불합격, 갈림 문항에 따라 바뀜(점수 범위가 합격선·과락선에 걸침)
enum ExamAnswerPassStatus { pass, fail, borderline }

/// 가채점 결과 1건 (서버 결과·오프라인 계산 공통 모양, #1075)
class ExamAnswerScoreReport {
  const ExamAnswerScoreReport({
    required this.subjects,
    required this.totalScore,
    required this.scoreRange,
    required this.passStatus,
    required this.questionMarks,
    this.percentile,
    this.isLocalEstimate = false,
  });

  final List<ExamAnswerSubjectScore> subjects;
  final int totalScore;
  final ExamAnswerScoreRange scoreRange;
  final ExamAnswerPassStatus passStatus;
  final List<ExamAnswerQuestionMark> questionMarks;

  /// 참여자 중 상위 % (1~100, 참여 10명 미만·오프라인 계산이면 null)
  final int? percentile;

  /// 서버에 닿지 못해 기기에서 계산했는지 (상위 % 없음 안내)
  final bool isLocalEstimate;

  bool get hasUnsettledQuestion => scoreRange.min != scoreRange.max;

  /// 틀린 문항 (정오를 알 수 없는 문항 제외)
  List<ExamAnswerQuestionMark> get wrongMarks =>
      questionMarks.where((mark) => mark.isCorrect == false).toList();
}

/// 과목 점수: 점수·만점·과락 여부
class ExamAnswerSubjectScore {
  const ExamAnswerSubjectScore({
    required this.subjectNo,
    required this.score,
    required this.maxScore,
    required this.isFailCut,
  });

  final int subjectNo;
  final int score;
  final int maxScore;
  final bool isFailCut;
}

/// 갈림·미확정 문항을 모두 틀림(min)·모두 맞음(max)으로 본 점수 범위
class ExamAnswerScoreRange {
  const ExamAnswerScoreRange({required this.min, required this.max});

  final int min;
  final int max;
}

/// 문항 1개 채점: 내 답(0 모름), 표시 정답(없으면 null), 정오(갈림·미확정이면 null)
class ExamAnswerQuestionMark {
  const ExamAnswerQuestionMark({
    required this.questionNo,
    required this.myAnswer,
    this.answer,
    this.isCorrect,
  });

  final int questionNo;
  final int myAnswer;
  final int? answer;
  final bool? isCorrect;
}
