import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../practice/daily_limit_reward_view.dart';
import '../pro/pro_access_feedback.dart';

/// 문제 상세를 못 받았을 때의 본문: 프로 접근 오류면 사유 화면, 그 외는 일반 오류 + 다시 시도
/// 사유 3종: 무료 하루 한도(사유 + 내일 0시), 공정 사용 한도(사유 + 내일 0시), 프로 필요(사유)
/// 결제 UI 대상이면 무료 한도 > 한도 화면(광고·세트·이용권, 풀리면 [onRetry], #963), 프로 필요 > 'PRO로 보기' > 시트로 프로가 되면 [onRetry]
class QuestionLoadErrorView extends ConsumerWidget {
  const QuestionLoadErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  /// 프로 접근 오류가 아닐 때의 문구
  static const String genericFailureMessage = '문제를 불러올 수 없어요';

  /// 사유 화면을 그리는 오류인지 (프로 필요·무료 한도·공정 사용 한도 > 풀 문제 없음, 제출 바 숨김 판단용)
  static bool isProAccessReason(Object error) => const {
    ErrorCode.freeDailyLimitReached,
    ErrorCode.fairUseDailyLimitReached,
    ErrorCode.proRequired,
  }.contains(error.asAppException.code);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exception = error.asAppException;
    final shouldShowProUi = ref.watch(shouldShowProUiProvider);
    if (shouldShowProUi && isFreeDailyLimitError(error)) {
      return DailyLimitRewardView(onUnlocked: onRetry);
    }
    final (
      IconData? icon,
      String? reason,
      String? resetNotice,
    ) = switch (exception.code) {
      ErrorCode.freeDailyLimitReached => (
        CupertinoIcons.clock,
        freeDailyLimitReason,
        freeDailyLimitResetNotice,
      ),
      ErrorCode.fairUseDailyLimitReached => (
        CupertinoIcons.clock,
        exception.message,
        fairUseLimitResetNotice,
      ),
      ErrorCode.proRequired => (
        CupertinoIcons.sparkles,
        exception.message,
        null,
      ),
      _ => (null, null, null),
    };
    if (icon == null || reason == null) {
      return PassqlStatusView.error(
        message: genericFailureMessage,
        onRetry: onRetry,
      );
    }
    // 이용권 버튼은 프로 필요만 (공정 사용 한도는 프로 사용자 몫, 무료 한도는 결제 UI 대상 아님)
    final canUnlockWithPass =
        exception.code == ErrorCode.proRequired && shouldShowProUi;
    return PassqlStatusView.empty(
      icon: icon,
      title: reason,
      message: resetNotice,
      actionLabel: canUnlockWithPass ? PassqlLockedPreview.unlockLabel : null,
      onAction: () => _openProOffer(context, ref),
    );
  }

  /// 'PRO로 보기': 프로 접근 안내 공통 지점 > 시트로 프로가 되면 다시 받기
  Future<void> _openProOffer(BuildContext context, WidgetRef ref) async {
    final feedbackResult = await showProAccessFeedback(context, ref, error);
    if (feedbackResult == ProAccessFeedbackResult.sheetUnlocked) onRetry();
  }
}
