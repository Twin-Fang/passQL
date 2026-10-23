import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../pro/pro_access_feedback.dart';

/// 문제 상세를 못 받았을 때의 본문: 프로 접근 오류면 사유 화면, 그 외는 일반 오류 + 다시 시도
/// 사유 3종: 무료 하루 한도(사유 + 내일 0시), 공정 사용 한도(사유 + 내일 0시), 프로 필요(사유)
/// 무료 한도·프로 필요는 결제 UI 대상일 때 '이용권으로 열기' > 공통 안내(시트) > 시트로 프로가 되면 [onRetry]
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
    // 공정 사용 한도는 프로 사용자 몫이라 결제 버튼 없음
    final canUnlockWithPass =
        exception.code != ErrorCode.fairUseDailyLimitReached &&
        ref.watch(shouldShowProUiProvider);
    return PassqlStatusView.empty(
      icon: icon,
      title: reason,
      message: resetNotice,
      actionLabel: canUnlockWithPass ? PassqlLockedPreview.unlockLabel : null,
      onAction: () => _openProOffer(context, ref),
    );
  }

  /// '이용권으로 열기': 프로 접근 안내 공통 지점 > 시트로 프로가 되면 다시 받기
  Future<void> _openProOffer(BuildContext context, WidgetRef ref) async {
    final feedbackResult = await showProAccessFeedback(context, ref, error);
    if (feedbackResult == ProAccessFeedbackResult.sheetUnlockedPro) onRetry();
  }
}
