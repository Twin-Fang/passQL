import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_clock.dart';
import '../../data/models/ox_quiz/ox_quiz_models.dart';
import '../../data/sources/api_providers.dart';
import 'ox_quiz_session_state.dart';
import 'session_reset.dart';

/// OX 퀴즈 한 묶음 장 수 (서버 기본 10, 최대 20)
const oxQuizCardSetSize = 10;

/// OX 퀴즈 풀이 상태 (#1083): 카드 묶음 받기 > O·X 고르기(바로 채점, 기록은 뒤에서 저장) > 다음 카드 > 요약
/// 로그아웃이면 로딩 유지 (API 호출 없음), 화면을 벗어나면 해제
final oxQuizSessionProvider =
    AsyncNotifierProvider.autoDispose<
      OxQuizSessionNotifier,
      OxQuizSessionState
    >(OxQuizSessionNotifier.new);

class OxQuizSessionNotifier
    extends AutoDisposeAsyncNotifier<OxQuizSessionState> {
  @override
  Future<OxQuizSessionState> build() async {
    if (ref.watch(currentMemberUuidProvider) == null) {
      return waitForSignedInMember();
    }
    final cardSet = await ref
        .read(oxQuizApiProvider)
        .getCardSet(size: oxQuizCardSetSize);
    return OxQuizSessionState(
      cards: cardSet.cards,
      todayAnsweredCount: cardSet.todayAnsweredCount,
      dailyGoalCount: cardSet.dailyGoalCount,
      hasLockedTopics: cardSet.hasLockedTopics,
    );
  }

  /// O·X 고르기: 바로 채점 > 콤보·정답 수 > 서버 기록 (다시 고르기 없음)
  void pick(bool isTrue) {
    final current = state.valueOrNull;
    final card = current?.currentCard;
    if (current == null || card == null || current.hasPicked) return;
    final isCorrect = card.isTrue == isTrue;
    state = AsyncData(
      current.copyWith(
        pickedIsTrue: () => isTrue,
        comboCount: isCorrect ? current.comboCount + 1 : 0,
        correctCount: current.correctCount + (isCorrect ? 1 : 0),
      ),
    );
    _recordAnswer(card.cardKey, isCorrect);
  }

  /// 다음 카드 (마지막이면 요약)
  void moveToNextCard() {
    final current = state.valueOrNull;
    if (current == null || !current.hasPicked) return;
    state = AsyncData(
      current.copyWith(
        currentIndex: current.currentIndex + 1,
        pickedIsTrue: () => null,
      ),
    );
  }

  /// 새 묶음 받기 (요약 화면 다시 풀기)
  void restart() => ref.invalidateSelf();

  // 답 기록 (실패해도 풀이는 계속, 요약에서 안내)
  Future<void> _recordAnswer(String cardKey, bool isCorrect) async {
    try {
      final response = await ref
          .read(oxQuizApiProvider)
          .answer(OxAnswerRequest(cardKey: cardKey, isCorrect: isCorrect));
      final latest = state.valueOrNull;
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          todayAnsweredCount: response.todayAnsweredCount,
          nextReviewDates: [
            ...latest.nextReviewDates,
            ?response.nextReviewDate,
          ],
        ),
      );
    } catch (_) {
      final latest = state.valueOrNull;
      if (latest != null) {
        state = AsyncData(latest.copyWith(hasSyncFailure: true));
      }
    }
  }
}

/// 내일까지 다시 나올 카드 수 (요약 화면, 기기 날짜 기준)
int countReviewsDueByTomorrow(List<DateTime> nextReviewDates) {
  final today = AppClock.now();
  final tomorrow = DateTime(today.year, today.month, today.day + 1);
  return nextReviewDates.where((date) => !date.isAfter(tomorrow)).length;
}
