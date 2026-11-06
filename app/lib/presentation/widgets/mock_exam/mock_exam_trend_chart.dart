import 'package:flutter/widgets.dart';

import '../../../data/models/mock_exam/mock_exam_result.dart';
import '../../design/design.dart';

/// 점수 추이 막대: 응시마다 막대(합격 초록·불합격 빨강) + 점수 + 회차, 합격선 점선 위치 표시
/// 최근 [_maxBarCount] 회만, 막대 탭 > 그 응시 결과
class MockExamTrendChart extends StatelessWidget {
  const MockExamTrendChart({
    super.key,
    required this.history,
    required this.onAttemptTap,
  });

  final MockExamHistoryResponse history;
  final void Function(String attemptUuid) onAttemptTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final attempts = history.attempts.length > _maxBarCount
        ? history.attempts.sublist(history.attempts.length - _maxBarCount)
        : history.attempts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _chartHeight,
          child: Stack(
            children: [
              // 합격선 (만점 100 기준 높이)
              Positioned(
                left: 0,
                right: 0,
                bottom:
                    (_chartHeight - _scoreLabelSpace) *
                    history.passScore /
                    _maxScore,
                child: Container(
                  height: PassqlSize.hairline,
                  color: colors.secondaryLabel,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final attempt in attempts)
                    Expanded(
                      child: PassqlPressable(
                        onTap: () => onAttemptTap(attempt.attemptUuid),
                        semanticLabel:
                            '제${attempt.roundNumber}회 ${attempt.totalScore}점, '
                            '${attempt.isPassed ? '합격' : '불합격'}',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${attempt.totalScore}',
                              style: PassqlTypography.captionSemibold.copyWith(
                                fontFeatures: PassqlTypography.tabular,
                                color: attempt.isPassed
                                    ? colors.correctText
                                    : colors.wrongText,
                              ),
                            ),
                            const SizedBox(height: PassqlSpacing.xxs),
                            Container(
                              width: _barWidth,
                              height:
                                  (_chartHeight - _scoreLabelSpace) *
                                  attempt.totalScore /
                                  _maxScore,
                              decoration: BoxDecoration(
                                color: attempt.isPassed
                                    ? colors.correct
                                    : colors.wrong,
                                borderRadius: BorderRadius.circular(
                                  PassqlRadius.sm,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        Row(
          children: [
            for (final attempt in attempts)
              Expanded(
                child: Text(
                  '${attempt.roundNumber}회',
                  textAlign: TextAlign.center,
                  style: PassqlTypography.caption.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xs),
        Text(
          '가로선은 합격선 ${history.passScore}점이에요',
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}

// 막대 영역 높이 (논리 픽셀)
const double _chartHeight = 140;
// 막대 위 점수 글자 자리 (논리 픽셀)
const double _scoreLabelSpace = 24;
// 막대 폭 (논리 픽셀)
const double _barWidth = 20;
// 막대 높이 기준 만점
const int _maxScore = 100;
// 보여 줄 최근 응시 수
const int _maxBarCount = 8;
