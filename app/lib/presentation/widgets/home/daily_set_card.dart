import 'package:flutter/cupertino.dart';
import '../../../data/models/daily_set/daily_set_models.dart';
import '../../design/design.dart';

/// 홈 화면의 오늘의 세트 카드.
///
/// 상태는 세 가지다: 풀 수 있음 / 이미 완료 / 준비 중(불러오지 못한 경우 포함).
/// 2열 좁은 카드라 문장은 단어 단위로만 줄바꿈 (PassqlKeepAllText)
class DailySetCard extends StatelessWidget {
  const DailySetCard({
    super.key,
    required this.dailySet,
    required this.onStart,
    required this.onViewResult,
    required this.onBrowse,
    required this.onViewLeaderboard,
  });

  /// null 이면 불러오지 못한 것으로 보고 준비 중으로 표시한다.
  final DailySetTodayResponse? dailySet;

  /// 풀이 시작.
  final VoidCallback onStart;

  /// 완료한 결과/순위 보기.
  final VoidCallback onViewResult;

  /// 세트가 없을 때 문제 목록으로 이동.
  final VoidCallback onBrowse;

  /// 오늘의 전체 순위 보기 (세트가 있을 때 완료 전에도 노출).
  final VoidCallback onViewLeaderboard;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final data = dailySet;
    final completed = data?.alreadyCompleted ?? false;
    final total = data?.questions.length ?? 0;
    final available = !completed && total > 0;

    final VoidCallback onTap = completed
        ? onViewResult
        : available
        ? onStart
        : onBrowse;

    // 카드 전체와 버튼이 같은 동작을 하도록 하나의 콜백을 공유한다.
    return PassqlCard(
      onTap: onTap,
      // 같은 동작의 안쪽 버튼만 스크린리더에 노출 (포커스 2번 방지)
      isCardTapExposedToScreenReader: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.flame_fill,
                size: PassqlIconSize.xs,
                color: colors.warning,
              ),
              const SizedBox(width: PassqlSpacing.xxs),
              // 좁은 2열 카드 + 큰 글자에서 넘치지 않게 남은 폭 안에서 줄바꿈
              Flexible(
                child: Text(
                  '오늘의 세트',
                  style: PassqlTypography.captionSemibold.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ),
              if (completed) ...[
                const Spacer(),
                PassqlBadge(text: '완료', kind: PassqlBadgeKind.success),
              ],
            ],
          ),
          const SizedBox(height: PassqlSpacing.sm),
          if (completed) ...[
            PassqlKeepAllText(
              '${data?.correctCount ?? 0} / $total 정답',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ] else if (available) ...[
            PassqlKeepAllText(
              '오늘의 $total문제',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            PassqlKeepAllText(
              '모두 같은 문제로 겨뤄요',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ] else ...[
            PassqlKeepAllText(
              '오늘의 세트를 준비 중이에요.\n문제 목록에서 풀어보세요.',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
          const SizedBox(height: PassqlSpacing.sm),
          PassqlButton(
            label: completed
                ? '결과 보기'
                : available
                ? '풀어보기'
                : '문제 풀기',
            onPressed: onTap,
            variant: PassqlButtonVariant.tinted,
            size: PassqlButtonSize.small,
          ),
          // 순위 보조 진입 (세트가 있는 상태: 풀 수 있음·완료)
          if (completed || available)
            PassqlButton(
              label: '순위 보기',
              onPressed: onViewLeaderboard,
              variant: PassqlButtonVariant.plain,
              size: PassqlButtonSize.small,
            ),
        ],
      ),
    );
  }
}
