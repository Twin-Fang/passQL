import 'package:flutter/widgets.dart';

import '../../../core/utils/app_clock.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../design/design.dart';
import '../exam_schedule/exam_schedule_labels.dart';

/// 상단 바 부제: 'SQLD 63회 · 11월 14일' (날짜를 읽지 못하면 회차만)
String examBarSubtitle(ExamScheduleResponse schedule) {
  final round = '${schedule.certType} ${schedule.round}회';
  final date = DateTime.tryParse(schedule.examDate);
  if (date == null) return round;
  return '$round | ${formatMonthDay(date)}';
}

/// 스크린리더 낭독: 'D-18' 대신 '시험까지 18일'
String examDdaySpokenLabel(int days) {
  if (days == 0) return '오늘 시험일';
  if (days > 0) return '시험까지 $days일';
  return '시험 ${days.abs()}일 지남';
}

/// 홈 상단 바 왼쪽: 로고 + 시험 D-day 배지 (#701, #971). 일정이 없거나 날짜를 읽지 못하면 로고만
/// 배지는 지금 단계 한 줄("접수 중 · 10.16 마감", "시험 D-2", #991), 누르면 시험 일정 화면
/// 스크린리더는 `시험까지 18일, SQLD 63회 · 11월 14일` 로 읽음
class ExamDdayBarTitle extends StatelessWidget {
  const ExamDdayBarTitle({super.key, this.schedule, this.onTap, this.today});

  final ExamScheduleResponse? schedule;

  /// 배지 누름 (시험 일정 화면 이동, null 이면 누를 수 없음)
  final VoidCallback? onTap;

  /// 기준 날짜 (null 이면 앱 시각)
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final schedule = this.schedule;
    final today = this.today ?? AppClock.now();
    final days = schedule == null
        ? null
        : daysUntilExam(schedule.examDate, now: today);
    const logo = PassqlLogo(height: PassqlSize.navBarLogoHeight);
    if (schedule == null || days == null) {
      return Semantics(header: true, child: logo);
    }
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(width: PassqlSpacing.xs),
        Flexible(
          child: PassqlBadge(text: examHomeBadgeTextOf(schedule, today)),
        ),
      ],
    );
    final spokenLabel =
        '${examDdaySpokenLabel(days)}, ${examBarSubtitle(schedule)}';
    final onTap = this.onTap;
    if (onTap == null) {
      return Semantics(
        header: true,
        label: spokenLabel,
        excludeSemantics: true,
        child: title,
      );
    }
    return Semantics(
      header: true,
      child: PassqlPressable(
        onTap: onTap,
        semanticLabel: '$spokenLabel, 시험 일정 보기',
        child: title,
      ),
    );
  }
}
