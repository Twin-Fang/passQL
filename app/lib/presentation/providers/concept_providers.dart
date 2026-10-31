import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/safe_call.dart';
import '../../data/models/concept/concept_models.dart';
import '../../data/sources/api_providers.dart';
import 'session_reset.dart';

/// 개념 단원 목록 (#577). 로그아웃이면 로딩 유지, 실패면 이용 불가로 처리(탭 숨김)
final conceptTopicsProvider =
    FutureProvider.autoDispose<ConceptTopicListResponse>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) {
        return waitForSignedInMember();
      }
      final topics = await safeCall(
        ref.read(conceptApiProvider).getTopics(),
        label: 'concept topics',
      );
      return topics ?? const ConceptTopicListResponse();
    });

/// 개념 탭 노출: 서버가 이용 가능이라고 답했을 때만 (공개 또는 미리보기 회원, 로딩 중엔 숨김)
final isConceptLearningAvailableProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(conceptTopicsProvider).valueOrNull?.isAvailable ?? false,
);

/// 단원의 개념 목록
final conceptListProvider = FutureProvider.autoDispose
    .family<ConceptListResponse, String>(
      (ref, topicUuid) => ref.read(conceptApiProvider).getConcepts(topicUuid),
    );

/// 개념 상세 (잠긴 단원이면 403 PRO_REQUIRED 로 실패)
final conceptDetailProvider = FutureProvider.autoDispose
    .family<ConceptDetailResponse, String>(
      (ref, conceptUuid) =>
          ref.read(conceptApiProvider).getConceptDetail(conceptUuid),
    );

/// 확인 문제 5개
final conceptCheckQuestionsProvider = FutureProvider.autoDispose
    .family<List<ConceptCheckQuestionResponse>, String>(
      (ref, conceptUuid) =>
          ref.read(conceptApiProvider).getCheckQuestions(conceptUuid),
    );

/// 개념 화면 상태: 모드·깊이, 지금 문제 위치, 고른 보기, 채점 결과, 다시 읽기로 이동할 문단
class ConceptStudyState {
  const ConceptStudyState({
    this.mode = ConceptStudyMode.read,
    this.depth = ConceptReadingDepth.core,
    this.questionIndex = 0,
    this.selectedKeyByQuestion = const {},
    this.resultByQuestion = const {},
    this.isSubmitting = false,
    this.pendingAnchor,
    this.isInitialized = false,
    this.topicSolvedCountAtStart,
    this.rereadAnchors = const {},
  });

  final ConceptStudyMode mode;
  final ConceptReadingDepth depth;
  // 풀기 화면의 지금 문제 순번 (0부터, 문제 수와 같으면 결과 화면)
  final int questionIndex;
  final Map<String, String> selectedKeyByQuestion;
  final Map<String, ConceptCheckAnswerResponse> resultByQuestion;
  final bool isSubmitting;
  // "이 부분 다시 읽기"로 스크롤할 자세히 문단 앵커 (스크롤 후 비움)
  final String? pendingAnchor;
  // 서버 진행(마지막 모드·깊이)으로 처음 한 번 맞췄는지
  final bool isInitialized;
  // 이 개념 화면을 처음 열었을 때 단원의 끝낸 개념 수 (결과의 단원 숫자 +1 연출 비교용)
  final int? topicSolvedCountAtStart;
  // 결과 화면에서 "다시 읽기"로 다녀온 문단 (돌아오면 그 문제 줄에 읽음 표시)
  final Set<String> rereadAnchors;

  int get correctCount =>
      resultByQuestion.values.where((result) => result.isCorrect).length;

  ConceptStudyState copyWith({
    ConceptStudyMode? mode,
    ConceptReadingDepth? depth,
    int? questionIndex,
    Map<String, String>? selectedKeyByQuestion,
    Map<String, ConceptCheckAnswerResponse>? resultByQuestion,
    bool? isSubmitting,
    String? pendingAnchor,
    bool shouldClearPendingAnchor = false,
    bool? isInitialized,
    int? topicSolvedCountAtStart,
    Set<String>? rereadAnchors,
  }) {
    return ConceptStudyState(
      mode: mode ?? this.mode,
      depth: depth ?? this.depth,
      questionIndex: questionIndex ?? this.questionIndex,
      selectedKeyByQuestion:
          selectedKeyByQuestion ?? this.selectedKeyByQuestion,
      resultByQuestion: resultByQuestion ?? this.resultByQuestion,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      pendingAnchor: shouldClearPendingAnchor
          ? null
          : (pendingAnchor ?? this.pendingAnchor),
      isInitialized: isInitialized ?? this.isInitialized,
      topicSolvedCountAtStart:
          topicSolvedCountAtStart ?? this.topicSolvedCountAtStart,
      rereadAnchors: rereadAnchors ?? this.rereadAnchors,
    );
  }
}

