import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_format.dart';
import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../common/app_toast.dart';
import '../pro/pro_offer_sheet.dart';

/// 회차 행 상태 5종 (오른쪽 표시 기준, 위에서부터 우선)
enum _RoundRowState { inProgress, attempted, locked, freeTrial, notStarted }

/// 회차 행: 번호 배지 + 제목·부가 한 줄 + 상태(진행·최고 점수·무료 1회·PRO)
/// 탭: 풀이 중 > 이어 풀기, 시작 가능 > 안내, 체험 소진·이용권 필요 > (지난 결과 있으면 결과) 아니면 이용권 안내, 다른 회차 풀이 중 > 안내 문구
class MockExamRoundRow extends ConsumerWidget {
  const MockExamRoundRow({
    super.key,
    required this.round,
    required this.rule,
    this.inProgressAttempt,
  });

  final MockExamRoundSummary round;
  final MockExamRule rule;

  /// 응답의 풀이 중 응시 (이 회차가 아니면 무시)
  final MockExamInProgressAttempt? inProgressAttempt;

  /// 묶음 구분선 들여쓰기: 행 좌우 여백 + 배지 + 배지 옆 간격 (제목 시작선에 맞춤)
  static const double separatorIndent =
      PassqlSpacing.md + PassqlSize.mockExamRoundBadge + PassqlSpacing.sm;

  bool get _isLocked =>
      !round.canStart &&
      (round.startBlockReason == MockExamStartBlockReason.proRequired ||
          round.startBlockReason == MockExamStartBlockReason.freeTrialUsed);

  /// 이 회차의 풀이 중 응시 (목록 응답의 풀이 중 응시가 이 회차일 때만)
  MockExamInProgressAttempt? get _ownInProgressAttempt =>
      inProgressAttempt?.roundUuid == round.roundUuid
      ? inProgressAttempt
      : null;

  _RoundRowState get _state {
    if (_ownInProgressAttempt != null ||
        round.lastAttempt?.status == MockExamAttemptStatus.inProgress) {
      return _RoundRowState.inProgress;
    }
    if (round.bestScore != null) return _RoundRowState.attempted;
    if (_isLocked) return _RoundRowState.locked;
    if (round.isFreeTrialRound && round.canStart) {
      return _RoundRowState.freeTrial;
    }
    return _RoundRowState.notStarted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = _state;
    return PassqlListRow(
      title: round.title,
      subtitle: _subtitleOf(state),
      leading: _RoundNumberBadge(
        roundNumber: round.roundNumber,
        isLocked: _isLocked,
      ),
      trailing: _trailingOf(state),
      hasChevron: true,
      onTap: () => _onTap(context, ref),
    );
  }

  /// 상태 > 부가 한 줄 (풀이 중 남은 시간 / 응시 횟수·마지막 날짜 / 시험 형식)
  String _subtitleOf(_RoundRowState state) {
    if (state == _RoundRowState.inProgress) {
      final ownAttempt = _ownInProgressAttempt;
      if (ownAttempt == null) return '풀이 중';
      // 1분 미만도 0분이 아니라 1분으로 (올림)
      final remainingMinutes = (ownAttempt.remainingSeconds + 59) ~/ 60;
      return '풀이 중 · 남은 시간 $remainingMinutes분';
    }
    if (round.submittedAttemptCount > 0) {
      final submittedAt = DateTime.tryParse(
        round.lastAttempt?.submittedAt ?? '',
      )?.toLocal();
      final countText = '${round.submittedAttemptCount}회 응시';
      return submittedAt == null
          ? countText
          : '$countText · 마지막 ${formatDottedMonthDay(submittedAt)}';
    }
    return '${rule.questionCount}문항 · ${rule.durationMinutes}분';
  }

  Widget? _trailingOf(_RoundRowState state) => switch (state) {
    _RoundRowState.inProgress => _InProgressProgress(
      answeredCount: _ownInProgressAttempt?.answeredCount,
      questionCount: rule.questionCount,
    ),
    _RoundRowState.attempted => _BestScore(
      bestScore: round.bestScore!,
      passScore: rule.passScore,
      isLastPassed: round.lastAttempt?.isPassed,
    ),
    // 누르면 행 탭이 PRO 안내를 띄움
    _RoundRowState.locked => const PassqlPlanChip(isPro: true),
    _RoundRowState.freeTrial => const PassqlBadge(
      text: '무료 1회',
      kind: PassqlBadgeKind.success,
    ),
    _RoundRowState.notStarted => null,
  };

