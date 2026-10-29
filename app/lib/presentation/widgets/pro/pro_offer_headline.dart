import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'pro_benefits.dart';

/// 프로 안내 시트 머리: 문장 제목 > 기간 줄(무료 최대치) > 들어온 이유 > 강조 혜택
class ProOfferHeadline extends StatelessWidget {
  const ProOfferHeadline({
    super.key,
    required this.daysUntilExam,
    required this.freeCap,
    required this.dailyFreeLimit,
    required this.reason,
    required this.focusedBenefit,
  });

  /// 시험까지 남은 날 (일정 없으면 null)
  final int? daysUntilExam;

  /// 시험까지 무료 최대 문제 수 (null 이면 기간 줄 생략)
  final int? freeCap;
  final int dailyFreeLimit;
  final String? reason;

  /// 탑승권 혜택 아이콘에서 열었을 때 강조할 혜택
  final ProBenefit? focusedBenefit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final daysUntil = daysUntilExam;
    final reason = this.reason;
    final focusedBenefit = this.focusedBenefit;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 「이용권」 글자 대신 숫자를 강조한 문장 제목 (스크린리더 머리글 역할)
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: PassqlTypography.title2.copyWith(color: colors.label),
              children: [
                if (daysUntil != null && daysUntil > 0)
                  TextSpan(text: '시험까지 $daysUntil일,\n'),
                TextSpan(
                  text: '제한 없이',
                  style: TextStyle(color: colors.accentText),
                ),
                const TextSpan(text: ' 풀고 합격해요'),
              ],
            ),
          ),
        ),
        if (freeCap != null) ...[
          const SizedBox(height: PassqlSpacing.xxs),
          Row(
            children: [
              Expanded(
                child: Text(
                  '무료로는 시험까지 랜덤 최대 $freeCap문제',
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ),
              Text(
                '$daysUntil일 × $dailyFreeLimit문제',
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Divider(
            height: PassqlSize.hairline * 3,
            thickness: PassqlSize.hairline * 3,
            color: colors.label,
          ),
        ],
        if (reason != null) ...[
          const SizedBox(height: PassqlSpacing.xs),
          PassqlKeepAllText(
            reason,
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: colors.accentText,
            ),
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
