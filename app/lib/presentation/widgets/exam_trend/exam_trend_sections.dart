import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';

// 문제 탭 최신 경향·개념 TOP 10 보기 조각 (#523): 요약, 과목 비중, 늘어난 유형, 자주 나오는 개념, 공부 팁
// 홈처럼 좌우 끝까지 닿는 구간 + 작은 색 타일 제목 (#726). 구간 사이 띠는 보기 쪽에서 둔다

/// 백분율 > 진행 막대 값 (0~1)
const double _percentDenominator = 100;

/// 순위 숫자 칸 폭 (두 자리 순위까지 제목 시작선이 같도록)
const double _rankColumnWidth = 32;

/// 강조색으로 그리는 상위 순위 수 (1~3위)
const int _highlightedRankCount = 3;

/// 행 위아래 여백: 행 사이에만 md (첫 행 위·끝 행 아래는 구간 여백이 맡음)
EdgeInsets _rowPaddingAt(int index, int count) => EdgeInsets.only(
  top: index == 0 ? 0 : PassqlSpacing.md,
  bottom: index == count - 1 ? 0 : PassqlSpacing.md,
);

/// 경향 구간 틀: 작은 색 타일 + 15pt 제목, 행 사이 구분선 (들여쓰기 없음)
class _TrendSection extends StatelessWidget {
  const _TrendSection({
    this.title,
    this.icon,
    this.tileColor,
    this.subtitle,
    required this.rows,
  });

  /// 없으면 제목 없는 구간 (개념 TOP 10 광고 뒤 6~10위)
  final String? title;
  final IconData? icon;
  final Color? tileColor;

  /// 제목 아래 한 줄 (분석 근거·갱신일)
  final String? subtitle;

  /// 위아래 여백 없는 행. 여백은 여기서 위치별로 준다
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final children = <Widget>[
      if (subtitle != null) ...[
        Text(
          subtitle!,
          style: PassqlTypography.caption.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
      ],
    ];
    for (final (index, row) in rows.indexed) {
      if (index > 0) {
        children.add(
          Container(height: PassqlSize.hairline, color: colors.separator),
        );
      }
      children.add(
        Padding(padding: _rowPaddingAt(index, rows.length), child: row),
      );
    }
    return PassqlSection(
      title: title,
      isCompactTitle: true,
      leading: icon == null
          ? null
          : PassqlIconTile(icon: icon!, color: tileColor!, isCompact: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// 팔레트 색조(blue·yellow) > 지금 화면 모드 색. 앱 색 토큰에 없는 제목 타일 색
Color _hueOf(BuildContext context, String hue) =>
    systemHueColor(hue, context.isDark ? Brightness.dark : Brightness.light);

/// 최신 경향 요약: 요약 문장 + 분석 근거·갱신일 (예전 '최신 경향' 칩은 제목 타일로 대체)
class ExamTrendSummarySection extends StatelessWidget {
  const ExamTrendSummarySection({super.key, required this.report});

  final ExamTrendReportResponse report;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return _TrendSection(
      title: '최신 경향',
      icon: CupertinoIcons.flame_fill,
      tileColor: colors.warning,
      rows: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.summary,
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            Text(
              '${report.basisDescription} · ${report.updatedDate} 갱신',
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 과목별 비중: 과목명 + 백분율 + 진행 막대 + 설명 (문항 수는 숨김)
class ExamTrendSubjectShareSection extends StatelessWidget {
  const ExamTrendSubjectShareSection({super.key, required this.subjectShares});

  final List<ExamTrendSubjectShare> subjectShares;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return _TrendSection(
      title: '과목별 비중',
      icon: CupertinoIcons.chart_pie_fill,
      tileColor: _hueOf(context, 'blue'),
      rows: [
        for (final subjectShare in subjectShares)
          Column(
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
                    '${subjectShare.percent}%',
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
    return _TrendSection(
      title: '최근 회차에서 늘어난 유형',
      icon: CupertinoIcons.arrow_up_right,
      tileColor: context.passqlColors.correct,
      rows: [
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
    this.basisCaption,
  });

  final List<ExamTrendConcept> concepts;
  final void Function(String topicCode, String topicName) onSolveTopic;

  /// 제목 개수 (목록을 둘로 나눠 그릴 때 전체 개수, 없으면 [concepts] 개수)
  final int? totalConceptCount;

  /// 제목 표시 (광고 뒤 이어지는 묶음은 제목 없이)
  final bool shouldShowHeader;

  /// 제목 아래 분석 근거·갱신일 한 줄 (서버 값, 예전 고정 문구 '최근 4회' 대체)
  final String? basisCaption;

  @override
  Widget build(BuildContext context) {
    return _TrendSection(
      title: shouldShowHeader
          ? '자주 나오는 개념 TOP ${totalConceptCount ?? concepts.length}'
          : null,
      icon: shouldShowHeader ? CupertinoIcons.list_number : null,
      tileColor: context.passqlColors.accent,
      subtitle: shouldShowHeader ? basisCaption : null,
      rows: [
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
/// 위아래 여백은 감싸는 구간이 위치별로 준다
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
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rank != null) ...[
          SizedBox(
            width: _rankColumnWidth,
            // 두 자리 순위도 한 줄 유지 (넘치면 축소)
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$rank',
                maxLines: 1,
                softWrap: false,
                style: PassqlTypography.title2.copyWith(
                  color: rank! <= _highlightedRankCount
                      ? colors.accentText
                      : colors.secondaryLabel,
                  fontFeatures: PassqlTypography.tabular,
                ),
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
                    color: colors.accentText,
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
    );
    if (!_canSolve) return row;
    return PassqlPressable(
      onTap: () => onSolveTopic(topicCode, topicName!),
      // 화면 글자(순위·제목·근거·설명·문제 수)를 한 문장으로
      semanticLabel: [
        if (rank != null) '$rank위',
        title,
        caption,
        description,
        '$topicName 최신 경향 문제 $latestTrendQuestionCount개 풀기',
      ].join(', '),
      child: row,
    );
  }
}

/// 공부 팁 목록 (문단만, 전구는 제목 타일이 맡음)
class ExamTrendStudyTipSection extends StatelessWidget {
  const ExamTrendStudyTipSection({super.key, required this.studyTips});

  final List<String> studyTips;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return _TrendSection(
      title: '공부 팁',
      icon: CupertinoIcons.lightbulb_fill,
      tileColor: _hueOf(context, 'yellow'),
      rows: [
        for (final studyTip in studyTips)
          Text(
            studyTip,
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
          ),
      ],
    );
  }
}
