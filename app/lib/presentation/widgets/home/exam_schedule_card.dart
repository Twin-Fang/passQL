import 'package:flutter/cupertino.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../design/design.dart';

/// 홈 화면 시험 일정 카드.
/// schedule이 null이면 "시험 일정 준비 중" 안내만 표시 (선택 기능 없음).
class ExamScheduleCard extends StatelessWidget {
  final ExamScheduleResponse? schedule;
  final VoidCallback? onTap;

  const ExamScheduleCard({super.key, this.schedule, this.onTap});

  /// 시험일까지 남은 일수 (오늘 0, 지난 날 음수). 날짜를 읽지 못하면 null
  int? _daysUntilExam(String examDate) {
    try {
      final exam = DateTime.parse(examDate);
      final today = DateTime.now();
      return exam
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
    } catch (_) {
      return null;
    }
  }

  /// 화면 표기: D-24 / D-Day / D+3
  String _ddayLabel(int? daysUntilExam) {
    if (daysUntilExam == null) return '';
    if (daysUntilExam == 0) return 'D-Day';
    if (daysUntilExam > 0) return 'D-$daysUntilExam';
    return 'D+${daysUntilExam.abs()}';
  }

  /// 스크린리더 낭독: 시험까지 24일 / 오늘 시험일 / 시험 3일 지남
  String _ddaySpokenLabel(int? daysUntilExam) {
    if (daysUntilExam == null) return '';
    if (daysUntilExam == 0) return '오늘 시험일';
    if (daysUntilExam > 0) return '시험까지 $daysUntilExam일';
    return '시험 ${daysUntilExam.abs()}일 지남';
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
    final daysUntilExam = schedule == null
        ? null
        : _daysUntilExam(schedule!.examDate);
    // 머리는 위, D-day 묶음은 아래 고정 > 옆 카드 높이에 맞춰 늘어나도 가운데가 비어 보이지 않음
    return PassqlCard(
      onTap: onTap,
      shouldChildFillHeight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카드가 가장 낮을 때도 머리와 붙지 않는 최소 간격
              const SizedBox(height: PassqlSpacing.sm),
              if (schedule != null) ...[
                // 'D-24' 대신 '시험까지 24일'로 읽힘
                Semantics(
                  label: _ddaySpokenLabel(daysUntilExam),
                  excludeSemantics: true,
                  child: Text(
                    _ddayLabel(daysUntilExam),
                    style: PassqlTypography.largeTitle.copyWith(
                      color: colors.accentText,
                    ),
                  ),
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
              ] else
                // 사용자가 고를 수 없으므로 누를 수 있는 모양(강조색) 없이 안내만
                PassqlKeepAllText(
                  '시험 일정 준비 중',
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
