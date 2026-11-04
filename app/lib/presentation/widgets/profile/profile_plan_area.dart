import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import 'profile_plan_action_rows.dart';
import 'profile_pro_extend_card.dart';
import 'profile_pro_pass_card.dart';
import 'profile_today_free_usage.dart';
import 'profile_upgrade_banner.dart';

/// 내 프로필 이용권 자리 (#816 A안, 옛 탑승권 자리): 등급 판정은 기존 잠금 UI 판정과 같음
/// 무료 = 오늘 남은 문제 > 업그레이드 배너 > 복원·코드 행, 프로 = 남은 날 탑승권 > 이어서 연장 > 내역·복원·코드 행
/// 결제 꺼짐·등급 모름 = 자리째 없음 (계정 줄은 이 자리 밖이라 항상 보임)
class ProfilePlanArea extends ConsumerWidget {
  const ProfilePlanArea({super.key, required this.nickname});

  /// 프로 탑승권 승객 칸
  final String nickname;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(shouldShowProUiProvider)) {
      final plan = ref.watch(knownPlanProvider);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 등급 응답이 없으면(개발자 도구 강제 등) 사용량 칸 생략
          if (plan != null && plan.effectiveTodayFreeLimit > 0) ...[
            ProfileTodayFreeUsage(plan: plan),
            const SizedBox(height: PassqlSpacing.lg),
          ],
          const ProfileUpgradeBanner(),
          const SizedBox(height: PassqlSpacing.xs),
          const ProfilePlanActionRows(isPro: false),
        ],
      );
    }
    if (ref.watch(shouldShowProBadgeProvider)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileProPassCard(nickname: nickname),
          const SizedBox(height: PassqlSpacing.lg),
          const ProfileProExtendCard(),
          const SizedBox(height: PassqlSpacing.xs),
          const ProfilePlanActionRows(isPro: true),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
