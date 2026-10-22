import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/ai/choice_explanation.dart';
import '../../data/models/ai/choice_explanation_response.dart';
import '../../data/models/question/locked_section_names.dart';
import '../../data/models/question/submit_result.dart';
import '../../data/sources/api_providers.dart';
import 'session_reset.dart';

/// 구조화 해설 요청 키: 문제 + 제출한 선택지 세트 + 고른 보기 (#521)
/// 제출 응답 해설(initial*)은 키 비교에서 빼고, 처음 provider 를 만든 쪽 값만 씀
@immutable
class ChoiceExplanationRequest {
  const ChoiceExplanationRequest({
    required this.questionUuid,
    required this.choiceSetUuid,
    this.selectedChoiceKey,
    this.initialExplanation,
    this.initialText,
    this.initialLockedSections = const [],
  });

  /// 제출 결과 > 요청 키 (세트를 모르면 null: 풀기 전 정답 노출 방지로 서버가 400)
  static ChoiceExplanationRequest? fromSubmission({
    required String questionUuid,
    required SubmitResult result,
    String? selectedChoiceKey,
  }) {
    final choiceSetUuid = result.choiceSetUuid;
    if (questionUuid.isEmpty ||
        choiceSetUuid == null ||
        choiceSetUuid.isEmpty) {
      return null;
    }
    final hasSelectedChoiceKey =
        selectedChoiceKey != null && selectedChoiceKey.isNotEmpty;
    return ChoiceExplanationRequest(
      questionUuid: questionUuid,
      choiceSetUuid: choiceSetUuid,
      selectedChoiceKey: hasSelectedChoiceKey ? selectedChoiceKey : null,
      initialExplanation: result.structuredExplanation,
      initialText: result.explanation,
      initialLockedSections: result.lockedSections,
    );
  }

  final String questionUuid;
  final String choiceSetUuid;

  /// null 이면 서버가 제출한 보기로 찾음
  final String? selectedChoiceKey;

  /// 제출 응답의 구조화 해설 (있으면 요청 없이 바로 표시)
  final ChoiceExplanation? initialExplanation;

  /// 제출 응답의 마크다운 해설 (구조화가 없을 때 생성 중 임시 표시)
  final String? initialText;

  /// 제출 응답의 잠긴 묶음 (무료면 FULL_EXPLANATION, 키 비교에서 뺌)
  final List<String> initialLockedSections;

  /// 해설함 항목 식별값 (같은 세트·같은 보기면 같은 해설)
  String get id => '$choiceSetUuid:${selectedChoiceKey ?? ''}';

  @override
  bool operator ==(Object other) =>
      other is ChoiceExplanationRequest &&
      other.questionUuid == questionUuid &&
      other.choiceSetUuid == choiceSetUuid &&
      other.selectedChoiceKey == selectedChoiceKey;

  @override
  int get hashCode =>
      Object.hash(questionUuid, choiceSetUuid, selectedChoiceKey);
}

/// 화면 상태 3개: 기다리는 중(첫 조회·생성 중), 준비됨, 실패(재시도 가능)
enum ChoiceExplanationPhase { loading, ready, failed }

/// 해설 1건의 화면 상태
@immutable
class ChoiceExplanationState {
  const ChoiceExplanationState._({
    required this.phase,
    this.explanation,
    this.markdownText,
    this.failureMessage,
    this.lockedSections = const [],
  });

  /// 기다리는 중. [interimText]: 옛 해설이 있으면 임시 표시
  const ChoiceExplanationState.loading({String? interimText})
    : this._(phase: ChoiceExplanationPhase.loading, markdownText: interimText);

  const ChoiceExplanationState.ready({
    ChoiceExplanation? explanation,
    String? markdownText,
    List<String> lockedSections = const [],
  }) : this._(
         phase: ChoiceExplanationPhase.ready,
         explanation: explanation,
         markdownText: markdownText,
         lockedSections: lockedSections,
       );

  const ChoiceExplanationState.failed({
    required String failureMessage,
    String? fallbackText,
  }) : this._(
         phase: ChoiceExplanationPhase.failed,
         markdownText: fallbackText,
         failureMessage: failureMessage,
       );

  final ChoiceExplanationPhase phase;

  /// 구조화 해설 (ready 이고 서버가 줬을 때만)
  final ChoiceExplanation? explanation;

  /// 마크다운 해설: ready 면 본문, loading 이면 임시, failed 면 폴백
  final String? markdownText;

  /// failed 일 때 사용자 문구
  final String? failureMessage;

  /// 서버가 뺀 묶음 (ready 일 때만, 무료면 FULL_EXPLANATION)
  final List<String> lockedSections;

  bool get isFullExplanationLocked => lockedSections.isFullExplanationLocked;

  bool get isLoading => phase == ChoiceExplanationPhase.loading;
  bool get isFailed => phase == ChoiceExplanationPhase.failed;
  bool get hasMarkdownText => markdownText?.trim().isNotEmpty ?? false;
}

/// 재조회 규칙: 서버 간격(retryAfter, 기본 1.5초)부터 1.5배씩 늘리고 6초 상한, 최대 8회(약 30초)
abstract final class ChoiceExplanationPolling {
  static const int defaultRetryAfterMilliseconds = 1500;
  static const int maximumDelayMilliseconds = 6000;
  static const double backoffMultiplier = 1.5;
  static const int maximumAttemptCount = 8;

