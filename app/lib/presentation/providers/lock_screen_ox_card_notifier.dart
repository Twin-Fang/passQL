import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../data/models/ox_quiz/ox_quiz_models.dart';
import '../../data/sources/api_providers.dart';

/// 잠금화면 OX 복습 카드 상태 (#1110): 카드 1장, 고른 답, 서버가 정한 다음 복습일
@immutable
class LockScreenOxCardState {
  const LockScreenOxCardState({
    required this.card,
    this.pickedIsTrue,
    this.nextReviewDate,
    this.hasSyncFailure = false,
  });

  final OxCardItem card;

  /// 고른 답 (null: 아직 안 고름, true: O, false: X)
  final bool? pickedIsTrue;

  /// 답 기록 뒤 받은 다음 복습일 (기록 전·실패면 null)
  final DateTime? nextReviewDate;

  /// 복습 기록 저장 실패
  final bool hasSyncFailure;

  bool get hasPicked => pickedIsTrue != null;

  LockScreenOxCardState copyWith({
    bool? pickedIsTrue,
    DateTime? nextReviewDate,
    bool? hasSyncFailure,
  }) => LockScreenOxCardState(
    card: card,
    pickedIsTrue: pickedIsTrue ?? this.pickedIsTrue,
    nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    hasSyncFailure: hasSyncFailure ?? this.hasSyncFailure,
  );
}

/// 잠금화면 OX 복습 (잠금 엔진 전용, #1110): 카드 1장 받기 > O·X 고르기(바로 채점) > 복습 기록 저장 > 다음 복습일
/// 크레딧 무관: 문제 상세·제출 API 를 부르지 않음 (OX 카드·답 API 만)
/// API 는 잠금화면 문제와 같은 인증 Dio(dioProvider) 를 쓰는 oxQuizApiProvider
class LockScreenOxCardNotifier extends Notifier<LockScreenOxCardState?> {
  // 잠금화면 한 번에 쓰는 카드 수
  static const int _cardCountPerShow = 1;

  @override
  LockScreenOxCardState? build() => null;

  /// 카드 받기 (기한 지난 복습 > 새 카드, 서버 판정): 받으면 true, 0장·실패면 false (호출부가 문제로 대체)
  Future<bool> load() async {
    state = null;
    try {
      final cardSet = await ref
          .read(oxQuizApiProvider)
          .getCardSet(size: _cardCountPerShow);
      final card = cardSet.cards.firstOrNull;
      if (card == null) return false;
      state = LockScreenOxCardState(card: card);
      return true;
    } catch (error) {
      AppLogger.warn('lock screen ox', 'card load failed : $error');
      return false;
    }
  }

  /// O·X 고르기: 바로 채점 표시 > 복습 기록 (다시 고르기 없음)
  Future<void> pick(bool isTrue) async {
    final current = state;
    if (current == null || current.hasPicked) return;
    state = current.copyWith(pickedIsTrue: isTrue);
    final cardKey = current.card.cardKey;
    try {
      final response = await ref
          .read(oxQuizApiProvider)
          .answer(
            OxAnswerRequest(
              cardKey: cardKey,
              isCorrect: current.card.isTrue == isTrue,
            ),
          );
      // 그사이 다음 표시로 바뀌었으면 덮지 않음
      if (state?.card.cardKey != cardKey) return;
      state = state?.copyWith(nextReviewDate: response.nextReviewDate);
    } catch (error) {
      AppLogger.warn('lock screen ox', 'answer sync failed : $error');
      if (state?.card.cardKey != cardKey) return;
      state = state?.copyWith(hasSyncFailure: true);
    }
  }
}

final lockScreenOxCardProvider =
    NotifierProvider<LockScreenOxCardNotifier, LockScreenOxCardState?>(
      LockScreenOxCardNotifier.new,
    );
