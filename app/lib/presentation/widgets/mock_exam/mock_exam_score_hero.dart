import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/mock_exam/mock_exam_result.dart';
import '../../design/design.dart';

/// 결과 첫 화면: 판정(의미색 글자) > 총점(차오름) > 이유 한 줄 > 목록 묶음(정답 수, 풀이 시간, 회차 순위)
/// 가채점 결과(ExamAnswerScoreResult)와 같은 글자·목록 행 구성, 큰 마크·알약 칩 없음 (#1126, DEC-0321)
class MockExamScoreHero extends StatelessWidget {
  const MockExamScoreHero({super.key, required this.examResult});

  final MockExamResultResponse examResult;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final elapsedMinutes = (examResult.elapsedSeconds / 60).ceil();
    final isTimeUp = examResult.submitReason == MockExamSubmitReason.timeUp;
    final ranking = examResult.ranking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 판정 + 총점 + 이유 (장식 아이콘 없이 글자만)
        Semantics(
          container: true,
          label:
              '${_verdictOf(examResult)}, ${examResult.totalScore}점. ${_reasonOf(examResult)}',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _verdictOf(examResult),
                style: PassqlTypography.headline.copyWith(
                  color: examResult.isPassed
                      ? colors.correctText
                      : colors.wrongText,
                ),
              ),
              // 총점은 0에서 차오름 (#1041, 낭독은 위 Semantics 가 최종값)
              PassqlCountUp(
                value: examResult.totalScore,
                builder: (context, displayedScore) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$displayedScore',
                        style: PassqlTypography.scoreNumber.copyWith(
                          fontFeatures: PassqlTypography.tabular,
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
              const SizedBox(height: PassqlSpacing.xxs),
              Text(
                _reasonOf(examResult),
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.lg),
        // 정답 수 > 풀이 시간(시간 끝 자동 제출이면 보조 줄) > 순위(응시자 10명 이상)
        PassqlGroupedSection(
          children: [
            PassqlListRow(
              title: '정답',
              trailing: Text(
                '${examResult.correctCount} / ${examResult.questionCount}문항',
              ),
            ),
            PassqlListRow(
              title: '풀이 시간',
              subtitle: isTimeUp ? '시간이 끝나 자동 제출했어요' : null,
              trailing: Text('$elapsedMinutes분'),
            ),
            if (ranking != null)
              PassqlListRow(
                title: '응시자 중 순위',
                subtitle:
                    '이 회차 응시자 ${ranking.takerCount}명 중 ${ranking.rankPosition}위',
                trailing: Text('상위 ${ranking.topPercent}%'),
              ),
          ],
        ),
      ],
    );
  }

  /// 판정 글자: 합격·불합격
  static String _verdictOf(MockExamResultResponse examResult) =>
      examResult.isPassed ? '합격' : '불합격';

  /// 이유 한 줄: 과락(과목명 있으면 함께) > 서버 합격선 여유 문장(#1111) > (옛 서버) 합격선까지 남은 점수·합격
  static String _reasonOf(MockExamResultResponse examResult) {
    if (examResult.failReason != MockExamFailReason.subjectFail &&
        examResult.passMarginText.isNotEmpty) {
      return examResult.passMarginText;
    }
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
