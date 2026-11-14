import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';
import '../../core/logging/app_logger.dart';
import '../../core/monitoring/app_analytics.dart';
import '../../data/models/question/choice_set_summary.dart';
import '../../data/models/question/lock_screen_question_response.dart';
import '../../data/models/question/question_detail.dart';
import '../../data/models/question/sse_event.dart';
import '../../data/models/question/submit_request.dart';
import '../../data/sources/api_providers.dart';
import 'auth_provider.dart';
import 'lock_screen_providers.dart';
import 'lock_screen_question_state.dart';
import 'plan_providers.dart';
import 'settings_providers.dart';

export 'lock_screen_question_state.dart';

/// 잠금화면 문제 흐름 (잠금 엔진 전용): 표시 > 로그인·크레딧 확인 > 문제 받기 > 탭 즉시 제출 > 한 문제 더(무료는 크레딧 소진 시 소진 화면)
/// 조용히 닫는 경우 4개: 미로그인, 낼 문제 없음(204), 네트워크·서버 오류, READY 세트 없음(1회 재시도 뒤)
/// 선택지 방식은 앱 "새 보기로 풀기" 실효 모드를 따름: 연습 = 상세의 READY(OK) 세트, 새 보기 = SSE 생성(20초 넘거나 실패면 READY 세트로 대체)
class LockScreenQuestionNotifier extends Notifier<LockScreenQuestionState> {
  // 바로 쓸 수 있는 선택지 세트 상태값 (서버 choice_set.status)
  static const String _readyChoiceSetStatus = 'OK';

  // AI 선택지 생성 최대 대기 (넘으면 기본 세트로 대체하거나 다음 문제)
  static const Duration _choiceGenerationTimeout = Duration(seconds: 20);

  /// 새 표시마다 올림 (이전 표시의 늦은 응답이 화면을 덮지 않게)
  int _showGeneration = 0;

  LockScreenBridge get _bridge => ref.read(lockScreenBridgeProvider);

  @override
  LockScreenQuestionState build() {
    // 등급은 autoDispose 라 잠금 엔진 수명 동안 구독 유지 (알약 값·제출 뒤 갱신)
    ref.listen(planProvider, (_, _) {});
    return const LockScreenQuestionState();
  }

  /// 잠금화면이 새로 보임: 처음 상태 > 로그인 확인 > 등급(크레딧 0 이면 소진 화면) > 문제
  Future<void> show() async {
    final generation = ++_showGeneration;
    state = const LockScreenQuestionState();
    final isSignedIn = await _isSignedIn();
    if (!_isCurrent(generation)) return;
    if (!isSignedIn) return _dismissQuietly('not signed in');
    await _waitForPlan();
    if (!_isCurrent(generation)) return;
    if (ref.read(freeRemainingSolvesProvider) == 0) return _showExhausted();
    await _loadQuestion(generation, canRetryWithoutReadySet: true);
  }

  /// "한 문제 더"(무료·프로 공통): 같은 표시 안에서 다음 문제
  /// 무료 크레딧 0 이면 바로 소진 화면 (제출 뒤 등급 갱신 전이면 서버가 상세에서 한도 응답 > 소진 화면)
  Future<void> loadNext() async {
    final generation = ++_showGeneration;
    state = const LockScreenQuestionState();
    if (ref.read(freeRemainingSolvesProvider) == 0) return _showExhausted();
    await _loadQuestion(generation, canRetryWithoutReadySet: true);
  }

  /// 보기 탭 = 바로 제출 > 채점 표시 > 등급 다시 받기(알약 숫자 감소·상태 알림)
  Future<void> submit(String choiceKey) async {
    final question = state.question;
    final choiceSetId = state.choiceSetId;
    if (question == null || choiceSetId == null) return;
    if (state.isSubmitting || state.hasSubmitted) return;
    state = state.copyWith(
      selectedKey: choiceKey,
      isSubmitting: true,
      shouldClearSubmitError: true,
    );
    final generation = _showGeneration;
    try {
      final submitResult = await ref
          .read(questionApiProvider)
          .submitAnswer(
            question.questionUuid,
            SubmitRequest(
              choiceSetId: choiceSetId,
              selectedChoiceKey: choiceKey,
            ),
          );
      if (!_isCurrent(generation)) return;
      // 응답에 세트 ID 가 없어 붙임 (AI 해설 조회 키, 앱 풀이와 같은 방식)
      state = state.copyWith(
        submitResult: submitResult.copyWith(choiceSetUuid: choiceSetId),
        isSubmitting: false,
      );
      unawaited(
        ref
            .read(appAnalyticsProvider)
            .logLockScreenAnswered(isCorrect: submitResult.isCorrect),
      );
      unawaited(ref.read(planProvider.notifier).refresh());
    } catch (error) {
      if (!_isCurrent(generation)) return;
      _handleSubmitFailure(error.asAppException);
    }
  }

  /// 제출 실패: 무료 한도 > 소진 화면, 공정 상한 > 한 문제 더 숨김, 그 외 > 선택 풀고 한 줄 안내
  void _handleSubmitFailure(AppException exception) {
    AppLogger.warn('lock screen', 'submit failed ${exception.code.name}');
    switch (exception.code) {
      case ErrorCode.freeDailyLimitReached:
        _showExhausted();
      case ErrorCode.fairUseDailyLimitReached:
        state = state.copyWith(
          isSubmitting: false,
          isFairUseLimitReached: true,
          submitErrorMessage: exception.message,
          shouldClearSelection: true,
        );
      default:
        state = state.copyWith(
          isSubmitting: false,
          submitErrorMessage: exception.message,
          shouldClearSelection: true,
        );
    }
  }

