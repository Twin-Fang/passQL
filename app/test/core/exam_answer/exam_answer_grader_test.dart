import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/exam_answer/exam_answer_score_report.dart';
import 'package:passql_app/core/exam_answer/exam_answer_grader.dart';
import 'package:passql_app/core/exam_answer/exam_grading_rule.dart';

/// SQLD 가채점 핵심 판정 (#1075): 합격선 60·과목 과락·갈림 범위·모름
void main() {
  // SQLD 대체 규칙 (서버 gradingRule 과 같은 값)
  const rule = ExamGradingRule.sqldFallback;

  // 모든 문항 정답 1번, [disputedQuestionNos] 만 갈림
  List<ExamAnswerKey> answerKeysOf({Set<int> disputedQuestionNos = const {}}) =>
      [
        for (var questionNo = 1; questionNo <= rule.questionCount; questionNo++)
          ExamAnswerKey(
            questionNo: questionNo,
            displayAnswer: 1,
            acceptedAnswers: const {1},
            isSettled: !disputedQuestionNos.contains(questionNo),
          ),
      ];

  // 1번부터 [correctCount] 문항만 정답(1), 나머지는 2
  String answersWithCorrectCount(int correctCount) => List.generate(
    rule.questionCount,
    (index) => index < correctCount ? '1' : '2',
  ).join();

  test('총점 60 이상이고 과락이 없으면 합격', () {
    final report = ExamAnswerGrader.grade(
      answersWithCorrectCount(30),
      answerKeysOf(),
      rule,
    );
    expect(report.totalScore, 60);
    expect(report.passStatus, ExamAnswerPassStatus.pass);
  });

  test('총점이 넘어도 1과목 8점 미만이면 과락 불합격', () {
    // 1과목 1~3번만 정답(6점), 2과목 전부 정답(80점)
    final answers = List.generate(
      rule.questionCount,
      (index) => index < 3 || index >= 10 ? '1' : '2',
    ).join();
    final report = ExamAnswerGrader.grade(answers, answerKeysOf(), rule);
    expect(report.totalScore, 86);
    expect(report.subjects.first.isFailCut, isTrue);
    expect(report.passStatus, ExamAnswerPassStatus.fail);
  });

  test('갈림 문항에 따라 합격선에 걸치면 범위와 함께 걸침 판정', () {
    // 29문항 정답(58점) + 갈림 2문항을 정답과 다른 보기로 답함 > 58~62점
    final answers = answersWithCorrectCount(29);
    final report = ExamAnswerGrader.grade(
      answers,
      answerKeysOf(disputedQuestionNos: {49, 50}),
      rule,
    );
    expect(report.scoreRange.min, 58);
    expect(report.scoreRange.max, 62);
    expect(report.passStatus, ExamAnswerPassStatus.borderline);
    expect(report.questionMarks.last.isCorrect, isNull);
  });

  test('모름은 갈림 문항이어도 틀림으로 본다', () {
    final answers = '${answersWithCorrectCount(49).substring(0, 49)}0';
    final report = ExamAnswerGrader.grade(
      answers,
      answerKeysOf(disputedQuestionNos: {50}),
      rule,
    );
    expect(report.scoreRange.max, report.scoreRange.min);
    expect(report.questionMarks.last.isCorrect, isFalse);
  });
}
