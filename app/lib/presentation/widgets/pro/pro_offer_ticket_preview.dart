import 'package:flutter/material.dart';

import '../../../core/utils/date_format.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import 'pro_benefits.dart';

/// 사면 받게 될 내 PRO 탑승권 미리보기 + 연장 만료일 줄 (고른 이용권 만료일이 바로 바뀜)
class ProOfferTicketPreview extends StatelessWidget {
  const ProOfferTicketPreview({
    super.key,
    required this.nickname,
    required this.examSchedule,
    required this.selectedOption,
    required this.benefits,
    required this.activeProExpiresAt,
  });

  /// 승객 칸
  final String nickname;

  /// 목적지·시험일 (없으면 SQLD, 시험일 칸 생략)
  final ExamScheduleResponse? examSchedule;
  final PassOption? selectedOption;
  final List<ProBenefit> benefits;

  /// 이용 중인 프로 만료일 (무료·만료면 null > 연장 줄 생략)
  final DateTime? activeProExpiresAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final schedule = examSchedule;
    final selectedOption = this.selectedOption;
    final activeProExpiresAt = this.activeProExpiresAt;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlPassTicket(
          tier: PassqlPassTicketTier.pro,
          destination: schedule == null
              ? 'SQLD'
              : '${schedule.certType} ${schedule.round}회',
          fields: [
            PassqlPassTicketField('승객', nickname),
            if (selectedOption != null)
              PassqlPassTicketField(
                '이용권',
                '${_monthDayOf(selectedOption.expiresAtIfPurchased)}까지',
                isHighlighted: true,
              ),
            if (schedule != null)
              PassqlPassTicketField('시험일', _monthDayOfText(schedule.examDate)),
          ],
          benefitIcons: [
            for (final benefit in benefits)
              (icon: benefit.icon, color: benefitColorOf(context, benefit)),
          ],
          stubLabel: 'PRO',
          hasSweep: true,
          hasHolo: true,
          isFloating: true,
          semanticLabel: selectedOption == null
              ? 'passQL PRO PASS 미리보기'
              : 'passQL PRO PASS 미리보기, ${formatDottedDate(selectedOption.expiresAtIfPurchased)}까지',
        ),
        if (activeProExpiresAt != null && selectedOption != null) ...[
          const SizedBox(height: PassqlSpacing.sm),
          Text(
            '만료일 ${formatDottedDate(activeProExpiresAt)} > ${formatDottedDate(selectedOption.expiresAtIfPurchased)}',
            textAlign: TextAlign.center,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ],
    );
  }
}

/// 날짜 > MM.dd
String _monthDayOf(DateTime date) =>
    '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

/// ISO 날짜 문자열 > MM.dd (읽지 못하면 원문 그대로)
String _monthDayOfText(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  return date == null ? isoDate : _monthDayOf(date);
}
