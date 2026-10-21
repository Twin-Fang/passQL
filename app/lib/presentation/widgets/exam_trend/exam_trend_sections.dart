import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';

// 출제 경향 화면 조각 (#523): 요약 카드, 과목 비중, 늘어난 유형, 자주 나오는 개념, 공부 팁

/// 백분율 > 진행 막대 값 (0~1)
const double _percentDenominator = 100;

/// 순위 숫자 칸 폭 (두 자리 순위까지 제목 시작선이 같도록)
const double _rankColumnWidth = 32;

/// 강조색으로 그리는 상위 순위 수 (1~3위)
const int _highlightedRankCount = 3;

/// 요약 카드: 최신 경향 배지 + 제목 + 근거 회차 + 요약 + 풀 수 있는 최신 경향 문제 수
class ExamTrendSummaryCard extends StatelessWidget {
  const ExamTrendSummaryCard({super.key, required this.report});

  final ExamTrendReportResponse report;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PassqlLatestTrendBadge(),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            report.title,
            style: PassqlTypography.title2.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            '${report.basisDescription} · ${report.updatedDate} 갱신',
            style: PassqlTypography.caption.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          Text(
            report.summary,
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
          ),
          if (report.latestTrendQuestionCount > 0) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              '최신 경향 문제 ${report.latestTrendQuestionCount}개를 풀 수 있어요',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 과목별 비중: 과목명 + 문항 수·백분율 + 진행 막대 + 설명
class ExamTrendSubjectShareSection extends StatelessWidget {
  const ExamTrendSubjectShareSection({super.key, required this.subjectShares});

  final List<ExamTrendSubjectShare> subjectShares;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlGroupedSection(
      header: '과목별 비중',
      children: [
        for (final subjectShare in subjectShares)
          Padding(
            padding: const EdgeInsets.all(PassqlSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subjectShare.subjectName,
                        style: PassqlTypography.subheadlineSemibold.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    Text(
                      '${subjectShare.questionCount}문항 · ${subjectShare.percent}%',
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                        fontFeatures: PassqlTypography.tabular,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xs),
                PassqlProgressBar(
                  value: subjectShare.percent / _percentDenominator,
                ),
                const SizedBox(height: PassqlSpacing.xs),
                Text(
                  subjectShare.description,
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

/// 늘어난 유형 목록: 유형명 + 근거 회차 + 설명 + (문제 있으면) 풀기 안내
class ExamTrendPatternSection extends StatelessWidget {
  const ExamTrendPatternSection({
    super.key,
    required this.patterns,
    required this.onSolveTopic,
  });

  final List<ExamTrendPattern> patterns;
  final void Function(String topicCode, String topicName) onSolveTopic;

  @override
  Widget build(BuildContext context) {
    return PassqlGroupedSection(
      header: '최근 회차에서 늘어난 유형',
      children: [
        for (final pattern in patterns)
          ExamTrendSolvableRow(
            title: pattern.title,
            caption: pattern.examRoundsText,
            description: pattern.description,
            topicCode: pattern.topicCode,
            topicName: pattern.topicName,
            latestTrendQuestionCount: pattern.latestTrendQuestionCount,
            onSolveTopic: onSolveTopic,
          ),
      ],
    );
  }
}

/// 자주 나오는 개념 순위: 순위 + 개념명 + 빈도 + 설명 + (문제 있으면) 풀기 안내
class ExamTrendConceptSection extends StatelessWidget {
  const ExamTrendConceptSection({
    super.key,
    required this.concepts,
    required this.onSolveTopic,
    this.totalConceptCount,
    this.shouldShowHeader = true,
    this.shouldShowFooter = true,
  });

  final List<ExamTrendConcept> concepts;
  final void Function(String topicCode, String topicName) onSolveTopic;

  /// 머리글 개수 (목록을 둘로 나눠 그릴 때 전체 개수, 없으면 [concepts] 개수)
  final int? totalConceptCount;

  /// 머리글·안내 문구 표시 (나눠 그린 묶음은 한쪽씩만 표시)
  final bool shouldShowHeader;
  final bool shouldShowFooter;

  @override
  Widget build(BuildContext context) {
    return PassqlGroupedSection(
      header: shouldShowHeader
          ? '자주 나오는 개념 TOP ${totalConceptCount ?? concepts.length}'
          : null,
      footer: shouldShowFooter ? '최근 4회(58·60·61·62회) 합산 출제 문항 수 기준' : null,
      children: [
        for (final concept in concepts)
          ExamTrendSolvableRow(
            title: concept.name,
            rank: concept.rank,
            caption: concept.frequencyText,
            description: concept.description,
            topicCode: concept.topicCode,
            topicName: concept.topicName,
            latestTrendQuestionCount: concept.latestTrendQuestionCount,
            onSolveTopic: onSolveTopic,
          ),
      ],
    );
  }
}

/// 유형·개념 공통 행. 최신 경향 문제가 있으면 탭 > 그 토픽 최신 경향 풀기, 없으면 정보만
class ExamTrendSolvableRow extends StatelessWidget {
  const ExamTrendSolvableRow({
    super.key,
    required this.title,
    required this.caption,
    required this.description,
    required this.topicCode,
    required this.topicName,
    required this.latestTrendQuestionCount,
    required this.onSolveTopic,
    this.rank,
  });

  final String title;
  final String caption;
  final String description;
  final String topicCode;
  final String? topicName;
  final int latestTrendQuestionCount;
  final void Function(String topicCode, String topicName) onSolveTopic;

  /// 순위 (있으면 왼쪽에 큰 숫자, 1~3위만 강조색)
  final int? rank;

  bool get _canSolve => topicName != null && latestTrendQuestionCount > 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final row = Padding(
      padding: const EdgeInsets.all(PassqlSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rank != null) ...[
            SizedBox(
              width: _rankColumnWidth,
              child: Text(
                '$rank',
                style: PassqlTypography.title2.copyWith(
                  color: rank! <= _highlightedRankCount
                      ? colors.accent
                      : colors.secondaryLabel,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: PassqlTypography.subheadlineSemibold.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    const SizedBox(width: PassqlSpacing.xs),
                    PassqlBadge(text: caption, kind: PassqlBadgeKind.neutral),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xxs),
                Text(
                  description,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                if (_canSolve) ...[
                  const SizedBox(height: PassqlSpacing.xs),
                  Text(
                    '$topicName 최신 경향 문제 $latestTrendQuestionCount개 풀기',
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_canSolve) ...[
            const SizedBox(width: PassqlSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
              child: Icon(
                CupertinoIcons.chevron_forward,
                size: PassqlIconSize.xs,
                color: colors.tertiaryLabel,
              ),
            ),
          ],
        ],
      ),
    );
    if (!_canSolve) return row;
    return PassqlPressable(
      onTap: () => onSolveTopic(topicCode, topicName!),
      semanticLabel: '$title, $topicName 최신 경향 문제 풀기',
      child: row,
    );
  }
}

/// 공부 팁 목록 (점 머리 문단)
class ExamTrendStudyTipSection extends StatelessWidget {
  const ExamTrendStudyTipSection({super.key, required this.studyTips});

  final List<String> studyTips;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlGroupedSection(
      header: '공부 팁',
      children: [
        for (final studyTip in studyTips)
          Padding(
            padding: const EdgeInsets.all(PassqlSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: PassqlSpacing.hairlineGap,
                  ),
                  child: Icon(
                    CupertinoIcons.lightbulb_fill,
                    size: PassqlIconSize.sm,
                    color: colors.warning,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Expanded(
                  child: Text(
                    studyTip,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
