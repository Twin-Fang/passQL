import 'package:flutter/cupertino.dart';

import '../../../core/utils/question_difficulty.dart';

import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';

/// 최근 회차 이야기 (#1077): 난이도 아이콘 + 회차·시험일 + 체감 한 줄 + 알려진 합격률 (#1158)
/// 공식 수치가 아니면 "수험생 전언, 비공식" 배지 (회차별 합격률은 공식 비공개)
class ExamRoundNoteTimeline extends StatelessWidget {
  const ExamRoundNoteTimeline({super.key, required this.roundNotes});

  final List<SqldRoundNote> roundNotes;

  @override
  Widget build(BuildContext context) {
    // 최신 회차 먼저
    final notesNewestFirst = [...roundNotes]
      ..sort((a, b) => b.round.compareTo(a.round));
    return PassqlGroupedSection(
      header: '최근 회차 이야기',
      footer: '회차별 합격률은 공식 발표가 없어요. 수험생 후기를 모은 참고용이에요',
      children: [
        for (final note in notesNewestFirst) _RoundNoteRow(note: note),
      ],
    );
  }
}

class _RoundNoteRow extends StatelessWidget {
  const _RoundNoteRow({required this.note});

  final SqldRoundNote note;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final passRatePercent = note.passRatePercent;
    final difficultyLevel = toDifficultyLevelFromStepNumber(
      note.difficultyLevel,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 난이도 아이콘 (값 없으면 자리째 없음)
          if (difficultyLevel != null) ...[
            _DifficultyTile(level: difficultyLevel),
            const SizedBox(width: PassqlSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 회차 + 시험일 (큰 글자에서도 줄바꿈되도록 Wrap) | 난이도 글자 오른쪽 끝
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: PassqlSpacing.xs,
                        children: [
                          Text(
                            '${note.round}회',
                            style: PassqlTypography.headline.copyWith(
                              color: colors.label,
                            ),
                          ),
                          Text(
                            note.examDate,
                            style: PassqlTypography.footnote.copyWith(
                              color: colors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (difficultyLevel != null)
                      Text(
                        difficultyLevel.label,
                        style: PassqlTypography.footnoteSemibold.copyWith(
                          color: _DifficultyTile.tonesOf(
                            difficultyLevel,
                            colors,
                          ).$2,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xxs),
                Text(
                  note.difficultyNote,
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                // 알려진 합격률 + (비공식이면) 배지
                if (passRatePercent != null) ...[
                  const SizedBox(height: PassqlSpacing.xs),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: PassqlSpacing.xs,
                    runSpacing: PassqlSpacing.xxs,
                    children: [
                      Text(
                        '합격률 약 ${passRatePercent.toStringAsFixed(0)}%',
                        style: PassqlTypography.subheadlineSemibold.copyWith(
                          color: colors.label,
                        ),
                      ),
                      if (!note.isOfficial)
                        const PassqlBadge(
                          text: '수험생 전언, 비공식',
                          kind: PassqlBadgeKind.neutral,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 난이도 타일: 옅은 의미색 바탕 + 의미색 아이콘 (쉬움 웃음·초록, 보통 게이지·주황, 어려움 불꽃·빨강)
class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({required this.level});

  final QuestionDifficultyLevel level;

  /// 난이도 > (아이콘·바탕 색, 글자색) — 배지 의미색과 같은 원본
  static (Color fillTone, Color textTone) tonesOf(
    QuestionDifficultyLevel level,
    PassqlColors colors,
  ) => PassqlBadge.tonesOf(switch (level) {
    QuestionDifficultyLevel.easy => PassqlBadgeKind.success,
    QuestionDifficultyLevel.normal => PassqlBadgeKind.warning,
    QuestionDifficultyLevel.hard => PassqlBadgeKind.important,
  }, colors);

  static IconData _iconOf(QuestionDifficultyLevel level) => switch (level) {
    QuestionDifficultyLevel.easy => CupertinoIcons.smiley_fill,
    QuestionDifficultyLevel.normal => CupertinoIcons.gauge,
    QuestionDifficultyLevel.hard => CupertinoIcons.flame_fill,
  };

  @override
  Widget build(BuildContext context) {
    final (fillTone, _) = tonesOf(level, context.passqlColors);
    // 스크린리더는 오른쪽 난이도 글자로 읽음
    return ExcludeSemantics(
      child: Container(
        width: PassqlSize.iconTile,
        height: PassqlSize.iconTile,
        decoration: BoxDecoration(
          color: fillTone.withValues(alpha: PassqlBadge.backgroundAlpha),
          borderRadius: BorderRadius.circular(PassqlRadius.iconTile),
        ),
        child: Icon(
          _iconOf(level),
          size: PassqlIconSize.iconTileGlyph,
          color: fillTone,
        ),
      ),
    );
  }
}