  /// [attemptIndex] 번째(0부터) 재조회까지 기다릴 시간
  static Duration delayOf(int attemptIndex, int? retryAfterMilliseconds) {
    final serverMilliseconds =
        retryAfterMilliseconds ?? defaultRetryAfterMilliseconds;
    final backoffMilliseconds =
        defaultRetryAfterMilliseconds *
        math.pow(backoffMultiplier, attemptIndex);
    final delayMilliseconds = math.min(
      math.max(serverMilliseconds, backoffMilliseconds.round()),
      maximumDelayMilliseconds,
    );
    return Duration(milliseconds: delayMilliseconds);
  }
}

/// 사용자 문구 3종
const String choiceExplanationTimeoutMessage = '해설이 아직 준비되지 않았어요';
const String choiceExplanationServerFailedMessage = 'AI 해설을 만들지 못했어요';
const String choiceExplanationEmptyMessage = '이 문제는 아직 AI 해설이 없어요';

/// 해설 1건 조회: 제출 응답 해설 즉시 > 없으면 조회 > 생성 중이면 재조회 > 준비·실패
/// 화면이 바뀌어도 해설함(AiExplanationSessionNotifier)이 구독을 잡고 있으면 백그라운드로 끝까지 진행
class ChoiceExplanationNotifier
    extends
        AutoDisposeFamilyNotifier<
          ChoiceExplanationState,
          ChoiceExplanationRequest
        > {
  Timer? _pollTimer;
  int _pollAttemptCount = 0;

  /// 오래된 응답 무시용 세대 번호 (재시도·재빌드마다 증가)
  int _fetchGeneration = 0;

  @override
  ChoiceExplanationState build(ChoiceExplanationRequest request) {
    final memberUuid = ref.watch(currentMemberUuidProvider);
    ref.onDispose(_stopPolling);
    final initialExplanation = request.initialExplanation;
    if (initialExplanation != null) {
      return ChoiceExplanationState.ready(
        explanation: initialExplanation,
        markdownText: request.initialText,
        lockedSections: request.initialLockedSections,
      );
    }
    // 로그아웃이면 호출 없이 대기 (회원별 데이터)
    if (memberUuid == null) {
      return ChoiceExplanationState.loading(interimText: request.initialText);
    }
    _pollAttemptCount = 0;
    final generation = ++_fetchGeneration;
    // build 안에서 state 를 바꾸지 않게 다음 틱에 조회
    Future.microtask(() => _fetchExplanation(generation));
    return ChoiceExplanationState.loading(interimText: request.initialText);
  }

  /// 실패 뒤 다시 시도: 재조회 횟수 초기화 > 조회
  void retry() {
    _stopPolling();
    _pollAttemptCount = 0;
    final generation = ++_fetchGeneration;
    state = ChoiceExplanationState.loading(
      interimText: state.markdownText ?? arg.initialText,
    );
    _fetchExplanation(generation);
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _fetchGeneration++;
  }

  Future<void> _fetchExplanation(int generation) async {
    try {
      final response = await ref
          .read(aiApiProvider)
          .getChoiceExplanation(
            arg.questionUuid,
            choiceSetUuid: arg.choiceSetUuid,
            selectedChoiceKey: arg.selectedChoiceKey,
          );
      if (generation != _fetchGeneration) return;
      _applyResponse(response, generation);
    } catch (error) {
      if (generation != _fetchGeneration) return;
      state = ChoiceExplanationState.failed(
        failureMessage: error.asAppException.message,
        fallbackText: state.markdownText,
      );
    }
  }

  /// 응답 상태별: READY 표시 / GENERATING 재조회 예약(상한 넘으면 실패) / FAILED 폴백
  void _applyResponse(ChoiceExplanationResponse response, int generation) {
    final responseText = response.text ?? state.markdownText;
    switch (response.status) {
      case ChoiceExplanationStatus.ready:
        final hasText = response.text?.trim().isNotEmpty ?? false;
        // 무료 응답은 본문이 비어도 잠금 표시가 있으면 준비됨 (판정 자리 + 블러)
        final isEmptyExplanation =
            response.explanation == null &&
            !hasText &&
            !response.lockedSections.isFullExplanationLocked;
        state = isEmptyExplanation
            ? const ChoiceExplanationState.failed(
                failureMessage: choiceExplanationEmptyMessage,
              )
            : ChoiceExplanationState.ready(
                explanation: response.explanation,
                markdownText: response.text,
                lockedSections: response.lockedSections,
              );
      case ChoiceExplanationStatus.generating:
        if (_pollAttemptCount >= ChoiceExplanationPolling.maximumAttemptCount) {
          state = ChoiceExplanationState.failed(
            failureMessage: choiceExplanationTimeoutMessage,
            fallbackText: responseText,
          );
          return;
        }
        state = ChoiceExplanationState.loading(interimText: responseText);
        final delay = ChoiceExplanationPolling.delayOf(
          _pollAttemptCount,
          response.retryAfterMilliseconds,
        );
        _pollAttemptCount++;
        _pollTimer = Timer(delay, () => _fetchExplanation(generation));
      case ChoiceExplanationStatus.failed:
        state = ChoiceExplanationState.failed(
          failureMessage: choiceExplanationServerFailedMessage,
          fallbackText: responseText,
        );
    }
  }
}

/// 해설 1건 상태 (구독이 모두 끊기면 해제·재조회 중단)
final choiceExplanationProvider = NotifierProvider.autoDispose
    .family<
      ChoiceExplanationNotifier,
      ChoiceExplanationState,
      ChoiceExplanationRequest
    >(ChoiceExplanationNotifier.new);
