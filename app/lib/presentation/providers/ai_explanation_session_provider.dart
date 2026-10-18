import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/monitoring/app_analytics.dart';
import 'choice_explanation_providers.dart';
import 'session_reset.dart';

/// 해설함 항목 1건: 해설 요청 + 화면 표시 정보 (풀이 순번·정오답·보기 표시 라벨)
@immutable
class AiExplanationEntry {
  const AiExplanationEntry({
    required this.request,
    required this.isCorrect,
    this.questionNumber,
    this.displayLabelByChoiceKey = const {},
    this.rationale,
  });

  final ChoiceExplanationRequest request;
  final bool isCorrect;

  /// 풀이 묶음 안 순번 (1부터, 단건 풀이면 null)
  final int? questionNumber;

  /// choiceKey > 화면 표시 라벨 (A~D, 화면 순서 기준 #512). 넣은 순서 = 화면 순서
  final Map<String, String> displayLabelByChoiceKey;

  /// 생성 근거 (AI 해설이 없거나 실패했을 때 폴백)
  final String? rationale;

  String get id => request.id;

  /// 패널·해설함 제목: '3번 문제' / '이 문제'
  String get questionTitle =>
      questionNumber == null ? '이 문제' : '$questionNumber번 문제';

  /// choiceKey > 표시 라벨 (모르면 키 그대로)
  String displayLabelOf(String choiceKey) =>
      displayLabelByChoiceKey[choiceKey] ?? choiceKey;

  /// 화면 표시 순서 (모르는 키는 뒤로)
  int displayOrderOf(String choiceKey) {
    final displayIndex = displayLabelByChoiceKey.keys.toList().indexOf(
      choiceKey,
    );
    return displayIndex < 0 ? displayLabelByChoiceKey.length : displayIndex;
  }
}

/// 해설함 + 패널 상태 (풀이 세션 범위)
@immutable
class AiExplanationSessionState {
  const AiExplanationSessionState({
    this.entries = const [],
    this.openedEntryId,
    this.isPanelOpen = false,
    this.isShowingHistory = false,
    this.openRequestCount = 0,
  });

  /// 최근 해설이 앞
  final List<AiExplanationEntry> entries;

  /// 패널에 보이는 해설
  final String? openedEntryId;

  final bool isPanelOpen;

  /// 패널이 해설함 목록을 보여 주는지
  final bool isShowingHistory;

  /// 열기 요청 횟수 (패널이 이미 떠 있어도 다시 펼치는 신호)
  final int openRequestCount;

  AiExplanationEntry? get openedEntry {
    for (final entry in entries) {
      if (entry.id == openedEntryId) return entry;
    }
    return null;
  }

  AiExplanationEntry? entryById(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  AiExplanationSessionState copyWith({
    List<AiExplanationEntry>? entries,
    String? openedEntryId,
    bool? isPanelOpen,
    bool? isShowingHistory,
    int? openRequestCount,
  }) => AiExplanationSessionState(
    entries: entries ?? this.entries,
    openedEntryId: openedEntryId ?? this.openedEntryId,
    isPanelOpen: isPanelOpen ?? this.isPanelOpen,
    isShowingHistory: isShowingHistory ?? this.isShowingHistory,
    openRequestCount: openRequestCount ?? this.openRequestCount,
  );
}

/// 풀이 세션 해설함: 제출마다 항목 추가 > 해설 구독 유지(다음 문제로 가도 백그라운드 완료) > 패널 열기·닫기
/// 풀이 화면이 사라지면(구독 0) 해제되고 해설 구독도 함께 끊김
class AiExplanationSessionNotifier
    extends AutoDisposeNotifier<AiExplanationSessionState> {
  /// 해설함 최대 항목 수 (오래된 것부터 버림)
  static const int maximumEntryCount = 20;

  /// 항목별 해설 provider 구독 (살아 있는 동안 재조회 계속)
  final Map<String, ProviderSubscription<ChoiceExplanationState>>
  _explanationSubscriptions = {};

  @override
  AiExplanationSessionState build() {
    // 회원이 바뀌면 이전 회원 해설함을 비움
    ref.watch(currentMemberUuidProvider);
    ref.onDispose(_closeAllSubscriptions);
    _closeAllSubscriptions();
    return const AiExplanationSessionState();
  }

  /// 제출 직후 항목 추가 (같은 해설이면 맨 앞으로) + 해설 조회 시작
  void addEntry(AiExplanationEntry entry) {
    _explanationSubscriptions.putIfAbsent(
      entry.id,
      () => ref.listen(choiceExplanationProvider(entry.request), (_, _) {}),
    );
    final entries = [
      entry,
      ...state.entries.where((existing) => existing.id != entry.id),
    ];
    final keptEntries = entries.take(maximumEntryCount).toList();
    for (final droppedEntry in entries.skip(maximumEntryCount)) {
      _explanationSubscriptions.remove(droppedEntry.id)?.close();
    }
    state = state.copyWith(entries: keptEntries);
  }

  /// 해설 패널 열기 (이미 떠 있으면 그 해설로 바꾸고 펼침) + 해설 보기 기록
  void openEntry(String entryId) {
    if (state.entryById(entryId) == null) return;
    ref
        .read(appAnalyticsProvider)
        .logAiExplanationRequested(isErrorExplanation: false);
    state = state.copyWith(
      openedEntryId: entryId,
      isPanelOpen: true,
      isShowingHistory: false,
      openRequestCount: state.openRequestCount + 1,
    );
  }

  /// 해설함 목록 보기
  void showHistory() {
    if (state.entries.isEmpty) return;
    state = state.copyWith(
      isPanelOpen: true,
      isShowingHistory: true,
      openRequestCount: state.openRequestCount + 1,
    );
  }

  /// 해설함 목록 > 보던 해설로 돌아가기
  void showOpenedEntry() {
    if (state.openedEntry == null) return;
    state = state.copyWith(isShowingHistory: false);
  }

  /// 패널 닫기 (해설함·백그라운드 조회는 유지)
  void closePanel() {
    state = state.copyWith(isPanelOpen: false, isShowingHistory: false);
  }

  void _closeAllSubscriptions() {
    for (final subscription in _explanationSubscriptions.values) {
      subscription.close();
    }
    _explanationSubscriptions.clear();
  }
}

/// 풀이 세션 해설함 (풀이 화면이 구독하는 동안만 유지)
final aiExplanationSessionProvider =
    NotifierProvider.autoDispose<
      AiExplanationSessionNotifier,
      AiExplanationSessionState
    >(AiExplanationSessionNotifier.new);