  void _onTap(BuildContext context, WidgetRef ref) {
    final lastAttempt = round.lastAttempt;
    // 풀이 중 회차: 안내·시작 확인 없이 이어 풀기 (남은 시간은 서버 기준, #902)
    if (lastAttempt != null &&
        lastAttempt.status == MockExamAttemptStatus.inProgress) {
      context.push(AppRoutes.mockExamAttempt(lastAttempt.attemptUuid));
      return;
    }
    if (round.canStart) {
      context.push(AppRoutes.mockExamGuide(round.roundUuid));
      return;
    }
    switch (round.startBlockReason) {
      case MockExamStartBlockReason.otherAttemptInProgress:
        showAppToast(context, '풀고 있는 모의고사를 먼저 마쳐 주세요');
      case _
          when lastAttempt != null &&
              lastAttempt.status == MockExamAttemptStatus.submitted:
        context.push(AppRoutes.mockExamResult(lastAttempt.attemptUuid));
      default:
        showProOfferSheet(context, ref);
    }
  }
}

/// 회차 번호 배지: 열림 강조색 옅은 바탕 + 숫자 "1" + "회", 잠김 회색 바탕 + 모서리 자물쇠
class _RoundNumberBadge extends StatelessWidget {
  const _RoundNumberBadge({required this.roundNumber, required this.isLocked});

  final int roundNumber;
  final bool isLocked;

  /// 자물쇠 원이 배지 모서리 밖으로 걸치는 정도
  static const double _lockOverhang = PassqlSpacing.xxs;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final textColor = isLocked ? colors.secondaryLabel : colors.accentText;
    final badge = Container(
      width: PassqlSize.mockExamRoundBadge,
      height: PassqlSize.mockExamRoundBadge,
      decoration: BoxDecoration(
        color: isLocked ? colors.fill : colors.accentTint,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$roundNumber',
              style: PassqlTypography.title3.copyWith(
                color: textColor,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
            TextSpan(
              text: '회',
              style: PassqlTypography.captionSemibold.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
        maxLines: 1,
        // 배지 크기 고정이라 큰 글자 배율에서도 넘치지 않게
        textScaler: TextScaler.noScaling,
      ),
    );
    if (!isLocked) return badge;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        badge,
        Positioned(
          right: -_lockOverhang,
          bottom: -_lockOverhang,
          child: Container(
            width: PassqlSize.mockExamRoundLockBadge,
            height: PassqlSize.mockExamRoundLockBadge,
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              CupertinoIcons.lock_fill,
              size: PassqlIconSize.xxs,
              color: colors.iconSecondary,
              semanticLabel: '잠김',
            ),
          ),
        ),
      ],
    );
  }
}

/// 풀이 중 진행: "23/50" + 짧은 막대 (답한 수 모르면 막대 없이 "풀이 중")
class _InProgressProgress extends StatelessWidget {
  const _InProgressProgress({
    required this.answeredCount,
    required this.questionCount,
  });

  final int? answeredCount;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final answered = answeredCount;
    if (answered == null || questionCount <= 0) {
      return const PassqlBadge(text: '풀이 중');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$answered/$questionCount',
          style: PassqlTypography.footnoteSemibold.copyWith(
            color: colors.accentText,
            fontFeatures: PassqlTypography.tabular,
          ),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        SizedBox(
          width: PassqlSize.mockExamRoundProgressWidth,
          child: PassqlProgressBar(value: answered / questionCount),
        ),
      ],
    );
  }
}

/// 최고 점수 "72점" (합격선 이상 초록) + 마지막 응시 합격·불합격 배지
class _BestScore extends StatelessWidget {
  const _BestScore({
    required this.bestScore,
    required this.passScore,
    required this.isLastPassed,
  });

  final int bestScore;
  final int passScore;

  /// 마지막 응시 합격 여부 (과락 포함 서버 판정, 모르면 배지 없음)
  final bool? isLastPassed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final scoreColor = bestScore >= passScore ? colors.correctText : colors.label;
    final isPassed = isLastPassed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$bestScore',
                style: PassqlTypography.title3.copyWith(
                  color: scoreColor,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
              TextSpan(
                text: '점',
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ),
        if (isPassed != null) ...[
          const SizedBox(height: PassqlSpacing.hairlineGap),
          PassqlBadge(
            text: isPassed ? '합격' : '불합격',
            kind: isPassed
                ? PassqlBadgeKind.success
                : PassqlBadgeKind.important,
          ),
        ],
      ],
    );
  }
}
