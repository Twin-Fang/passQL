import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';

/// 카드 폭: 화면 폭보다 작게 잡아 가로 목록에서 다음 카드가 화면 끝에 걸쳐 보이게 함
const double _cardWidth = 236;

/// 글자 배율 1.0 기준 카드 안쪽 높이: 머리 + 제목 1줄 + 설명 2줄 + 하단 문구, 하단 문구는 맨 아래 고정
const double _baseCardContentHeight = 136;

/// 배율 따라 늘어나는 글자 줄 (머리 배지 1줄, 제목 1줄, 설명 2줄, 하단 1줄): (스타일, 줄 수)
final List<(TextStyle, int)> _scalingTextLines = [
  (PassqlTypography.captionSemibold, 1),
  (PassqlTypography.subheadlineSemibold, _titleMaxLines),
  (PassqlTypography.footnote, _descriptionMaxLines),
  (PassqlTypography.footnoteSemibold, 1),
];

/// 제목 최대 줄 수
const int _titleMaxLines = 1;

/// 설명 최대 줄 수
const int _descriptionMaxLines = 2;

/// 홈 가로 목록의 늘어난 유형 카드: 토픽 아이콘 + 회차 배지 + 제목 + 설명 + 하단 "토픽명 문제 N개 >"
/// 문제 있는 유형만 탭 > 그 토픽 최신 경향 풀기, 없으면 하단 문구·탭 없음
class ExamTrendPatternCard extends StatelessWidget {
  const ExamTrendPatternCard({
    super.key,
    required this.pattern,
    required this.onSolveTopic,
  });

  final ExamTrendPattern pattern;
  final void Function(String topicCode, String topicName) onSolveTopic;

  /// 카드 전체 높이 (안쪽 높이 + 위아래 카드 여백): 가로 목록 높이 기준, 글자 배율 반영
  static double totalHeightOf(BuildContext context) =>
      _contentHeightOf(MediaQuery.textScalerOf(context)) + PassqlSpacing.md * 2;

  /// 안쪽 높이 = 1.0 기준 높이 + 글자 줄마다 (배율 적용 줄 높이 - 1.0 줄 높이), 글자 배율 따라 늘어남
  static double _contentHeightOf(TextScaler textScaler) {
    var extraHeight = 0.0;
    for (final (style, lineCount) in _scalingTextLines) {
      final fontSize = style.fontSize!;
      final lineHeightRatio = style.height ?? 1;
      extraHeight +=
          (textScaler.scale(fontSize) - fontSize) * lineHeightRatio * lineCount;
    }
    return _baseCardContentHeight + extraHeight;
  }

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
          height: _contentHeightOf(MediaQuery.textScalerOf(context)),
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
              const SizedBox(height: PassqlSpacing.xxs),
              Text(
                pattern.description,
                maxLines: _descriptionMaxLines,
                overflow: TextOverflow.ellipsis,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
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
                          color: colors.accentText,
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
