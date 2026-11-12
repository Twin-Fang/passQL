import 'package:flutter/foundation.dart';

import '../../data/models/question/choice_item.dart';
import '../../data/models/question/question_detail.dart';
import '../../data/models/question/submit_result.dart';

/// 잠금화면에 쓸 선택지 세트 (READY 세트 또는 AI 생성 세트)
typedef PreparedLockScreenChoices = ({
  String choiceSetId,
  List<ChoiceItem> items,
});

/// 잠금화면 화면 단계 3개: 불러오는 중, 문제, 크레딧 소진
enum LockScreenPhase { loading, question, exhausted }

/// 잠금화면 문제 상태 (미리보기도 같은 모양으로 본문을 그림)
@immutable
class LockScreenQuestionState {
  const LockScreenQuestionState({
    this.phase = LockScreenPhase.loading,
    this.question,
    this.choiceSetId,
    this.choices = const [],
    this.selectedKey,
    this.submitResult,
    this.isSubmitting = false,
    this.isGeneratingChoices = false,
    this.isFairUseLimitReached = false,
    this.submitErrorMessage,
  });

  final LockScreenPhase phase;
  final QuestionDetail? question;
  final String? choiceSetId;
  final List<ChoiceItem> choices;

  /// 고른 보기 (채점 뒤에도 표시 고정)
  final String? selectedKey;
  final SubmitResult? submitResult;
  final bool isSubmitting;

  /// AI 선택지 생성 대기 중 (선택지 자리 로딩)
  final bool isGeneratingChoices;

  /// 프로 공정 사용 상한(429) > "한 문제 더" 숨김
  final bool isFairUseLimitReached;

  /// 제출 실패 한 줄 (한도 외 오류)
  final String? submitErrorMessage;

  bool get hasSubmitted => submitResult != null;

  /// 실행형 SQL 문제 (서버 executionMode)
  bool get isExecutable => question?.executionMode == 'EXECUTABLE';

  LockScreenQuestionState copyWith({
    String? selectedKey,
    SubmitResult? submitResult,
    bool? isSubmitting,
    bool? isFairUseLimitReached,
    String? submitErrorMessage,
    bool shouldClearSelection = false,
    bool shouldClearSubmitError = false,
  }) => LockScreenQuestionState(
    phase: phase,
    question: question,
    choiceSetId: choiceSetId,
    choices: choices,
    selectedKey: shouldClearSelection ? null : selectedKey ?? this.selectedKey,
    submitResult: submitResult ?? this.submitResult,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isGeneratingChoices: isGeneratingChoices,
    isFairUseLimitReached: isFairUseLimitReached ?? this.isFairUseLimitReached,
    submitErrorMessage: shouldClearSubmitError
        ? null
        : submitErrorMessage ?? this.submitErrorMessage,
  );
}
