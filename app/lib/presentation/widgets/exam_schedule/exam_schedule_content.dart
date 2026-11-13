import 'package:flutter/widgets.dart';

import '../../../data/models/exam/sqld_exam_schedule_overview_response.dart';
import '../../design/design.dart';
import 'exam_schedule_hero_card.dart';
import 'exam_schedule_info_section.dart';
import 'exam_schedule_labels.dart';
import 'exam_schedule_timeline.dart';

/// 시험 일정 화면 본문 (#991 B안): 다음 시험 카드 > 올해 타임라인 > 시험 정보 > 출처 줄
/// 다음 시험이 없으면 카드 없이 타임라인부터
class ExamScheduleContent extends StatelessWidget {
  const ExamScheduleContent({
    super.key,
    required this.overview,
    required this.today,
    required this.onApplyPressed,
    required this.onMockExamPressed,
    required this.onOfficialGuidePressed,
  });

  final SqldExamScheduleOverviewResponse overview;
  final DateTime today;
  final VoidCallback onApplyPressed;
  final VoidCallback onMockExamPressed;
  final VoidCallback onOfficialGuidePressed;

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    PassqlSpacing.md,
    PassqlSpacing.xs,
    PassqlSpacing.md,
    PassqlSpacing.xl,
  );

  @override
  Widget build(BuildContext context) {
    final nextSchedule = overview.nextSchedule;
    return ListView(
      padding: _padding,
      children: [
        if (nextSchedule != null) ...[
          ExamScheduleHeroCard(
            schedule: nextSchedule,
            today: today,
            onApplyPressed: onApplyPressed,
            onMockExamPressed: onMockExamPressed,
          ),
          const SizedBox(height: PassqlSpacing.xl),
        ],
        if (overview.schedules.isNotEmpty) ...[
          ExamScheduleTimeline(
            year: overview.year,
            schedules: overview.schedules,
            today: today,
          ),
          const SizedBox(height: PassqlSpacing.xl),
        ],
        ExamScheduleInfoSection(onOfficialGuidePressed: onOfficialGuidePressed),
        const SizedBox(height: PassqlSpacing.md),
        Text(
          examScheduleSourceTextOf(overview.lastCollectedAt, today),
          textAlign: TextAlign.center,
          style: PassqlTypography.caption.copyWith(
            color: context.passqlColors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}
