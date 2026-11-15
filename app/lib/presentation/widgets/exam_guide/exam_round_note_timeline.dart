import 'package:flutter/widgets.dart';

import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';

/// 최근 회차 이야기 (#1077): 회차별 체감 난이도 한 줄 + 알려진 합격률
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 회차 + 시험일 (큰 글자에서도 줄바꿈되도록 Wrap)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: PassqlSpacing.xs,
            children: [
              Text(
                '${note.round}회',
                style: PassqlTypography.headline.copyWith(color: colors.label),
              ),
              Text(
                note.examDate,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
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
            const SizedBox(height: PassqlSpacing.xxs),
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
    );
  }
}
