import '../../data/models/ox_quiz/ox_quiz_models.dart';

/// OX 퀴즈 화면 상태 (#1083): 카드 묶음, 현재 카드·고른 답, 연속 정답 콤보, 오늘 진행, 다음 복습일
class OxQuizSessionState {
  const OxQuizSessionState({
    required this.cards,
    required this.todayAnsweredCount,
    required this.dailyGoalCount,
    this.hasLockedTopics = false,
    this.currentIndex = 0,
    this.pickedIsTrue,
    this.comboCount = 0,
    this.correctCount = 0,
    this.nextReviewDates = const [],
    this.hasSyncFailure = false,
  });

  final List<OxCardItem> cards;
  final int todayAnsweredCount;
  final int dailyGoalCount;
  final bool hasLockedTopics;
  final int currentIndex;

  /// 현재 카드에 고른 답 (null: 아직 안 고름, true: O, false: X)
  final bool? pickedIsTrue;

  /// 이번 묶음 연속 정답 수 (틀리면 0)
  final int comboCount;
  final int correctCount;

  /// 서버가 정한 카드별 다음 출제일 (기록 성공분)
  final List<DateTime> nextReviewDates;

  /// 답 기록 저장 실패가 있었는지 (요약 화면 안내)
  final bool hasSyncFailure;

  bool get isFinished => currentIndex >= cards.length;

  bool get hasPicked => pickedIsTrue != null;

  OxCardItem? get currentCard => isFinished ? null : cards[currentIndex];

  bool get isPickedCorrect => pickedIsTrue == currentCard?.isTrue;

  /// 답한 카드 수 (지금 카드를 골랐으면 포함)
  int get answeredCount => currentIndex + (hasPicked ? 1 : 0);

  OxQuizSessionState copyWith({
    int? todayAnsweredCount,
    int? currentIndex,
    bool? Function()? pickedIsTrue,
    int? comboCount,
    int? correctCount,
    List<DateTime>? nextReviewDates,
    bool? hasSyncFailure,
  }) => OxQuizSessionState(
    cards: cards,
    todayAnsweredCount: todayAnsweredCount ?? this.todayAnsweredCount,
    dailyGoalCount: dailyGoalCount,
    hasLockedTopics: hasLockedTopics,
    currentIndex: currentIndex ?? this.currentIndex,
    pickedIsTrue: pickedIsTrue != null ? pickedIsTrue() : this.pickedIsTrue,
    comboCount: comboCount ?? this.comboCount,
    correctCount: correctCount ?? this.correctCount,
    nextReviewDates: nextReviewDates ?? this.nextReviewDates,
    hasSyncFailure: hasSyncFailure ?? this.hasSyncFailure,
  );
}
