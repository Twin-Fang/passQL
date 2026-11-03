import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_unit_progress.dart';
import '../../design/design.dart';
import 'concept_result_head_delegate.dart';
import 'concept_result_timeline.dart';
import 'concept_rise_in.dart';
import 'concept_unit_progress_row.dart';

/// 결과 본문 (흰 면 하나): 접히는 머리 > 다시 볼 문제 목록 > 단원 줄 > 실전 문제 줄. 연출 시각 [elapsed] 기준으로 차례로 나타남
class ConceptResultBody extends StatelessWidget {
  const ConceptResultBody({
    super.key,
    required this.timeline,
    required this.elapsed,
    required this.correctFlags,
    required this.unitProgress,
    required this.relatedQuestionCount,
    required this.onRelatedQuestionsPressed,
    required this.buildWrongRow,
  });

  final ConceptResultTimeline timeline;
  final Duration elapsed;

  /// 문제 순서대로 맞힘 여부
  final List<bool> correctFlags;
  final ConceptUnitProgress? unitProgress;
  final int relatedQuestionCount;
  final VoidCallback? onRelatedQuestionsPressed;

  /// 틀린 문제 줄 (문제 순번 > 줄 위젯)
  final Widget Function(int questionIndex) buildWrongRow;

  bool get _hasUnitIncrease => unitProgress?.hasIncrease ?? false;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isHeadlineVisible = elapsed >= timeline.headlineAt;
    // 단원을 다 끝냈으면 단원 숫자가 바뀌는 순간 제목도 단원 끝으로 바뀜
    final isUnitHeadline =
        timeline.isUnitCompleted && elapsed >= timeline.unitRollAt;
    // 결과 한 장은 회색 띠로 나누지 않고 흰 면 하나에 이어서 둔다
    return ColoredBox(
      color: colors.card,
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ConceptResultHeadDelegate(
              timeline: timeline,
              elapsed: elapsed,
              correctFlags: correctFlags,
              isHeadlineVisible: isHeadlineVisible,
              unitProgress: unitProgress,
              isUnitHeadline: isUnitHeadline,
              backgroundColor: colors.card,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              0,
              PassqlSpacing.md,
              PassqlSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ..._buildWrongSection(isHeadlineVisible),
                ..._buildUnitSection(),
                ..._buildRelatedSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// 다시 볼 문제: 구간 제목 > 틀린 문제 줄 차례로 (틀린 문제 없으면 없음)
  List<Widget> _buildWrongSection(bool isHeadlineVisible) {
    final wrongIndexes = [
      for (var index = 0; index < correctFlags.length; index++)
        if (!correctFlags[index]) index,
    ];
    if (wrongIndexes.isEmpty) return const [];
    return [
      const SizedBox(height: PassqlSpacing.md),
      ConceptRiseIn(
        isVisible: isHeadlineVisible,
        child: _SectionTitle(title: '다시 볼 문제', count: wrongIndexes.length),
      ),
      for (final (position, index) in wrongIndexes.indexed) ...[
        if (position > 0) const _Hairline(),
        ConceptRiseIn(
          isVisible: elapsed >= timeline.rowAt(position),
          child: buildWrongRow(index),
        ),
      ],
    ];
  }

  /// 단원 줄: +1 > 숫자 굴림 > 새 칸 튐 (단원 값 없으면 없음)
  List<Widget> _buildUnitSection() {
    final unit = unitProgress;
    if (unit == null) return const [];
    return [
      const SizedBox(height: PassqlSpacing.xl),
      ConceptUnitProgressRow(
        unit: unit,
        isPlusVisible:
            _hasUnitIncrease &&
            elapsed >= timeline.unitPlusAt &&
            elapsed < timeline.unitRollAt,
        isRolled: !_hasUnitIncrease || elapsed >= timeline.unitRollAt,
        // 새로 찬 칸이 한 번 커졌다 돌아오는 진행(0 > 1)
        pulse: ConceptRingTimeline.progressBetween(
          elapsed,
          timeline.unitRollAt,
          timeline.unitRollAt + PassqlMotion.emphasized,
        ),
      ),
    ];
  }

  /// 실전 문제 줄: 버튼과 같은 때 나타나고 그 전에는 누를 수 없음 (관련 문제 없으면 없음)
  List<Widget> _buildRelatedSection() {
    final hasRelatedQuestions =
        relatedQuestionCount > 0 && onRelatedQuestionsPressed != null;
    if (!hasRelatedQuestions) return const [];
    final isButtonsVisible = elapsed >= timeline.buttonsAt;
    return [
      const SizedBox(height: PassqlSpacing.xs),
      ConceptRiseIn(
        isVisible: isButtonsVisible,
        child: PassqlListRow(
          hasHorizontalPadding: false,
          title: '실전 문제 $relatedQuestionCount개 더 풀기',
          hasChevron: true,
          onTap: isButtonsVisible ? onRelatedQuestionsPressed : null,
        ),
      ),
    ];
  }
}

/// 구간 제목: "다시 볼 문제" + 보라 개수
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: PassqlSpacing.xxs),
      child: Text.rich(
        TextSpan(
          text: '$title ',
          style: PassqlTypography.title3.copyWith(color: colors.label),
          children: [
            TextSpan(
              text: '$count',
              style: TextStyle(
                color: colors.accentText,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 줄 사이 머리카락 선 (iOS 목록과 같은 1물리픽셀)
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 0, thickness: 0, color: context.passqlColors.separator);
}
