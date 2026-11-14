import 'exam_answer_score_report.dart';
import 'sqld_scoring_rule.dart';

/// 가답안 1문항 (채점 입력): 표시 정답·인정 정답(복수 정답 포함)·정답이 정해졌는지
/// 정해짐 = 공식·확정·우세, 아니면 갈림·미확정 (점수 범위의 양 끝 가정 대상)
class ExamAnswerKey {
  const ExamAnswerKey({
    required this.questionNo,
    required this.acceptedAnswers,
    required this.isSettled,
    this.displayAnswer,
  });

  final int questionNo;
  final Set<int> acceptedAnswers;
  final bool isSettled;
  final int? displayAnswer;
}

/// SQLD 오프라인 가채점: 답안 문자열 + 가답안 > 결과 (서버에 닿지 못할 때만 씀)
/// 갈림·미확정 문항: 점수는 표시 정답 기준, 범위는 모두 틀림(min)~모두 맞음(max)
abstract final class SqldAnswerGrader {
  static ExamAnswerScoreReport grade(
    String answers,
    List<ExamAnswerKey> answerKeys,
  ) {
    final keyByQuestionNo = {for (final key in answerKeys) key.questionNo: key};
    final marks = <ExamAnswerQuestionMark>[];
    // 과목 번호 > 점수 3종 (추정·최소·최대)
    final estimatedScoreBySubject = <int, int>{};
    final minScoreBySubject = <int, int>{};
    final maxScoreBySubject = <int, int>{};

    // 문항별 채점 (모름은 언제나 틀림)
    for (
      var questionNo = 1;
      questionNo <= SqldScoringRule.questionCount;
      questionNo++
    ) {
      final myAnswer = answerAt(answers, questionNo);
      final key = keyByQuestionNo[questionNo];
      final subjectNo = SqldScoringRule.subjectOf(questionNo).subjectNo;
      final isAnswered = myAnswer != SqldScoringRule.unknownAnswer;
      final isSettled = key?.isSettled ?? false;
      final isMatched =
          isAnswered && (key?.acceptedAnswers.contains(myAnswer) ?? false);
      final isEstimatedCorrect = isSettled
          ? isMatched
          : isAnswered && myAnswer == key?.displayAnswer;

      void addPoints(Map<int, int> scoreBySubject, bool isCorrect) {
        scoreBySubject[subjectNo] =
            (scoreBySubject[subjectNo] ?? 0) +
            (isCorrect ? SqldScoringRule.pointsPerQuestion : 0);
      }

      addPoints(estimatedScoreBySubject, isEstimatedCorrect);
      addPoints(minScoreBySubject, isSettled && isMatched);
      addPoints(maxScoreBySubject, isSettled ? isMatched : isAnswered);
      marks.add(
        ExamAnswerQuestionMark(
          questionNo: questionNo,
          myAnswer: myAnswer,
          answer: key?.displayAnswer,
          isCorrect: isSettled || !isAnswered ? isMatched : null,
        ),
      );
    }

    // 범위 양 끝 합격 판정 > 판정 3종
    final isPassAtMin = _isPassed(minScoreBySubject);
    final isPassAtMax = _isPassed(maxScoreBySubject);
    final passStatus = isPassAtMin
        ? ExamAnswerPassStatus.pass
        : isPassAtMax
        ? ExamAnswerPassStatus.borderline
        : ExamAnswerPassStatus.fail;

    return ExamAnswerScoreReport(
      subjects: [
        for (final subject in SqldScoringRule.subjects)
          ExamAnswerSubjectScore(
            subjectNo: subject.subjectNo,
            score: estimatedScoreBySubject[subject.subjectNo] ?? 0,
            maxScore: subject.maxScore,
            isFailCut: subject.isFailCut(
              estimatedScoreBySubject[subject.subjectNo] ?? 0,
            ),
          ),
      ],
      totalScore: _sum(estimatedScoreBySubject),
      scoreRange: ExamAnswerScoreRange(
        min: _sum(minScoreBySubject),
        max: _sum(maxScoreBySubject),
      ),
      passStatus: passStatus,
      questionMarks: marks,
      isLocalEstimate: true,
    );
  }

  /// 답안 문자열 [questionNo] 번 자리 > 보기 번호 (모름·빈칸·범위 밖은 0)
  static int answerAt(String answers, int questionNo) {
    if (questionNo < 1 || questionNo > answers.length) {
      return SqldScoringRule.unknownAnswer;
    }
    final choice = int.tryParse(answers[questionNo - 1]);
    if (choice == null || choice < 1 || choice > SqldScoringRule.choiceCount) {
      return SqldScoringRule.unknownAnswer;
    }
    return choice;
  }

  /// 총점 60 이상 + 과락 과목 없음
  static bool _isPassed(Map<int, int> scoreBySubject) =>
      _sum(scoreBySubject) >= SqldScoringRule.passScore &&
      SqldScoringRule.subjects.every(
        (subject) => !subject.isFailCut(scoreBySubject[subject.subjectNo] ?? 0),
      );

  static int _sum(Map<int, int> scoreBySubject) =>
      scoreBySubject.values.fold(0, (total, score) => total + score);
}
