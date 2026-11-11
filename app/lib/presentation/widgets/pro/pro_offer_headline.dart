import 'package:flutter/material.dart';

import '../../../core/utils/exam_dday.dart';
import '../../design/design.dart';
import 'pro_benefits.dart';

/// 프로 안내 시트 머리: PRO 마크 > 문장 제목 > 무료 최대치 줄 > 강조 혜택
/// 이용 중이면 제목만 연장 문장 (N일 남은 이용권, 이어서 연장해요)
class ProOfferHeadline extends StatelessWidget {
  const ProOfferHeadline({
    super.key,
    required this.daysUntilExam,
    required this.activeProExpiresAt,
    required this.freeCap,
    required this.focusedBenefit,
  });

  /// 시험까지 남은 날 (일정 없으면 null)
  final int? daysUntilExam;

  /// 이용 중인 프로 만료일 (무료·만료면 null > 구매 문장)
  final DateTime? activeProExpiresAt;

  /// 시험까지 무료 최대 문제 수 (null 이면 기간 줄 생략)
  final int? freeCap;

  /// 탑승권 혜택 아이콘에서 열었을 때 강조할 혜택
  final ProBenefit? focusedBenefit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final daysUntil = daysUntilExam;
    final focusedBenefit = this.focusedBenefit;
    final activeProExpiresAt = this.activeProExpiresAt;
    final proDaysLeft = activeProExpiresAt == null
        ? null
        : daysUntilDate(activeProExpiresAt);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: PassqlProMark(withLabel: true),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        // 「이용권」 글자 대신 숫자를 강조한 문장 제목 (스크린리더 머리글 역할)
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: PassqlTypography.title2.copyWith(color: colors.label),
              children: proDaysLeft != null
                  ? [
                      TextSpan(
                        text: '$proDaysLeft일',
                        style: TextStyle(color: colors.accentText),
                      ),
                      const TextSpan(text: ' 남은 이용권,\n이어서 연장해요'),
                    ]
                  : [
                      if (daysUntil != null && daysUntil > 0)
                        TextSpan(text: '시험까지 $daysUntil일,\n'),
                      TextSpan(
                        text: '제한 없이',
                        style: TextStyle(color: colors.accentText),
                      ),
                      const TextSpan(text: ' 풀어요'),
                    ],
            ),
          ),
        ),
        if (freeCap != null) ...[
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            '무료로는 시험까지 랜덤 최대 $freeCap문제',
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Divider(
            height: PassqlSize.hairline * 3,
            thickness: PassqlSize.hairline * 3,
            color: colors.label,
          ),
        ],
        if (focusedBenefit != null) ...[
          const SizedBox(height: PassqlSpacing.sm),
          _FocusedBenefitRow(
            key: const Key('pro-offer-focused-benefit'),
            benefit: focusedBenefit,
          ),
        ],
      ],
    );
  }
}

/// 탑승권 혜택 아이콘에서 들어왔을 때 그 혜택을 크게 (아이콘 + 이름 + 무료 → 프로 값)
class _FocusedBenefitRow extends StatelessWidget {
  const _FocusedBenefitRow({super.key, required this.benefit});

  final ProBenefit benefit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Row(
        children: [
          PassqlIconTile(
            icon: benefit.icon,
            color: benefitColorOf(context, benefit),
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.label,
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                Text(
                  benefitFreeToProLabel(benefit),
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
