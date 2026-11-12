import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../design/design.dart';

/// 시험 형식 안내 (회차 목록 머리·시험 안내 공용): 숫자 요약 3칸 > 과목별 과락 기준 칸 > (시험 안내만) 불릿 3개
/// 숫자는 서버 examRule 에서만, 눌리는 모양(행·쉐브론·눌림 효과) 없음
class MockExamRuleRows extends StatelessWidget {
  const MockExamRuleRows({
    super.key,
    required this.rule,
    this.isDetailed = false,
  });

  final MockExamRule rule;

  /// 시험 안내: 자동 제출·이어 풀기·풀이 중 정답 없음까지
  final bool isDetailed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 숫자 요약 3칸 (칸 사이 세로 구분선, 높이는 가장 큰 칸 기준)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RuleFigure(
                      figure: '${rule.durationMinutes}분',
                      caption: '시험 시간',
                    ),
                    const _FigureDivider(),
                    _RuleFigure(
                      figure: '${rule.questionCount}문항',
                      caption: '문항당 ${rule.pointsPerQuestion}점',
                    ),
                    const _FigureDivider(),
                    _RuleFigure(
                      figure: '${rule.passScore}점',
                      caption: '합격 · ${rule.maxScore}점 만점',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 과락 기준은 경고색 없이 과목별로 넘어야 할 점수 (#1041)
        if (rule.subjects.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.sm),
          _SubjectCutoffCard(subjects: rule.subjects),
        ],
        if (isDetailed) ...[
          const SizedBox(height: PassqlSpacing.md),
          const _RuleNote(
            icon: CupertinoIcons.paperplane,
            title: '시간이 끝나면 자동 제출',
            description: '남은 시간은 서버 기준이라 기기 시각을 바꿔도 같아요',
          ),
          const SizedBox(height: PassqlSpacing.sm),
          const _RuleNote(
            icon: CupertinoIcons.arrow_clockwise,
            title: '나갔다 와도 이어서 풀어요',
            description: '답은 고를 때마다 저장되고, 시간은 계속 흘러요',
          ),
          const SizedBox(height: PassqlSpacing.sm),
          const _RuleNote(
            icon: CupertinoIcons.eye_slash,
            title: '풀이 중엔 정답·해설·SQL 실행이 없어요',
            description: '실제 시험처럼 머릿속으로 풀어요',
          ),
        ],
      ],
    );
  }
}

/// 과목별 과락 기준: 제목 + 한 줄 설명 > 과목마다 칸 (과목·문항 수 / 기준 점수 이상)
class _SubjectCutoffCard extends StatelessWidget {
  const _SubjectCutoffCard({required this.subjects});

  final List<MockExamSubjectRule> subjects;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '과목별 과락 기준',
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: colors.label,
            ),
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          PassqlKeepAllText(
            '한 과목이라도 기준 미만이면 총점과 상관없이 불합격이에요',
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          // 과목 칸 나란히 (높이는 가장 큰 칸 기준)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, subject) in subjects.indexed) ...[
                  if (index > 0) const SizedBox(width: PassqlSpacing.xs),
                  Expanded(child: _SubjectCutoffCell(subject: subject)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 과목 칸 하나: 과목 이름(작게) > 기준 점수 이상(굵게) > 문항 수·만점(작게)
class _SubjectCutoffCell extends StatelessWidget {
  const _SubjectCutoffCell({required this.subject});

  final MockExamSubjectRule subject;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      container: true,
      label:
          '${subject.name} ${subject.questionCount}문항 ${subject.maxScore}점 만점, ${subject.failBelowScore}점 이상',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // 카드·시트 위 옅은 칸 (라이트·다크 모두 회색 채움)
          color: colors.fill,
          borderRadius: BorderRadius.circular(PassqlRadius.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PassqlSpacing.sm,
            vertical: PassqlSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PassqlKeepAllText(
                subject.name,
                style: PassqlTypography.caption.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              const SizedBox(height: PassqlSpacing.hairlineGap),
              Text(
                '${subject.failBelowScore}점 이상',
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: colors.label,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
              Text(
                '${subject.questionCount}문항 · ${subject.maxScore}점 만점',
                style: PassqlTypography.caption.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 숫자 요약 한 칸: 큰 숫자 + 작은 설명 (가운데 정렬)
class _RuleFigure extends StatelessWidget {
  const _RuleFigure({required this.figure, required this.caption});

  final String figure;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 좁은 화면에서 숫자가 줄바꿈되지 않게 칸 폭에 맞춰 축소
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              figure,
              maxLines: 1,
              style: PassqlTypography.title3.copyWith(
                color: colors.label,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: PassqlTypography.caption.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// 숫자 칸 사이 세로 구분선
class _FigureDivider extends StatelessWidget {
  const _FigureDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: PassqlSpacing.xs,
      vertical: PassqlSpacing.xxs,
    ),
    child: SizedBox(
      width: PassqlSize.hairline,
      child: ColoredBox(color: context.passqlColors.separator),
    ),
  );
}

/// 시험 안내 불릿 한 줄: 작은 아이콘 + 제목 + 보조 설명 (아이콘 타일 없음)
class _RuleNote extends StatelessWidget {
  const _RuleNote({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // 아이콘을 제목 첫 줄 가운데에 맞춤
          padding: const EdgeInsets.only(top: PassqlSpacing.hairlineGap),
          child: Icon(
            icon,
            size: PassqlIconSize.sm,
            color: colors.iconSecondary,
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: colors.label,
                ),
              ),
              Text(
                description,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
