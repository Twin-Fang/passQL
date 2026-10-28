import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../core/monitoring/app_analytics.dart';
import '../../data/sources/api_providers.dart';
import '../../data/models/question/choice_item.dart';
import '../../data/models/question/execute_request.dart';
import '../../data/models/question/execute_result.dart';
import '../../data/models/question/question_detail.dart';
import '../../data/models/question/sse_event.dart';
import '../../data/models/question/submit_request.dart';
import '../../data/models/question/submit_result.dart';
import 'plan_providers.dart';
import 'question_interaction_state.dart';

export 'question_interaction_state.dart';
import 'sql_execution_pacing.dart';

/// 문제 상세 로딩 Provider. autoDispose로 화면 이탈 시 캐시 해제.
final questionDetailProvider = FutureProvider.autoDispose
    .family<QuestionDetail, String>((ref, questionUuid) async {
      return ref.read(questionApiProvider).getQuestion(questionUuid);
    });

/// 문제 풀이 상호작용: 선택지 준비(기존 세트 재사용 또는 SSE 생성) > 선택·실행 > 제출
/// questionUuid별 autoDispose family.
class QuestionInteractionNotifier
    extends AutoDisposeFamilyNotifier<QuestionInteractionState, String> {
  /// 바로 쓸 수 있는 선택지 세트 상태값 (서버 choice_set.status)
  static const _readyChoiceSetStatus = 'OK';

  StreamSubscription<SseEvent>? _sseSubscription;

  String get _questionUuid => arg;

  @override
  QuestionInteractionState build(String questionUuid) {
    ref.onDispose(() => _sseSubscription?.cancel());
    return const QuestionInteractionState();
  }

  /// 선택지 준비: 바로 쓸 수 있는 세트가 있으면 재사용, 없으면 SSE 로 새로 생성
  void initializeChoices(QuestionDetail question) {
    final readyChoiceSet = question.choiceSets
        .where((choiceSet) => choiceSet.status == _readyChoiceSetStatus)
        .firstOrNull;
    if (readyChoiceSet != null) {
      useExistingChoiceSet(readyChoiceSet.choiceSetUuid, readyChoiceSet.items);
    } else {
      startSseGeneration();
    }
  }

  /// 기존 OK 선택지 세트를 바로 사용 (SSE 불필요).
  void useExistingChoiceSet(String choiceSetId, List<ChoiceItem> items) {
    state = state.copyWith(
      activeChoiceSetId: choiceSetId,
      activeChoices: items,
    );
  }

  /// SSE로 선택지 생성 시작.
  Future<void> startSseGeneration() async {
    state = state.copyWith(
      isGeneratingChoices: true,
      clearSseError: true,
      sseStatusMessage: '선택지 생성 중...',
    );

    await _sseSubscription?.cancel();
    _sseSubscription = ref
        .read(sseQuestionClientProvider)
        .generateChoices(questionUuid: _questionUuid)
        .listen(
          _onSseEvent,
          onError: (_) {
            state = state.copyWith(
              isGeneratingChoices: false,
              sseError: SseErrorEvent('STREAM_ERROR', true),
            );
          },
          // complete/error 이벤트 없이 스트림이 끝난 경우(프록시 타임아웃, 네트워크 전환 등)에도
          // 스피너가 영원히 남지 않도록 재시도 가능한 오류로 바꾼다.
          onDone: () {
            if (state.isGeneratingChoices) {
              state = state.copyWith(
                isGeneratingChoices: false,
                sseError: SseErrorEvent('STREAM_CLOSED', true),
              );
            }
          },
        );
  }

  void _onSseEvent(SseEvent event) {
    switch (event) {
      case SseStatusEvent(:final message):
        state = state.copyWith(sseStatusMessage: message);
      case SseCompleteEvent(:final choices, :final choiceSetId):
        state = state.copyWith(
          isGeneratingChoices: false,
          activeChoiceSetId: choiceSetId,
          activeChoices: choices,
          clearSseError: true,
        );
      case final SseErrorEvent errorEvent:
        state = state.copyWith(
          isGeneratingChoices: false,
          sseError: errorEvent,
        );
    }
  }

  /// 선택지 클릭: 고르기만 (실행은 [runChoice], #727)
  void selectChoice(String choiceKey) {
    state = state.copyWith(selectedChoiceKey: choiceKey);
  }

  /// 보기 ▶ 실행: 무료(결제 켜짐)면 실행 없이 잠금 표시, 아니면 SQL 실행 (캐시 우선)
  Future<void> runChoice({
    required String choiceKey,
    required String sql,
  }) async {
    if (sql.isEmpty) return;
    final isExecutionLocked = ref.read(shouldShowProUiProvider);
    state = state.copyWith(
      executedChoiceKey: choiceKey,
      clearExecuteResult: true,
      clearExecuteFailure: true,
      isExecutionLocked: isExecutionLocked,
    );
    if (isExecutionLocked) return;
    await _executeSql(sql);
  }

  /// 실행 실패 카드의 다시 시도: 마지막 실행 보기 SQL 재실행
  Future<void> retryExecution() async {
    final executedChoice = state.activeChoices
        .where((choice) => choice.key == state.executedChoiceKey)
        .firstOrNull;
    if (executedChoice == null || state.isExecuting) return;
    state = state.copyWith(clearExecuteFailure: true);
    await _executeSql(executedChoice.body);
  }

  /// SQL 실행: 앱 캐시 우선 > POST /execute(서버도 결과 캐시) > 결과 또는 실패 사유 저장
  /// 캐시로 즉시 끝나도 실행 중 표시는 최소 시간 유지 (#727)
  Future<void> _executeSql(String sql) async {
    state = state.copyWith(isExecuting: true);
    try {
      final executeResult = await runWithMinimumExecutionDisplay(
        () async =>
            state.executeCache[sql] ??
            await ref
                .read(questionApiProvider)
                .executeChoice(_questionUuid, ExecuteRequest(sql: sql)),
      );
      final newCache = Map<String, ExecuteResult>.from(state.executeCache)
        ..[sql] = executeResult;
      state = state.copyWith(
        executeCache: newCache,
        currentExecuteResult: executeResult,
        isExecuting: false,
      );
    } catch (exception) {
      // 실패 사유를 담아 오류 카드로 표시 (인증 만료는 인터셉터가 세션 만료 신호로 처리)
      state = state.copyWith(
        isExecuting: false,
        executeFailure: exception.asAppException,
      );
    }
  }

  /// 답안 제출. 성공 시 SubmitResult, 선택 전이면 null, API 실패 시 [AppException] 던짐.
  /// [sessionUuid]는 연습/챕터 세션 단위 AI 코멘트 집계용이며 단건 풀이는 생략한다.
  Future<SubmitResult?> submit({String? sessionUuid}) async {
    final choiceSetId = state.activeChoiceSetId;
    final selectedKey = state.selectedChoiceKey;
    if (choiceSetId == null || selectedKey == null) return null;

    state = state.copyWith(isSubmitting: true);
    final SubmitResult submitResult;
    try {
      submitResult = await ref
          .read(questionApiProvider)
          .submitAnswer(
            _questionUuid,
            SubmitRequest(
              choiceSetId: choiceSetId,
              selectedChoiceKey: selectedKey,
              sessionUuid: sessionUuid,
            ),
          );
      _logAnswerSubmitted(submitResult.isCorrect);
      AppLogger.info(
        'action',
        'answer submitted isCorrect=${submitResult.isCorrect}',
      );
    } catch (exception) {
      AppLogger.warn(
        'action',
        'answer submit failed ${exception.asAppException.code.name}',
      );
      // 원인별 문구는 호출 측이 토스트로 표시 (인증 만료는 인터셉터가 세션 만료 신호로 처리)
      state = state.copyWith(isSubmitting: false);
      throw exception.asAppException;
    }
    // 제출 성공 뒤 (등급 갱신 오류가 제출 실패로 바뀌지 않게 try 밖)
    _refreshDailyUsageIfCounted();
    // 신고 시 어떤 선택지 세트를 풀었는지 알려야 하므로 결과에 붙여 둔다.
    return submitResult.copyWith(choiceSetUuid: choiceSetId);
  }

  /// 무료(결제 UI 대상) 제출 성공 > 등급 다시 받기 (홈·설정의 오늘 랜덤 n/10 갱신, 기다리지 않음)
  /// 생략 2가지: 결제 UI 대상 아님(프로·결제 꺼짐·iOS = 사용량 표시 없음), 이미 한도(더 늘지 않음)
  void _refreshDailyUsageIfCounted() {
    if (!ref.read(shouldShowProUiProvider)) return;
    if (ref.read(knownPlanProvider)?.isDailyFreeLimitReached == true) return;
    unawaited(ref.read(planProvider.notifier).refresh());
  }

  /// 제출 결과 분석 기록 (토픽 이름: 화면이 이미 불러온 문제 상세에서만, 새로 요청하지 않음)
  void _logAnswerSubmitted(bool isCorrect) {
    final detailProvider = questionDetailProvider(_questionUuid);
    final topicName = ref.exists(detailProvider)
        ? ref.read(detailProvider).valueOrNull?.topicName
        : null;
    ref
        .read(appAnalyticsProvider)
        .logAnswerSubmitted(isCorrect: isCorrect, topicName: topicName);
  }
}

/// questionUuid별 인터랙션 Provider.
final questionInteractionProvider = NotifierProvider.autoDispose
    .family<QuestionInteractionNotifier, QuestionInteractionState, String>(
      QuestionInteractionNotifier.new,
    );
