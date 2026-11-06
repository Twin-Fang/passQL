import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/mock_exam/mock_exam_result.dart';
import '../../design/design.dart';

/// 결과 첫 화면: 합격·불합격 마크 + 총점 + 이유 한 줄 + 제출 방식·푼 시간
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
          '${examResult.isPassed ? '합격' : '불합격'}, ${examResult.totalScore}점. ${_reasonOf(examResult)}',
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
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${examResult.totalScore}',
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
        ],
      ),
    );
  }

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
