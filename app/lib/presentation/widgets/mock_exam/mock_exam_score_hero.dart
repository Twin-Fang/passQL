import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/mock_exam/mock_exam_result.dart';
import '../../design/design.dart';

/// 결과 첫 화면: 합격·불합격 마크 + 총점 + 이유 한 줄 + 제출 방식·푼 시간 + (응시자 10명 이상) 회차 순위
class MockExamScoreHero extends StatelessWidget {
  const MockExamScoreHero({super.key, required this.examResult});

  final MockExamResultResponse examResult;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final elapsedMinutes = (examResult.elapsedSeconds / 60).ceil();
    return Semantics(
      container: true,
      label:
          '${examResult.isPassed ? '합격' : '불합격'}, ${examResult.totalScore}점. ${_reasonOf(examResult)}${_rankingSemanticsOf(examResult.ranking)}',
      excludeSemantics: true,
      child: Column(
        children: [
          // 합격·불합격 마크 (화면 전환 뒤 톡 튀어나옴, 동작 줄이기면 정지)
          PassqlResultMark(
            isCorrect: examResult.isPassed,
            label: examResult.isPassed ? '합격' : '불합격',
            isLarge: true,
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          // 총점은 0에서 차오름 (#1041, 낭독은 위 Semantics 가 최종값)
          PassqlCountUp(
            value: examResult.totalScore,
            builder: (context, displayedScore) => Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$displayedScore',
                    style: PassqlTypography.scoreNumber.copyWith(
                      color: colors.label,
                    ),
                  ),
                  TextSpan(
                    text: ' / ${examResult.maxScore}점',
                    style: PassqlTypography.headline.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            _reasonOf(examResult),
            textAlign: TextAlign.center,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          Wrap(
            spacing: PassqlSpacing.xs,
            alignment: WrapAlignment.center,
            children: [
              PassqlBadge(
                text: '${examResult.correctCount} / ${examResult.questionCount} 정답',
                kind: PassqlBadgeKind.neutral,
              ),
              PassqlBadge(
                text: '$elapsedMinutes분 풀이',
                kind: PassqlBadgeKind.neutral,
                icon: CupertinoIcons.timer,
              ),
              if (examResult.submitReason == MockExamSubmitReason.timeUp)
                const PassqlBadge(
                  text: '시간 끝 자동 제출',
                  kind: PassqlBadgeKind.warning,
                ),
            ],
          ),
          if (examResult.ranking case final ranking?) ...[
            const SizedBox(height: PassqlSpacing.md),
            _RankingLine(ranking: ranking),
          ],
        ],
      ),
    );
  }

  /// 순위 낭독 문장 (순위 없으면 빈 글자)
  static String _rankingSemanticsOf(MockExamRanking? ranking) =>
      ranking == null
      ? ''
      : '. 이 회차 응시자 ${ranking.takerCount}명 중 ${ranking.rankPosition}위, 상위 ${ranking.topPercent}%';

  /// 이유 한 줄: 과락(과목명 있으면 함께) > 합격선까지 남은 점수 > 합격
  static String _reasonOf(MockExamResultResponse examResult) {
    switch (examResult.failReason) {
      case MockExamFailReason.subjectFail:
        final failedNames = examResult.subjects
            .where((subject) => subject.isFailed)
            .map((subject) => subject.name);
        return failedNames.isEmpty
            ? '과락 과목이 있어 총점과 상관없이 불합격이에요'
            : '${failedNames.join(', ')} 과락이라 총점과 상관없이 불합격이에요';
      case MockExamFailReason.totalScoreBelow:
        return '합격선 ${examResult.passScore}점까지 ${examResult.passScore - examResult.totalScore}점 남았어요';
      case MockExamFailReason.none || MockExamFailReason.unknown:
        return '합격선 ${examResult.passScore}점을 넘었어요';
    }
  }
}

/// 회차 순위 한 줄 (#1041 A안): 위 구분선 > 상위 N%(강조) > 응시자 수 중 순위
class _RankingLine extends StatelessWidget {
  const _RankingLine({required this.ranking});

  final MockExamRanking ranking;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      children: [
        Container(height: PassqlSize.hairline, color: colors.separator),
        const SizedBox(height: PassqlSpacing.sm),
        Text(
          '상위 ${ranking.topPercent}%',
          style: PassqlTypography.headline.copyWith(color: colors.accentText),
        ),
        const SizedBox(height: PassqlSpacing.hairlineGap),
        Text(
          '이 회차 응시자 ${ranking.takerCount}명 중 ${ranking.rankPosition}위',
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}