/// 개념 1개 학습 흐름: 읽기·풀기 전환, 깊이 전환, 보기 선택 > 채점 > 다음 문제, 다시 읽기, 진행 저장
/// 진행 저장은 화면을 막지 않는 선택 호출 (실패해도 학습은 계속)
class ConceptStudyNotifier
    extends AutoDisposeFamilyNotifier<ConceptStudyState, String> {
  @override
  ConceptStudyState build(String conceptUuid) => const ConceptStudyState();

  /// 서버에 남은 마지막 모드·깊이로 처음 한 번만 맞춤
  void initializeFrom(ConceptDetailResponse detail) {
    if (state.isInitialized) return;
    state = state.copyWith(
      mode: detail.lastMode,
      depth: detail.lastDepth,
      isInitialized: true,
    );
  }

  void selectMode(ConceptStudyMode mode) {
    if (state.mode == mode) return;
    state = state.copyWith(mode: mode);
    _saveProgress(ConceptProgressRequest(lastMode: mode));
  }

  void selectDepth(ConceptReadingDepth depth) {
    if (state.depth == depth) return;
    state = state.copyWith(depth: depth);
    _saveProgress(ConceptProgressRequest(lastDepth: depth));
  }

  /// 읽음 표시 (자세히 끝까지 읽음, 또는 핵심만에서 다음으로 넘어감)
  void markRead() {
    _saveProgress(const ConceptProgressRequest(isRead: true));
  }

  void selectChoice(String questionUuid, String choiceKey) {
    if (state.resultByQuestion.containsKey(questionUuid)) return;
    state = state.copyWith(
      selectedKeyByQuestion: {
        ...state.selectedKeyByQuestion,
        questionUuid: choiceKey,
      },
    );
  }

  /// 채점: 고른 보기 전송 > 결과 저장 > 목록·단원 진행 새로고침
  Future<void> submit(String questionUuid) async {
    final selectedKey = state.selectedKeyByQuestion[questionUuid];
    if (selectedKey == null || state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final result = await ref
          .read(conceptApiProvider)
          .answerCheckQuestion(
            arg,
            questionUuid,
            ConceptCheckAnswerRequest(choiceKey: selectedKey),
          );
      state = state.copyWith(
        resultByQuestion: {...state.resultByQuestion, questionUuid: result},
        isSubmitting: false,
      );
      _refreshProgressLists();
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  /// 처음 단원 완료 수를 한 번만 기억 (뒤에 새로고침된 값과 비교해 이번에 끝냈는지 판단)
  void rememberTopicSolvedCount(int solvedCount) {
    if (state.topicSolvedCountAtStart != null) return;
    state = state.copyWith(topicSolvedCountAtStart: solvedCount);
  }

  /// 다음 문제: 지금 뒤에서 아직 채점 안 한 문제로 (틀린 문제만 다시 풀 때 맞힌 문제는 건너뜀), 없으면 결과
  void goToNextQuestion(List<String> questionUuids) {
    var nextIndex = state.questionIndex + 1;
    while (nextIndex < questionUuids.length &&
        state.resultByQuestion.containsKey(questionUuids[nextIndex])) {
      nextIndex++;
    }
    state = state.copyWith(questionIndex: nextIndex);
  }

  /// 처음부터 다시 풀기 (고른 보기·결과 비움)
  void restartQuiz() {
    state = state.copyWith(
      questionIndex: 0,
      selectedKeyByQuestion: const {},
      resultByQuestion: const {},
      rereadAnchors: const {},
    );
  }

  /// 틀린 문제만 다시 풀기: 맞힌 결과는 두고 틀린 문제의 보기·결과만 비운 뒤 첫 틀린 문제로
  void restartWrongOnly(List<String> questionUuids) {
    final wrongUuids = questionUuids
        .where((uuid) => state.resultByQuestion[uuid]?.isCorrect == false)
        .toSet();
    if (wrongUuids.isEmpty) return;
    state = state.copyWith(
      questionIndex: questionUuids.indexWhere(wrongUuids.contains),
      selectedKeyByQuestion: {
        for (final entry in state.selectedKeyByQuestion.entries)
          if (!wrongUuids.contains(entry.key)) entry.key: entry.value,
      },
      resultByQuestion: {
        for (final entry in state.resultByQuestion.entries)
          if (!wrongUuids.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  /// 다시 읽기: 읽기·자세히로 바꾸고 해당 문단으로 스크롤 예약 (풀던 위치는 그대로)
  void rereadSection(String anchor) {
    state = state.copyWith(
      mode: ConceptStudyMode.read,
      depth: ConceptReadingDepth.detail,
      pendingAnchor: anchor,
      rereadAnchors: {...state.rereadAnchors, anchor},
    );
  }

  void consumePendingAnchor() {
    state = state.copyWith(shouldClearPendingAnchor: true);
  }

  /// 진행 저장 (화면을 떠나도 저장이 끝날 때까지 상태 유지 > 읽음이면 목록 새로고침)
  void _saveProgress(ConceptProgressRequest request) {
    final keepAliveLink = ref.keepAlive();
    safeCall(
          ref.read(conceptApiProvider).saveProgress(arg, request),
          label: 'concept progress',
        )
        .then((_) {
          if (request.isRead == true) _refreshProgressLists();
        })
        .whenComplete(keepAliveLink.close);
  }

  /// 단원 목록·개념 목록의 완료 표시 새로고침
  void _refreshProgressLists() {
    ref.invalidate(conceptTopicsProvider);
    ref.invalidate(conceptListProvider);
  }
}

final conceptStudyProvider = NotifierProvider.autoDispose
    .family<ConceptStudyNotifier, ConceptStudyState, String>(
      ConceptStudyNotifier.new,
    );
