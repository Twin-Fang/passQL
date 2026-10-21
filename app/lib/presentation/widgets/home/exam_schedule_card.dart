import 'package:flutter/cupertino.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../design/design.dart';

/// 홈 화면 시험 일정 카드.
/// schedule이 null이면 "선택된 일정 없음" 표시.
class ExamScheduleCard extends StatelessWidget {
  final ExamScheduleResponse? schedule;
  final VoidCallback? onTap;

  const ExamScheduleCard({super.key, this.schedule, this.onTap});

  /// examDate(YYYY-MM-DD) → D-day 문자열.
  String _dday(String examDate) {
    try {
      final exam = DateTime.parse(examDate);
      final today = DateTime.now();
      final diff = exam
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      if (diff == 0) return 'D-Day';
      if (diff > 0) return 'D-$diff';
      return 'D+${diff.abs()}';
    } catch (_) {
      return '';
    }
  }

  /// YYYY-MM-DD → 한국어 날짜 (예: 2026년 6월 21일)
  String _formatDate(String examDate) {
    try {
      final parts = examDate.split('-');
      return '${parts[0]}년 ${parts[1]}월 ${parts[2]}일';
    } catch (_) {
      return examDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: PassqlIconSize.xs,
                color: colors.accent,
              ),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                '시험 일정',
                style: PassqlTypography.captionSemibold.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.sm),
          if (schedule != null) ...[
            Text(
              _dday(schedule!.examDate),
              style: PassqlTypography.title1.copyWith(color: colors.accentText),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlKeepAllText(
              '${schedule!.certType} ${schedule!.round}회',
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.label,
              ),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            PassqlKeepAllText(
              _formatDate(schedule!.examDate),
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ] else ...[
            PassqlKeepAllText(
              '선택된 일정 없음',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlKeepAllText(
              '일정 선택하기',
              style: PassqlTypography.captionSemibold.copyWith(
                color: colors.accentText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
