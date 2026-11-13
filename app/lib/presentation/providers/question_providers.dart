import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../core/monitoring/app_analytics.dart';
import '../../core/monitoring/crash_reporter.dart';
import '../../data/sources/api_providers.dart';
import '../../data/models/member/choice_generation_mode.dart';
import '../../data/models/question/choice_item.dart';
import '../../data/models/question/execute_request.dart';
import '../../data/models/question/execute_result.dart';
import '../../data/models/question/question_detail.dart';
import '../../data/models/question/sse_event.dart';
import '../../data/models/question/submit_request.dart';
import '../../data/models/question/submit_result.dart';
import 'choice_mode_switch_plan.dart';
import 'plan_providers.dart';
import 'question_feature_lock_providers.dart';
import 'question_interaction_state.dart';
import 'settings_providers.dart';

export 'choice_mode_switch_plan.dart';
export 'question_interaction_state.dart';
import 'sql_execution_pacing.dart';

/// 문제 상세 로딩 Provider. autoDispose로 화면 이탈 시 캐시 해제.
final questionDetailProvider = FutureProvider.autoDispose
    .family<QuestionDetail, String>((ref, questionUuid) async {
      return ref.read(questionApiProvider).getQuestion(questionUuid);
    });

/// 이 화면에서 받아 둔 선택지 세트 (보기 방식을 다시 바꿀 때 재사용)
typedef PreparedChoiceSet = ({String choiceSetId, List<ChoiceItem> choices});

