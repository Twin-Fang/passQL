import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../providers/question_providers.dart';
import '../practice/daily_limit_reward_view.dart';
import '../pro/pro_access_feedback.dart';

/// 선택지 받기 연결이 무료 하루 한도로 막힌 오류 (없으면 null)
/// 미리 받은 상세가 200 이어도 한도는 선택지 받기에서 걸림 > 본문을 한도 화면으로
AppException? dailyLimitFailureOfChoiceGeneration(
  QuestionInteractionState interaction,
) {
  final connectFailure = interaction.sseError?.connectFailure;
  if (connectFailure == null || !isFreeDailyLimitError(connectFailure)) {
    return null;
  }
  return connectFailure;
}

/// 풀이 화면 프로 접근 오류 1회 안내: 같은 오류로 시트 반복 방지
/// 대상 키 2종: 상세 실패 questionUuid(다시 시도하면 지움), 선택지 생성 실패 오류 이벤트(다시 시도마다 새 이벤트)
/// 무료 하루 한도는 본문 한도 화면(DailyLimitRewardView)이 맡아 시트를 띄우지 않음 (#963)
class QuestionProAccessNotice {
  final Set<Object> _noticedKeys = {};

  /// 현재 문제 실패 1회 안내: 시트로 열렸을 때만(프로 전환) [onUnlocked]
  /// 현재 문제만 대상 (미리 받기 실패는 그 문제로 넘어왔을 때 안내, 풀이 도중 시트 금지 §4-5)
  void showOnce(
    BuildContext context,
    WidgetRef ref, {
    required Object noticeKey,
    required Object error,
    required VoidCallback onUnlocked,
  }) {
    if (isFreeDailyLimitError(error) || !_noticedKeys.add(noticeKey)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      final feedbackResult = await showProAccessFeedback(context, ref, error);
      if (feedbackResult == ProAccessFeedbackResult.sheetUnlocked &&
          context.mounted) {
        onUnlocked();
      }
    });
  }

  /// 선택지 생성 연결 거부 1회 안내 (프로 필요 등, 하루 한도 제외)
  void showOnceForChoiceGeneration(
    BuildContext context,
    WidgetRef ref,
    QuestionInteractionState interaction,
    QuestionInteractionNotifier interactionNotifier,
  ) {
    final sseError = interaction.sseError;
    final connectFailure = sseError?.connectFailure;
    if (sseError == null || connectFailure == null) return;
    showOnce(
      context,
      ref,
      noticeKey: sseError,
      error: connectFailure,
      onUnlocked: interactionNotifier.startSseGeneration,
    );
  }

  /// 안내 기록 지우기 (다시 시도하면 다시 안내)
  void forget(Object noticeKey) => _noticedKeys.remove(noticeKey);
}
