import 'package:flutter/cupertino.dart';
import '../../../data/models/daily_set/daily_set_models.dart';
import '../../design/design.dart';

/// 홈 첫 구간 안 오늘의 세트: (완료 결과) > 버튼. 제목·순위 링크는 홈의 구간 제목 줄, 랜덤 풀기는 홈의 별도 구간 (#966)
///
/// 상태는 세 가지다: 풀 수 있음 / 이미 완료 / 준비 중(불러오지 못한 경우 포함).
/// 구간 면은 홈 화면이 감싼다 (이 위젯은 내용만).
class DailySetSection extends StatelessWidget {
  const DailySetSection({
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
    // 완료 기록의 문제별 정답 여부 (answeredResults 는 풀다 만 세트용이라 쓰지 않음)
    final results = data?.results;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 버튼이 구간의 주인공 (#701). 다 푼 날만 결과를 버튼 위에
        if (completed) ...[
          // 큰 점수 + 오른쪽 완료 배지
          Semantics(
            label: '오늘의 세트 완료, $total문제 중 ${data?.correctCount ?? 0}개 정답',
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${data?.correctCount ?? 0}',
                          style: PassqlTypography.title1.copyWith(
                            color: colors.label,
                          ),
                        ),
                        TextSpan(
                          text: ' / $total 정답',
                          style: PassqlTypography.subheadlineSemibold.copyWith(
                            color: colors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PassqlBadge(text: '완료', kind: PassqlBadgeKind.success),
              ],
            ),
          ),
          if (results != null && results.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            _ResultMarks(results: results),
          ],
          const SizedBox(height: PassqlSpacing.sm),
        ] else if (!available) ...[
          PassqlKeepAllText(
            '오늘의 세트를 준비 중이에요.\n문제 목록에서 풀어보세요.',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
        ],
        // 홈에서 유일한 채운 버튼 (한 화면 한 강조)
        PassqlButton(
          label: completed
              ? '결과 보기'
              : available
              ? '오늘의 세트 풀기'
              : '문제 풀기',
          onPressed: completed
              ? onViewResult
              : available
              ? onStart
              : onBrowse,
        ),
      ],
    );
  }
}

/// 다 푼 날 문제별 정답·오답 칸 (보여주기만, 누르지 않음 #701)
/// 응답이 없는 문제(null)는 빈 칸
class _ResultMarks extends StatelessWidget {
  const _ResultMarks({required this.results});

  final List<bool?> results;

  // 칸 높이: 아이콘(xs)이 위아래 여유를 두고 들어가는 최소 높이
  static const double _cellHeight = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final correct = results.where((r) => r == true).length;
    final wrong = results.where((r) => r == false).length;
    return Semantics(
      label: '문제별 결과, 정답 $correct개 오답 $wrong개',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < results.length; i++) ...[
            if (i > 0) const SizedBox(width: PassqlSpacing.xxs),
            Expanded(
              child: Container(
                height: _cellHeight,
                decoration: BoxDecoration(
                  color: switch (results[i]) {
                    true => colors.correctTint,
                    false => colors.wrongTint,
                    null => colors.fill,
                  },
                  borderRadius: BorderRadius.circular(PassqlRadius.sm),
                ),
                child: switch (results[i]) {
                  true => Icon(
                    CupertinoIcons.checkmark,
                    size: PassqlIconSize.xs,
                    color: colors.correctText,
                  ),
                  false => Icon(
                    CupertinoIcons.xmark,
                    size: PassqlIconSize.xs,
                    color: colors.wrongText,
                  ),
                  null => null,
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