/// 문제 풀이 상호작용: 선택지 준비(기존 세트 재사용 또는 SSE 생성) > 보기 방식 변경 반영 > 선택·실행 > 제출
/// questionUuid별 autoDispose family.
class QuestionInteractionNotifier
    extends AutoDisposeFamilyNotifier<QuestionInteractionState, String> {
  /// 바로 쓸 수 있는 선택지 세트 상태값 (서버 choice_set.status)
  static const _readyChoiceSetStatus = 'OK';

  static const _generatingStatusMessage = '선택지 생성 중...';

  StreamSubscription<SseEvent>? _sseSubscription;

  /// 화면을 떠나 정리됐는지 (모드 응답을 기다리는 동안 떠난 경우 상태를 바꾸지 않음)
  bool _isDisposed = false;

  /// 진행 중인 SSE 생성의 모드 (없으면 null). 보기 방식을 바꿔도 끊지 않고 결과만 보관 (#907)
  ChoiceGenerationMode? _inFlightGenerationMode;

  /// 진행 중인 SSE 결과를 화면에 보여 줄지 (다른 세트로 바꿔 둔 동안은 보관만)
  bool _isSseResultShown = true;

  /// 받아 둔 세트: 검증된 보기(상세의 OK 세트 또는 연습 모드 생성), AI 새 보기(새 보기 모드 생성)
  PreparedChoiceSet? _readyChoiceSet;
  PreparedChoiceSet? _freshChoiceSet;

  String get _questionUuid => arg;

  @override
  QuestionInteractionState build(String questionUuid) {
    ref.onDispose(() {
      _isDisposed = true;
      _sseSubscription?.cancel();
    });
    return const QuestionInteractionState();
  }

  /// 선택지 준비: 새 보기 모드면 세트가 있어도 SSE 로 새로 받기 (고정 보기 문제는 서버가 고정 세트로 답함, DEC-0251·DEC-0141)
  /// 그 외 바로 쓸 수 있는 세트 재사용 > 없으면 SSE 생성
  Future<void> initializeChoices(QuestionDetail question) async {
    final readyChoiceSet = question.choiceSets
        .where((choiceSet) => choiceSet.status == _readyChoiceSetStatus)
        .firstOrNull;
    if (readyChoiceSet == null) {
      await startSseGeneration();
      return;
    }
    _readyChoiceSet = (
      choiceSetId: readyChoiceSet.choiceSetUuid,
      choices: readyChoiceSet.items,
    );
    final isFreshChoiceMode = await _isFreshChoiceModeEffective();
    if (_isDisposed) return;
    if (isFreshChoiceMode) {
      await startSseGeneration();
    } else {
      useExistingChoiceSet(readyChoiceSet.choiceSetUuid, readyChoiceSet.items);
    }
  }

  /// 실제 적용 모드가 새 보기(REAL)인가. 모드 조회 실패면 false (검증된 세트 재사용)
  Future<bool> _isFreshChoiceModeEffective() async {
    // autoDispose 라 응답이 올 때까지 구독을 걸어 둠
    final modeSubscription = ref.listen(choiceModeProvider, (_, _) {});
    try {
      await ref.read(choiceModeProvider.future);
      return _currentEffectiveChoiceMode() == ChoiceGenerationMode.real;
    } catch (_) {
      return false;
    } finally {
      modeSubscription.close();
    }
  }

  /// 지금 실효 모드 (모름이면 검증된 보기)
  ChoiceGenerationMode _currentEffectiveChoiceMode() =>
      ref.read(effectiveChoiceModeProvider).valueOrNull ??
      ChoiceGenerationMode.practice;

  /// 기존 OK 선택지 세트를 바로 사용 (SSE 불필요).
  void useExistingChoiceSet(String choiceSetId, List<ChoiceItem> items) {
    state = state.copyWith(
      activeChoiceSetId: choiceSetId,
      activeChoices: items,
    );
  }

  /// 풀이 중 보기 방식 변경(저장 성공 뒤) 반영: 제출 전이면 지금 문제 보기 교체, 제출 중·뒤면 다음 풀이부터 (#907)
  /// 생성 비용 때문에 받아 둔 세트·진행 중 생성을 먼저 씀 (판정은 planChoiceModeSwitch)
  ChoiceModeSwitchAction applyChoiceModeChange() {
    final action = planChoiceModeSwitch(
      hasSubmissionStarted: state.isSubmitting || state.hasSubmitted,
      targetMode: _currentEffectiveChoiceMode(),
      hasReadyChoiceSet: _readyChoiceSet != null,
      hasFreshChoiceSet: _freshChoiceSet != null,
      inFlightGenerationMode: _inFlightGenerationMode,
    );
    switch (action) {
      case ChoiceModeSwitchAction.keepUntilNextSolve:
        break;
      case ChoiceModeSwitchAction.showReadyChoiceSet:
        _showPreparedChoiceSet(_readyChoiceSet!);
      case ChoiceModeSwitchAction.showFreshChoiceSet:
        _showPreparedChoiceSet(_freshChoiceSet!);
      case ChoiceModeSwitchAction.awaitInFlightGeneration:
        _isSseResultShown = true;
        state = _clearedForNewChoices().copyWith(
          isGeneratingChoices: true,
          sseStatusMessage: _generatingStatusMessage,
        );
      case ChoiceModeSwitchAction.generateChoices:
        state = _clearedForNewChoices();
        unawaited(startSseGeneration());
    }
    return action;
  }

  /// 받아 둔 세트로 교체 (진행 중 생성은 끊지 않고 결과만 보관)
  void _showPreparedChoiceSet(PreparedChoiceSet choiceSet) {
    _isSseResultShown = false;
    state = _clearedForNewChoices().copyWith(
      activeChoiceSetId: choiceSet.choiceSetId,
      activeChoices: choiceSet.choices,
    );
  }

  /// 보기 교체용 빈 상태 (선택·실행 결과는 버리고 SQL 실행 캐시만 유지)
  QuestionInteractionState _clearedForNewChoices() =>
      QuestionInteractionState(executeCache: state.executeCache);

  /// SSE로 선택지 생성 시작.
  Future<void> startSseGeneration() async {
    _isSseResultShown = true;
    _inFlightGenerationMode = _currentEffectiveChoiceMode();
    state = state.copyWith(
      isGeneratingChoices: true,
      clearSseError: true,
      sseStatusMessage: _generatingStatusMessage,
    );

    await _sseSubscription?.cancel();
    _sseSubscription = ref
        .read(sseQuestionClientProvider)
        .generateChoices(questionUuid: _questionUuid)
        .listen(
          _onSseEvent,
          onError: (_) =>
              _finishGenerationWithError(SseErrorEvent('STREAM_ERROR', true)),
          // complete/error 이벤트 없이 스트림이 끝난 경우(프록시 타임아웃, 네트워크 전환 등)에도
          // 스피너가 영원히 남지 않도록 재시도 가능한 오류로 바꾼다.
          onDone: () {
            if (_inFlightGenerationMode != null) {
              _finishGenerationWithError(SseErrorEvent('STREAM_CLOSED', true));
            }
          },
        );
  }

  void _onSseEvent(SseEvent event) {
    switch (event) {
      case SseStatusEvent(:final message):
        if (_isSseResultShown) {
          state = state.copyWith(sseStatusMessage: message);
        }
      case SseCompleteEvent(:final choices, :final choiceSetId):
        _rememberGeneratedChoiceSet((
          choiceSetId: choiceSetId,
          choices: choices,
        ));
        if (!_isSseResultShown) return;
        state = state.copyWith(
          isGeneratingChoices: false,
          activeChoiceSetId: choiceSetId,
          activeChoices: choices,
          clearSseError: true,
        );
      case final SseErrorEvent errorEvent:
        _finishGenerationWithError(errorEvent);
    }
  }

  /// 생성 결과 보관 (생성 모드 기준: 새 보기 모드면 AI 새 보기, 그 외 검증된 보기 자리)
  void _rememberGeneratedChoiceSet(PreparedChoiceSet choiceSet) {
    if (_inFlightGenerationMode == ChoiceGenerationMode.real) {
      _freshChoiceSet = choiceSet;
    } else {
      _readyChoiceSet ??= choiceSet;
    }
    _inFlightGenerationMode = null;
  }

  /// 생성 실패 마무리 (보관만 하던 생성이면 화면은 그대로)
  void _finishGenerationWithError(SseErrorEvent errorEvent) {
    _inFlightGenerationMode = null;
    if (!_isSseResultShown) return;
    state = state.copyWith(isGeneratingChoices: false, sseError: errorEvent);
  }

  /// 선택지 클릭: 고르기만 (실행은 [runChoice], #727)
  void selectChoice(String choiceKey) {
    state = state.copyWith(selectedChoiceKey: choiceKey);
  }

  /// 보기 ▶ 실행: 무료(결제 켜짐)면 실행 없이 잠금 표시 (오늘의 세트 체험 문제 제외), 아니면 SQL 실행 (캐시 우선)
  Future<void> runChoice({
    required String choiceKey,
    required String sql,
  }) async {
    if (sql.isEmpty) return;
    final isExecutionLocked = ref.read(
      isQuestionExecutionLockedProvider(_questionUuid),
    );
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
    } catch (exception, stackTrace) {
      reportIfUnexpectedFailure(
        exception,
        stackTrace,
        reason: 'questionExecute:$_questionUuid',
      );
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
    } catch (exception, stackTrace) {
      reportIfUnexpectedFailure(
        exception,
        stackTrace,
        reason: 'answerSubmit:$_questionUuid',
      );
      AppLogger.warn(
        'action',
        'answer submit failed ${exception.asAppException.code.name}',
      );
      // 원인별 문구는 호출 측이 토스트로 표시 (인증 만료는 인터셉터가 세션 만료 신호로 처리)
      state = state.copyWith(isSubmitting: false);
      throw exception.asAppException;
    }
    // 제출 성공 뒤 (등급 갱신 오류가 제출 실패로 바뀌지 않게 try 밖)
    state = state.copyWith(hasSubmitted: true);
    _refreshDailyUsageIfCounted();
    // 신고 시 어떤 선택지 세트를 풀었는지 알려야 하므로 결과에 붙여 둔다.
    return submitResult.copyWith(choiceSetUuid: choiceSetId);
  }

  /// 무료(결제 UI 대상) 제출 성공 > 등급 다시 받기 (홈·설정의 오늘 랜덤 n/10 갱신, 기다리지 않음)
  /// 생략: 결제 UI 대상 아님(프로·결제 꺼짐·iOS = 사용량 표시 없음). 한도여도 갱신(남은 수·보상 반영)
  void _refreshDailyUsageIfCounted() {
    if (!ref.read(shouldShowProUiProvider)) return;
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
