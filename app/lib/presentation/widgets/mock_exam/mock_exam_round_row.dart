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

/// 회차 행 상태 5종 (첫 줄 표시 기준, 위에서부터 우선)
enum _RoundRowState { inProgress, attempted, locked, freeTrial, notStarted }

/// 회차 행: 번호 배지 + 첫 줄(최고 점수·합격 배지 / 진행 / 미응시·무료·PRO) + 작은 둘째 줄 + 쉐브론
/// 제목은 번호 배지와 겹쳐 화면에서 빼고 읽기 문구에만 둠
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

  static const String _notStartedText = '아직 안 풀었어요';

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

  /// 최고 기록 응시 판정 > 배지 문구 (과락이면 사유 붙임, 판정 모르면 null)
  String? get _bestResultText {
    final isPassed = round.bestAttemptIsPassed;
    if (isPassed == null) return null;
    if (isPassed) return '합격';
    return round.bestAttemptFailReason == MockExamFailReason.subjectFail
        ? '불합격 | 과락'
        : '불합격';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = _state;
    final subtitle = _subtitleOf(state);
    return PassqlListRow(
      title: round.title,
      titleContent: _headlineOf(state),
      subtitle: subtitle,
      semanticLabel: '${round.title}, ${_headlineSemanticOf(state)}, $subtitle',
      leading: _RoundNumberBadge(
        roundNumber: round.roundNumber,
        isLocked: _isLocked,
      ),
      hasChevron: true,
      onTap: () => _onTap(context, ref),
    );
  }

  /// 상태 > 첫 줄 (최고 점수+합격 배지 / 풀이 중 진행 / 미응시+무료·PRO)
  Widget _headlineOf(_RoundRowState state) => switch (state) {
    _RoundRowState.inProgress => _InProgressHeadline(
      answeredCount: _ownInProgressAttempt?.answeredCount,
      questionCount: rule.questionCount,
    ),
    _RoundRowState.attempted => _HeadlineLine(
      text: '최고 ',
      score: round.bestScore,
      isScorePassed: round.bestAttemptIsPassed ?? false,
      trailing: _bestResultText == null
          ? null
          : PassqlBadge(
              text: _bestResultText!,
              kind: round.bestAttemptIsPassed!
                  ? PassqlBadgeKind.success
                  : PassqlBadgeKind.important,
            ),
    ),
    // 누르면 행 탭이 PRO 안내를 띄움
    _RoundRowState.locked => const _HeadlineLine(
      text: _notStartedText,
      trailing: PassqlPlanChip(isPro: true),
    ),
    _RoundRowState.freeTrial => const _HeadlineLine(
      text: _notStartedText,
      trailing: PassqlBadge(text: '무료 1회', kind: PassqlBadgeKind.success),
    ),
    _RoundRowState.notStarted => const _HeadlineLine(text: _notStartedText),
  };

  /// 상태 > 첫 줄 읽기 문구 (화면 첫 줄과 같은 정보)
  String _headlineSemanticOf(_RoundRowState state) => switch (state) {
    _RoundRowState.inProgress =>
      _ownInProgressAttempt == null
          ? '풀이 중'
          : '풀이 중 ${_ownInProgressAttempt!.answeredCount}/${rule.questionCount}',
    _RoundRowState.attempted => [
      '최고 ${round.bestScore}점',
      ?_bestResultText,
    ].join(' '),
    _RoundRowState.locked => '$_notStartedText, PRO',
    _RoundRowState.freeTrial => '$_notStartedText, 무료 1회',
    _RoundRowState.notStarted => _notStartedText,
  };

  /// 상태 > 둘째 줄 (풀이 중 남은 시간 / 마지막 결과·응시 횟수 / 시험 형식)
  String _subtitleOf(_RoundRowState state) {
    final ruleText = '${rule.questionCount}문항 | ${rule.durationMinutes}분';
    if (state == _RoundRowState.inProgress) {
      final ownAttempt = _ownInProgressAttempt;
      if (ownAttempt == null) return ruleText;
      // 1분 미만도 0분이 아니라 1분으로 (올림)
      final remainingMinutes = (ownAttempt.remainingSeconds + 59) ~/ 60;
      return '남은 시간 $remainingMinutes분';
    }
    final attemptCount = round.submittedAttemptCount;
    if (attemptCount == 0) return ruleText;
    final countText = '$attemptCount회 응시';
    final lastAttempt = round.lastAttempt;
    // 2회 이상: 마지막 결과 + 횟수
    if (attemptCount > 1) {
      final lastScore = lastAttempt?.totalScore;
      final isLastPassed = lastAttempt?.isPassed;
      if (lastScore == null || isLastPassed == null) return countText;
      return '마지막 $lastScore점 ${isLastPassed ? '합격' : '불합격'} | $countText';
    }
    // 1회: 횟수 + 응시 날짜
    final submittedAt = DateTime.tryParse(
      lastAttempt?.submittedAt ?? '',
    )?.toLocal();
    return submittedAt == null
        ? countText
        : '$countText | ${formatDottedMonthDay(submittedAt)}';
  }

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

/// 첫 줄 공통: 보조 글자("최고 "·"아직 안 풀었어요") + (선택) 점수 + (선택) 배지·칩
/// 좁은 폭·큰 글자에서는 배지가 다음 줄로 내려감
class _HeadlineLine extends StatelessWidget {
  const _HeadlineLine({
    required this.text,
    this.score,
    this.isScorePassed = false,
    this.trailing,
  });

  final String text;
  final int? score;

  /// 점수 색 기준: 그 응시의 실제 합격 여부 (과락이면 총점이 높아도 초록 아님)
  final bool isScorePassed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final scoreColor = isScorePassed ? colors.correctText : colors.label;
    return Wrap(
      spacing: PassqlSpacing.xs,
      runSpacing: PassqlSpacing.hairlineGap,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            text: text,
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: colors.secondaryLabel,
            ),
            children: [
              if (score != null)
                TextSpan(
                  text: '$score점',
                  style: PassqlTypography.title3.copyWith(
                    color: scoreColor,
                    fontFeatures: PassqlTypography.tabular,
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// 풀이 중 첫 줄: "풀이 중" + "23/50" + 짧은 막대 (답한 수 모르면 "풀이 중"만)
class _InProgressHeadline extends StatelessWidget {
  const _InProgressHeadline({
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
      return const _HeadlineLine(text: '풀이 중');
    }
    return _HeadlineLine(
      text: '풀이 중',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$answered/$questionCount',
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: colors.accentText,
              fontFeatures: PassqlTypography.tabular,
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          SizedBox(
            width: PassqlSize.mockExamRoundProgressWidth,
            child: PassqlProgressBar(value: answered / questionCount),
          ),
        ],
      ),
    );
  }
}
