import 'package:flutter/widgets.dart';

import '../../../core/utils/exam_dday.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../design/design.dart';

/// 상단 바 부제: 'SQLD 63회 · 11월 14일' (날짜를 읽지 못하면 회차만)
String examBarSubtitle(ExamScheduleResponse schedule) {
  final round = '${schedule.certType} ${schedule.round}회';
  final date = DateTime.tryParse(schedule.examDate);
  if (date == null) return round;
  return '$round · ${formatMonthDay(date)}';
}

/// 스크린리더 낭독: 'D-18' 대신 '시험까지 18일'
String examDdaySpokenLabel(int days) {
  if (days == 0) return '오늘 시험일';
  if (days > 0) return '시험까지 $days일';
  return '시험 ${days.abs()}일 지남';
}

/// 홈 상단 바 왼쪽: 로고 + 시험 D-day 배지 (#701, #971). 일정이 없거나 날짜를 읽지 못하면 로고만
/// 스크린리더는 `시험까지 18일, SQLD 63회 · 11월 14일` 로 읽음
class ExamDdayBarTitle extends StatelessWidget {
  const ExamDdayBarTitle({super.key, this.schedule});

  final ExamScheduleResponse? schedule;

  @override
  Widget build(BuildContext context) {
    final schedule = this.schedule;
    final days = schedule == null ? null : daysUntilExam(schedule.examDate);
    const logo = PassqlLogo(height: PassqlSize.navBarLogoHeight);
    if (schedule == null || days == null) {
      return Semantics(header: true, child: logo);
    }
    return Semantics(
      header: true,
      label: '${examDdaySpokenLabel(days)}, ${examBarSubtitle(schedule)}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(width: PassqlSpacing.xs),
          PassqlBadge(text: examDdayLabel(days)),
        ],
      ),
    );
  }
}