  /// 문제 받기 > 상세 > 선택지 준비 (연습: READY 세트, 새 보기: SSE 생성 > 실패면 READY 세트)
  /// 쓸 세트가 없으면 다음 문제 1회 재시도 뒤 닫기
  Future<void> _loadQuestion(
    int generation, {
    required bool canRetryWithoutReadySet,
  }) async {
    // 보기 방식 조회는 문제 받기와 동시에 (무료·결제 켜짐이면 연습)
    final freshChoiceModeCheck = isFreshChoiceModeEffective(ref);
    final LockScreenSettings settings;
    final QuestionDetail question;
    try {
      settings = await _bridge.getSettings();
      final isExecutableExcluded =
          settings.isExecutableExcluded ||
          !ref.read(isLockScreenExecutableIncludedProvider);
      final response = await ref
          .read(questionApiProvider)
          .getLockScreenQuestion(isExecutableExcluded);
      final questionUuid = lockScreenQuestionUuidOf(response.data);
      if (!_isCurrent(generation)) return;
      if (questionUuid == null) return _dismissQuietly('no question');
      question = await ref.read(questionApiProvider).getQuestion(questionUuid);
    } catch (error) {
      if (!_isCurrent(generation)) return;
      final exception = error.asAppException;
      if (exception.code == ErrorCode.freeDailyLimitReached) {
        return _showExhausted();
      }
      return _dismissQuietly('load failed ${exception.code.name}');
    }
    if (!_isCurrent(generation)) return;
    final readyChoiceSet = question.choiceSets
        .where(
          (choiceSet) =>
              choiceSet.status == _readyChoiceSetStatus &&
              choiceSet.items.isNotEmpty,
        )
        .firstOrNull;
    final isFreshChoiceMode = await freshChoiceModeCheck;
    if (!_isCurrent(generation)) return;
    final PreparedLockScreenChoices? choices = isFreshChoiceMode
        ? await _generateFreshChoices(generation, question) ??
              _toPreparedChoices(readyChoiceSet)
        : _toPreparedChoices(readyChoiceSet);
    if (!_isCurrent(generation)) return;
    if (choices == null) {
      if (canRetryWithoutReadySet) {
        return _loadQuestion(generation, canRetryWithoutReadySet: false);
      }
      return _dismissQuietly('no ready choice set');
    }
    state = LockScreenQuestionState(
      phase: LockScreenPhase.question,
      question: question,
      choiceSetId: choices.choiceSetId,
      choices: choices.items,
    );
    unawaited(
      ref
          .read(appAnalyticsProvider)
          .logLockScreenQuestionShown(ref.read(isProProvider) ? 'pro' : 'free'),
    );
  }

  /// AI 선택지 생성: 지문은 먼저 보이고 선택지 자리만 로딩 > 완료 세트 (실패·시간 초과면 null)
  Future<PreparedLockScreenChoices?> _generateFreshChoices(
    int generation,
    QuestionDetail question,
  ) async {
    state = LockScreenQuestionState(
      phase: LockScreenPhase.question,
      question: question,
      isGeneratingChoices: true,
    );
    try {
      final finalEvent = await ref
          .read(sseQuestionClientProvider)
          .generateChoices(questionUuid: question.questionUuid)
          .firstWhere((event) => event is! SseStatusEvent)
          .timeout(_choiceGenerationTimeout);
      if (finalEvent is SseCompleteEvent && finalEvent.choices.isNotEmpty) {
        return (choiceSetId: finalEvent.choiceSetId, items: finalEvent.choices);
      }
      AppLogger.warn('lock screen', 'fresh choices failed, use ready set');
    } catch (error) {
      // 시간 초과·스트림 오류 > 기본 세트로 대체 (호출부)
      AppLogger.warn('lock screen', 'fresh choices timeout or error : $error');
    }
    return null;
  }

  PreparedLockScreenChoices? _toPreparedChoices(ChoiceSetSummary? choiceSet) =>
      choiceSet == null
      ? null
      : (choiceSetId: choiceSet.choiceSetUuid, items: choiceSet.items);

  /// 크레딧 소진 화면 (그날은 다시 안 띄우게 네이티브에 기록)
  void _showExhausted() {
    state = const LockScreenQuestionState(phase: LockScreenPhase.exhausted);
    unawaited(_bridge.markExhaustedToday());
    unawaited(ref.read(appAnalyticsProvider).logLockScreenExhaustedShown());
  }

  void _dismissQuietly(String reason) {
    AppLogger.info('lock screen', 'dismissed quietly : $reason');
    unawaited(_bridge.dismiss());
  }

  Future<bool> _isSignedIn() async {
    try {
      // 잠금 엔진은 오래 살아 있어 앱에서 바뀐 로그인 상태를 저장소에서 다시 읽음 (#1071)
      await ref.read(authProvider.future);
      return await ref.read(authProvider.notifier).reloadFromStorage() != null;
    } catch (_) {
      // 세션 읽기 실패 = 미로그인으로 보고 조용히 닫음 (잠금화면은 로그인 화면이 없음)
      return false;
    }
  }

  /// 등급 최신화 (엔진이 오래 살아 있어 표시마다 다시 받음, 실패해도 진행: 크레딧 판정은 서버가 상세·제출에서 다시 함)
  Future<void> _waitForPlan() async {
    try {
      if (ref.read(planProvider).hasValue) {
        await ref.read(planProvider.notifier).refresh();
      } else {
        await ref.read(planProvider.future);
      }
    } catch (_) {
      // 등급 모름 > 알약 없이 진행
    }
  }

  bool _isCurrent(int generation) => generation == _showGeneration;
}

final lockScreenQuestionProvider =
    NotifierProvider<LockScreenQuestionNotifier, LockScreenQuestionState>(
      LockScreenQuestionNotifier.new,
    );
