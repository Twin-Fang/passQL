import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import 'pro_info_sheet.dart';
import 'pro_offer_sheet.dart';

/// 설정 맨 위 등급 카드: 무료 > 큰 유도 카드, 프로 > 이용권 한 줄, 결제 꺼짐·등급 모름 > 그리지 않음
class ProSettingsCard extends ConsumerWidget {
  const ProSettingsCard({super.key});

  /// 큰 카드 제목·혜택 한 줄·버튼 문구
  static const String freeTitle = '책 없이 폰 하나로 SQLD 합격';
  static const String freeBenefit = '랜덤 풀기 제한 없음 · SQL 직접 실행 · 보기별 해설';
  static const String passLabel = '회차 패스';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final knownPlan = ref.watch(knownPlanProvider);
    if (ref.watch(shouldShowProUiProvider)) {
      return _FreePlanCard(plan: knownPlan);
    }
    if (ref.watch(shouldShowProBadgeProvider)) {
      return _ProPlanLine(proExpiresAt: knownPlan?.proExpiresAt);
    }
    return const SizedBox.shrink();
  }
}

/// 무료: FREE · 오늘 n/10문제 사용 > 제목 > 혜택 한 줄 > 회차 패스 버튼
class _FreePlanCard extends ConsumerWidget {
  const _FreePlanCard({required this.plan});

  /// 등급 모름(디버그 강제 등)이면 null > 사용량 줄 생략
  final MemberPlanResponse? plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final usagePlan = plan;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PassqlPlanChip(isPro: false),
              if (usagePlan != null && usagePlan.dailyFreeLimit > 0) ...[
                const SizedBox(width: PassqlSpacing.xs),
                Flexible(
                  child: Text(
                    '오늘 ${usagePlan.todayRandomSolvedCount}/'
                    '${usagePlan.dailyFreeLimit}문제 사용',
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: PassqlSpacing.sm),
          PassqlKeepAllText(
            ProSettingsCard.freeTitle,
            style: PassqlTypography.title3.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          PassqlKeepAllText(
            ProSettingsCard.freeBenefit,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.md),
          PassqlButton(
            label: ProSettingsCard.passLabel,
            onPressed: () => showProOfferSheet(context, ref),
          ),
        ],
      ),
    );
  }
}

/// 프로: 회차 패스 · {만료일}까지 · PRO › (누르면 이용권 정보 시트)
class _ProPlanLine extends StatelessWidget {
  const _ProPlanLine({required this.proExpiresAt});

  final DateTime? proExpiresAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final expiresAt = proExpiresAt;
    final summary = expiresAt == null
        ? ProSettingsCard.passLabel
        : '${ProSettingsCard.passLabel} · ${formatDottedDate(expiresAt)}까지 ·';
    return PassqlCard(
      onTap: () => showProInfoSheet(context, proExpiresAt: expiresAt),
      child: Row(
        children: [
          Flexible(
            child: Text(
              summary,
              style: PassqlTypography.body.copyWith(color: colors.label),
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          const PassqlPlanChip(isPro: true),
          const Spacer(),
          Icon(
            CupertinoIcons.chevron_forward,
            size: PassqlIconSize.xs,
            color: colors.tertiaryLabel,
          ),
        ],
      ),
    );
  }
}
