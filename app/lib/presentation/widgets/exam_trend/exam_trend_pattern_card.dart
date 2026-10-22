import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';

/// 카드 안쪽 여백
const double _cardPadding = PassqlSpacing.lg;

/// 글자 배율 1.0 기준 카드 안쪽 높이: 배지 24 + 12 + 제목 2줄 56 + 8 + 설명 2줄 40 + 최소 12 + 하단 20
const double _baseCardContentHeight = 172;

/// 배율 따라 늘어나는 글자 줄 (배지 1줄, 제목 2줄, 설명 2줄, 하단 1줄): (스타일, 줄 수)
final List<(TextStyle, int)> _scalingTextLines = [
  (PassqlTypography.captionSemibold, 1),
  (PassqlTypography.title2, _titleMaxLines),
  (PassqlTypography.subheadline, _descriptionMaxLines),
  (PassqlTypography.subheadlineSemibold, 1),
];

/// 제목 최대 줄 수
const int _titleMaxLines = 2;

/// 설명 최대 줄 수
const int _descriptionMaxLines = 2;

/// 강조색 바탕 위 보조 글자·배지 바탕 불투명도
const double _secondaryTextAlpha = 0.85;
const double _badgeBackgroundAlpha = 0.2;

/// 홈 출제 경향 넘김 카드 1장: 강조색 바탕 + '늘어난 유형' 배지 + 유형 이름 + 설명 + 하단 '이 유형 풀기 >'
/// 숫자(회차·문항 수) 없음, 문제 있는 유형만 탭 > 그 토픽 최신 경향 풀기
class ExamTrendPatternCard extends StatelessWidget {
  const ExamTrendPatternCard({
    super.key,
    required this.pattern,
    required this.onSolveTopic,
  });

  final ExamTrendPattern pattern;
  final void Function(String topicCode, String topicName) onSolveTopic;

  /// 머리 배지 문구 원본
  static const String risingBadgeLabel = '늘어난 유형';

  /// 하단 풀기 문구 원본
  static const String solveLabel = '이 유형 풀기';

  /// 카드 전체 높이 (안쪽 높이 + 위아래 여백): 넘김 목록 높이 기준, 글자 배율 반영
  static double totalHeightOf(BuildContext context) =>
      _contentHeightOf(MediaQuery.textScalerOf(context)) + _cardPadding * 2;

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
    final secondaryTextColor = colors.onAccent.withValues(
      alpha: _secondaryTextAlpha,
    );
    final cardBody = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: SizedBox(
        height: _contentHeightOf(MediaQuery.textScalerOf(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRisingBadge(colors),
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              pattern.title,
              maxLines: _titleMaxLines,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.title2.copyWith(color: colors.onAccent),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              pattern.description,
              maxLines: _descriptionMaxLines,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.subheadline.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const Spacer(),
            // 하단 고정: 풀 수 있을 때만
            if (_canSolve)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    solveLabel,
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.onAccent,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    size: PassqlIconSize.xs,
                    color: colors.onAccent,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    if (!_canSolve) return cardBody;
    return PassqlPressable(
      onTap: () => onSolveTopic(pattern.topicCode, pattern.topicName!),
      semanticLabel: '${pattern.title}, ${pattern.description}, $solveLabel',
      child: cardBody,
    );
  }

  /// '늘어난 유형' 캡슐 (강조색 위 반투명 흰 바탕)
  Widget _buildRisingBadge(PassqlColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: PassqlSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.onAccent.withValues(alpha: _badgeBackgroundAlpha),
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Text(
        risingBadgeLabel,
        style: PassqlTypography.captionSemibold.copyWith(
          color: colors.onAccent,
        ),
      ),
    );
  }
}
