import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';

/// 카드 폭: 화면 폭보다 작게 잡아 가로 목록에서 다음 카드가 화면 끝에 걸쳐 보이게 함
const double _cardWidth = 236;

/// 카드 안쪽 높이: 머리 + 제목 2줄 + 하단 문구가 들어가고, 하단 문구는 이 높이의 맨 아래에 고정
const double _cardContentHeight = 136;

/// 제목 최대 줄 수
const int _titleMaxLines = 2;

/// 홈 가로 목록의 늘어난 유형 카드: 토픽 아이콘 + 회차 배지 + 제목 + 하단 "토픽명 문제 N개 >"
/// 문제 있는 유형만 탭 > 그 토픽 최신 경향 풀기, 없으면 하단 문구·탭 없음
class ExamTrendPatternCard extends StatelessWidget {
  const ExamTrendPatternCard({
    super.key,
    required this.pattern,
    required this.onSolveTopic,
  });

  final ExamTrendPattern pattern;
  final void Function(String topicCode, String topicName) onSolveTopic;

  /// 카드 전체 높이 (안쪽 높이 + 위아래 카드 여백): 가로 목록 높이 기준
  static const double totalHeight = _cardContentHeight + PassqlSpacing.md * 2;

  bool get _canSolve =>
      pattern.topicName != null && pattern.latestTrendQuestionCount > 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return SizedBox(
      width: _cardWidth,
      child: PassqlCard(
        onTap: _canSolve
            ? () => onSolveTopic(pattern.topicCode, pattern.topicName!)
            : null,
        child: SizedBox(
          height: _cardContentHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 머리 (토픽 아이콘, 근거 회차)
              Row(
                children: [
                  PassqlIconTile(
                    icon: topicIconFor(pattern.topicCode),
                    color: topicColorFor(
                      pattern.topicCode,
                      Theme.of(context).brightness,
                    ),
                  ),
                  const SizedBox(width: PassqlSpacing.xs),
                  Flexible(
                    child: PassqlBadge(
                      text: pattern.examRoundsText,
                      kind: PassqlBadgeKind.neutral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                pattern.title,
                maxLines: _titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: colors.label,
                ),
              ),
              const Spacer(),
              // 하단 고정: 풀 수 있을 때만
              if (_canSolve)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${pattern.topicName} 문제 ${pattern.latestTrendQuestionCount}개',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PassqlTypography.footnoteSemibold.copyWith(
                          color: colors.accent,
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      size: PassqlIconSize.xs,
                      color: colors.tertiaryLabel,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
