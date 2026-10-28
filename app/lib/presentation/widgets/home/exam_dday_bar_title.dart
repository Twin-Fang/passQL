import 'package:flutter/widgets.dart';

import '../../../data/models/exam/exam_schedule_response.dart';
import '../../design/design.dart';
import 'exam_dday.dart';

/// 상단 바 부제: 'SQLD 63회 · 11월 14일' (날짜를 읽지 못하면 회차만)
String examBarSubtitle(ExamScheduleResponse schedule) {
  final round = '${schedule.certType} ${schedule.round}회';
  final date = DateTime.tryParse(schedule.examDate);
  if (date == null) return round;
  return '$round · ${date.month}월 ${date.day}일';
}

/// 스크린리더 낭독: 'D-18' 대신 '시험까지 18일'
String examDdaySpokenLabel(int days) {
  if (days == 0) return '오늘 시험일';
  if (days > 0) return '시험까지 $days일';
  return '시험 ${days.abs()}일 지남';
}

/// 홈 상단 바 왼쪽 제목: 로고 자리에 시험 D-day + 회차·날짜 (#701)
/// 일정이 없거나 날짜를 읽지 못하면 로고 + '시험 일정 준비 중'
class ExamDdayBarTitle extends StatelessWidget {
  const ExamDdayBarTitle({super.key, this.schedule});

  final ExamScheduleResponse? schedule;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final subtitleStyle = PassqlTypography.caption.copyWith(
      color: colors.secondaryLabel,
    );
    final days = schedule == null ? null : daysUntilExam(schedule!.examDate);
    if (days == null) {
      return Semantics(
        header: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PassqlLogo(height: PassqlSize.navBarLogoHeight),
            const SizedBox(width: PassqlSpacing.xs),
            Flexible(
              child: Text(
                '시험 일정 준비 중',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle,
              ),
            ),
          ],
        ),
      );
    }
    final subtitle = examBarSubtitle(schedule!);
    return Semantics(
      header: true,
      label: '${examDdaySpokenLabel(days)}, $subtitle',
      excludeSemantics: true,
      // 좁은 폭·큰 글자에서는 회차·날짜가 먼저 줄고 D-day 는 남는다
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            examDdayLabel(days),
            maxLines: 1,
            style: PassqlTypography.title2.copyWith(color: colors.accentText),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          Flexible(
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: subtitleStyle,
            ),
          ),
        ],
      ),
    );
  }
}
