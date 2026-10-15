import 'package:flutter/cupertino.dart';
import '../../../data/models/daily_set/daily_set_models.dart';
import '../../design/design.dart';

/// 홈 화면의 오늘의 세트 카드.
///
/// 상태는 세 가지다: 풀 수 있음 / 이미 완료 / 준비 중(불러오지 못한 경우 포함).
class DailySetCard extends StatelessWidget {
  const DailySetCard({
    super.key,
    required this.dailySet,
    required this.onStart,
    required this.onViewResult,
    required this.onBrowse,
  });

  /// null 이면 불러오지 못한 것으로 보고 준비 중으로 표시한다.
  final DailySetTodayResponse? dailySet;

  /// 풀이 시작.
  final VoidCallback onStart;

  /// 완료한 결과/순위 보기.
  final VoidCallback onViewResult;

  /// 세트가 없을 때 문제 목록으로 이동.
  final VoidCallback onBrowse;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.flame_fill, size: 14, color: colors.warning),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                '오늘의 세트',
                style: PassqlTypography.captionSemibold.copyWith(color: colors.secondaryLabel),
              ),
              if (completed) ...[
                const Spacer(),
                PassqlBadge(text: '완료', color: colors.correctText),
              ],
            ],
          ),
          const SizedBox(height: PassqlSpacing.sm),
          if (completed) ...[
            Text(
              '${data?.correctCount ?? 0} / $total 정답',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ] else if (available) ...[
            Text(
              '오늘의 $total문제',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            Text(
              '모두 같은 문제로 겨뤄요',
              style: PassqlTypography.subheadline.copyWith(color: colors.secondaryLabel),
            ),
          ] else ...[
            Text(
              '오늘의 세트를 준비 중이에요.\n문제 목록에서 풀어보세요.',
              style: PassqlTypography.subheadline.copyWith(color: colors.secondaryLabel),
            ),
          ],
          const SizedBox(height: PassqlSpacing.sm),
          PassqlButton(
            label: completed
                ? '결과와 순위 보기'
                : available
                ? '풀어보기'
                : '문제 풀기',
            onPressed: onTap,
            variant: PassqlButtonVariant.tinted,
            size: PassqlButtonSize.small,
          ),
        ],
      ),
    );
  }
}
