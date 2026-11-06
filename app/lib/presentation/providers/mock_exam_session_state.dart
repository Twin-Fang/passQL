import '../../data/models/mock_exam/mock_exam_enums.dart';
import '../../data/models/mock_exam/mock_exam_sheet.dart';

/// 기기의 문항 답 1개: 고른 보기·표시, 서버 저장 여부 (실패분은 다음 저장·제출 때 다시 보냄)
class MockExamLocalAnswer {
  const MockExamLocalAnswer({
    this.selectedChoiceKey,
    this.isFlagged = false,
    this.isSynced = true,
  });

  final String? selectedChoiceKey;
  final bool isFlagged;
  final bool isSynced;

  bool get isAnswered => selectedChoiceKey != null;

  MockExamLocalAnswer copyWith({
    String? Function()? selectedChoiceKey,
    bool? isFlagged,
    bool? isSynced,
  }) => MockExamLocalAnswer(
    selectedChoiceKey: selectedChoiceKey != null
        ? selectedChoiceKey()
        : this.selectedChoiceKey,
    isFlagged: isFlagged ?? this.isFlagged,
    isSynced: isSynced ?? this.isSynced,
  );
}

/// 풀이 화면 상태: 시험지, 현재 문항, 답, 제출 진행·끝
class MockExamSessionState {
  const MockExamSessionState({
    required this.sheet,
    required this.currentIndex,
    required this.answerByNumber,
    this.isSubmitting = false,
    this.isFinished = false,
  });

  final MockExamSheetResponse sheet;
  final int currentIndex;
  final Map<int, MockExamLocalAnswer> answerByNumber;
  final bool isSubmitting;

  /// 채점 끝(제출·시간 끝·다른 기기 제출) > 결과 화면으로
  final bool isFinished;

  List<MockExamSheetQuestion> get questions => sheet.questions;

  MockExamSheetQuestion get currentQuestion => questions[currentIndex];

  MockExamLocalAnswer answerOf(int questionNumber) =>
      answerByNumber[questionNumber] ?? const MockExamLocalAnswer();

  int get answeredCount =>
      answerByNumber.values.where((answer) => answer.isAnswered).length;

  int get unansweredCount => questions.length - answeredCount;

  int get flaggedCount =>
      answerByNumber.values.where((answer) => answer.isFlagged).length;

  bool get hasUnsyncedAnswer =>
      answerByNumber.values.any((answer) => !answer.isSynced);

  bool get isFirstQuestion => currentIndex == 0;

  bool get isLastQuestion => currentIndex == questions.length - 1;

  /// 과목별 문항 위치 (번호판 묶음)
  List<int> indexesOf(MockExamSubject subject) => [
    for (var index = 0; index < questions.length; index++)
      if (questions[index].subject == subject) index,
  ];

  MockExamSessionState copyWith({
    MockExamSheetResponse? sheet,
    int? currentIndex,
    Map<int, MockExamLocalAnswer>? answerByNumber,
    bool? isSubmitting,
    bool? isFinished,
  }) => MockExamSessionState(
    sheet: sheet ?? this.sheet,
    currentIndex: currentIndex ?? this.currentIndex,
    answerByNumber: answerByNumber ?? this.answerByNumber,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isFinished: isFinished ?? this.isFinished,
  );
}

/// 시험지 > 문항 번호별 답 (서버 저장값)
Map<int, MockExamLocalAnswer> answersFromSheet(MockExamSheetResponse sheet) => {
  for (final question in sheet.questions)
    question.questionNumber: MockExamLocalAnswer(
      selectedChoiceKey: question.selectedChoiceKey,
      isFlagged: question.isFlagged,
    ),
};

/// 다시 받은 시험지 답 + 기기에만 있는 답(저장 실패분은 기기 값 우선)
Map<int, MockExamLocalAnswer> mergeUnsyncedAnswers(
  Map<int, MockExamLocalAnswer> serverAnswers,
  Map<int, MockExamLocalAnswer> localAnswers,
) => {
  ...serverAnswers,
  for (final entry in localAnswers.entries)
    if (!entry.value.isSynced) entry.key: entry.value,
};
