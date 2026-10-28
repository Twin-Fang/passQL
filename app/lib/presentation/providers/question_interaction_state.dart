import '../../core/error/app_exception.dart';
import '../../data/models/question/choice_item.dart';
import '../../data/models/question/execute_result.dart';
import '../../data/models/question/sse_event.dart';

/// 선택지 선택·보기 실행(실행한 보기·결과·실패·잠금)·SSE·실행 캐시·제출 상태.
class QuestionInteractionState {
  /// 현재 활성 선택지 세트 UUID (SSE 완료 후 또는 기존 OK 세트).
  final String? activeChoiceSetId;

  /// 현재 표시 중인 선택지 목록.
  final List<ChoiceItem> activeChoices;

  /// 사용자가 선택한 선택지 키 (A/B/C/D).
  final String? selectedChoiceKey;

  /// SQL → ExecuteResult 캐시. 같은 SQL 재실행 방지.
  final Map<String, ExecuteResult> executeCache;

  /// 마지막으로 실행한 보기 키 (선택과 별개, ▶ 실행 버튼으로만 바뀜, #727)
  final String? executedChoiceKey;

  /// [executedChoiceKey] 보기의 실행 결과 (null이면 미실행).
  final ExecuteResult? currentExecuteResult;

  /// SQL 실행 중 여부.
  final bool isExecuting;

  /// SQL 실행 API 실패 사유 (네트워크·5xx·SANDBOX_TIMEOUT 등, null이면 실패 없음)
  final AppException? executeFailure;

  /// 실행형 보기를 실행하려 했지만 무료(결제 켜짐)라 실행하지 않음 > 결과 자리 블러
  final bool isExecutionLocked;

  /// SSE 선택지 생성 중 여부.
  final bool isGeneratingChoices;

  /// SSE 상태 메시지 ("선택지 생성 중..." 등).
  final String? sseStatusMessage;

  /// SSE 에러 (null이면 정상).
  final SseErrorEvent? sseError;

  /// 제출 중 여부.
  final bool isSubmitting;

  const QuestionInteractionState({
    this.activeChoiceSetId,
    this.activeChoices = const [],
    this.selectedChoiceKey,
    this.executeCache = const {},
    this.executedChoiceKey,
    this.currentExecuteResult,
    this.isExecuting = false,
    this.executeFailure,
    this.isExecutionLocked = false,
    this.isGeneratingChoices = false,
    this.sseStatusMessage,
    this.sseError,
    this.isSubmitting = false,
  });

  QuestionInteractionState copyWith({
    String? activeChoiceSetId,
    List<ChoiceItem>? activeChoices,
    String? selectedChoiceKey,
    Map<String, ExecuteResult>? executeCache,
    String? executedChoiceKey,
    ExecuteResult? currentExecuteResult,
    bool clearExecuteResult = false,
    bool? isExecuting,
    AppException? executeFailure,
    bool clearExecuteFailure = false,
    bool? isExecutionLocked,
    bool? isGeneratingChoices,
    String? sseStatusMessage,
    SseErrorEvent? sseError,
    bool clearSseError = false,
    bool? isSubmitting,
  }) {
    return QuestionInteractionState(
      activeChoiceSetId: activeChoiceSetId ?? this.activeChoiceSetId,
      activeChoices: activeChoices ?? this.activeChoices,
      selectedChoiceKey: selectedChoiceKey ?? this.selectedChoiceKey,
      executeCache: executeCache ?? this.executeCache,
      executedChoiceKey: executedChoiceKey ?? this.executedChoiceKey,
      currentExecuteResult: clearExecuteResult
          ? null
          : (currentExecuteResult ?? this.currentExecuteResult),
      isExecuting: isExecuting ?? this.isExecuting,
      executeFailure: clearExecuteFailure
          ? null
          : (executeFailure ?? this.executeFailure),
      isExecutionLocked: isExecutionLocked ?? this.isExecutionLocked,
      isGeneratingChoices: isGeneratingChoices ?? this.isGeneratingChoices,
      sseStatusMessage: sseStatusMessage ?? this.sseStatusMessage,
      sseError: clearSseError ? null : (sseError ?? this.sseError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
