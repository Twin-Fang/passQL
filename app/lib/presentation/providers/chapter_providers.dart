import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/app_exception.dart';
import '../../data/models/question/submit_result.dart';

// ─── 데이터 모델 ────────────────────────────────────────────────

/// 챕터 내 문제 하나의 제출 결과.
class ChapterResult {
  final String questionUuid;
  final bool isCorrect;
  final int durationMs;

  const ChapterResult({
    required this.questionUuid,
    required this.isCorrect,
    required this.durationMs,
  });
}

/// 챕터 완료 후 ChapterResultPage에 넘기는 요약.
class ChapterSummary {
  final String topicName;
  final List<ChapterResult> results;
  final int totalDurationMs;

  const ChapterSummary({
    required this.topicName,
    required this.results,
    required this.totalDurationMs,
  });
}

// ─── 상태 ────────────────────────────────────────────────────────

class ChapterState {
  /// API에서 로드된 UUID 목록.
  final List<String> questionUuids;

  /// 현재 문제 인덱스 (0-based).
  final int currentIndex;

  /// 제출 완료된 결과 누적 목록.
  final List<ChapterResult> results;

  /// 초기 목록 로드 중 여부.
  final bool isLoadingList;

  /// 목록 로드 에러 메시지 (null = 정상).
  final String? listError;

  /// 현재 문제 제출 결과 (피드백 표시용, 제출 전 null).
  final SubmitResult? lastSubmitResult;

  /// 현재 문제 제출 완료 여부.
  final bool isAnswered;

  /// AI 해설 버튼에 사용할 선택 키 (제출 시 저장).
  final String? lastSelectedKey;

  const ChapterState({
    this.questionUuids = const [],
    this.currentIndex = 0,
    this.results = const [],
    this.isLoadingList = true,
    this.listError,
    this.lastSubmitResult,
    this.isAnswered = false,
    this.lastSelectedKey,
  });

  /// 마지막 문제 여부.
  bool get isLastQuestion =>
      questionUuids.isNotEmpty && currentIndex == questionUuids.length - 1;

  ChapterState copyWith({
    List<String>? questionUuids,
    int? currentIndex,
    List<ChapterResult>? results,
    bool? isLoadingList,
    String? listError,
    bool clearError = false,
    SubmitResult? lastSubmitResult,
    bool clearSubmitResult = false,
    bool? isAnswered,
    String? lastSelectedKey,
    bool clearSelectedKey = false,
  }) {
    return ChapterState(
      questionUuids: questionUuids ?? this.questionUuids,
      currentIndex: currentIndex ?? this.currentIndex,
      results: results ?? this.results,
      isLoadingList: isLoadingList ?? this.isLoadingList,
      listError: clearError ? null : (listError ?? this.listError),
      lastSubmitResult: clearSubmitResult
          ? null
          : (lastSubmitResult ?? this.lastSubmitResult),
      isAnswered: isAnswered ?? this.isAnswered,
      lastSelectedKey: clearSelectedKey
          ? null
          : (lastSelectedKey ?? this.lastSelectedKey),
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────

/// 문제 묶음 풀이 진행: 목록 불러오기 > 제출 기록(소요 시간 포함) > 다음 문제 > 완료 요약
class ChapterNotifier extends AutoDisposeFamilyNotifier<ChapterState, String> {
  /// 현재 문제를 보기 시작한 시각. 제출 소요 시간 계산 기준(화면에 그리지 않아 상태 밖에 둔다)
  DateTime _questionStartedAt = DateTime.now();

  @override
  ChapterState build(String flowId) {
    _questionStartedAt = DateTime.now();
    return const ChapterState();
  }

  /// 풀 문제 UUID 목록을 불러온다. 목록을 어디서 가져오는지는 흐름(`QuestionFlow`)이 정한다.
  ///
  /// 실패하면 사용자에게 보여줄 문구를 상태에 담는다(예: 오늘의 세트 이미 완료).
  Future<void> load(Future<List<String>> Function() loader) async {
    state = state.copyWith(isLoadingList: true, clearError: true);
    try {
      final questionUuids = await loader();
      state = state.copyWith(
        questionUuids: questionUuids,
        isLoadingList: false,
      );
    } catch (exception) {
      state = state.copyWith(
        isLoadingList: false,
        listError: exception.asAppException.message,
      );
    }
  }

  /// 현재 문제 제출 기록: 소요 시간 계산 > results 추가 > 피드백 상태
  void recordSubmission(SubmitResult result, String selectedKey) {
    final durationMs = DateTime.now()
        .difference(_questionStartedAt)
        .inMilliseconds;
    final currentQuestionUuid = state.questionUuids[state.currentIndex];
    state = state.copyWith(
      results: [
        ...state.results,
        ChapterResult(
          questionUuid: currentQuestionUuid,
          isCorrect: result.isCorrect,
          durationMs: durationMs,
        ),
      ],
      lastSubmitResult: result,
      isAnswered: true,
      lastSelectedKey: selectedKey,
    );
  }

  /// 다음 문제로 이동 — currentIndex 증가, 피드백 초기화, 소요 시간 기준 재설정.
  void nextQuestion() {
    _questionStartedAt = DateTime.now();
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      clearSubmitResult: true,
      isAnswered: false,
      clearSelectedKey: true,
    );
  }

  /// 완료 요약: 지금까지의 결과 + 총 소요 시간
  ChapterSummary buildSummary(String topicName) => ChapterSummary(
    topicName: topicName,
    results: state.results,
    totalDurationMs: state.results.fold(
      0,
      (sum, result) => sum + result.durationMs,
    ),
  );
}

/// 풀이 흐름별 ChapterNotifier provider. 키는 `QuestionFlow.id`. autoDispose로 이탈 시 해제.
final chapterProvider = NotifierProvider.autoDispose
    .family<ChapterNotifier, ChapterState, String>(ChapterNotifier.new);
