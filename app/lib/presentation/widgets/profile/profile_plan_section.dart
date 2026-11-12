import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/exam_dday.dart';
import '../../../core/utils/profile_pass_values.dart';

import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import '../../providers/settings_providers.dart';
import 'profile_plan_manage_row.dart';
import 'profile_pro_extend_card.dart';
import 'profile_pro_pass_card.dart';
import 'profile_today_free_usage.dart';
import 'profile_upgrade_banner.dart';

/// 내 프로필 크레딧·이용권 구간 (#816 A안, #971): 등급 판정은 기존 잠금 UI 판정과 같음
/// 무료 = 오늘 크레딧 구간 > 이용권 구간(업그레이드 배너 + 이용권 관리 행), 프로 = 이용권 구간(남은 날 탑승권 > 이어서 연장(만료 임박만) > 이용권 관리 행)
/// 구간마다 앞 띠를 스스로 둠. 결제 꺼짐·등급 모름 = 자리째 없음
class ProfilePlanSection extends ConsumerWidget {
  const ProfilePlanSection({super.key});

  static const String _passSectionTitle = '이용권';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(shouldShowProUiProvider)) {
      final plan = ref.watch(knownPlanProvider);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 등급 응답이 없으면(개발자 도구 강제 등) 크레딧 구간 생략
          if (plan != null && plan.effectiveTodayFreeLimit > 0) ...[
            const PassqlSectionGap(),
            PassqlSection(child: ProfileTodayFreeUsage(plan: plan)),
          ],
          const PassqlSectionGap(),
          const PassqlSection(
            title: _passSectionTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileUpgradeBanner(),
                SizedBox(height: PassqlSpacing.xs),
                ProfilePlanManageRow(),
              ],
            ),
          ),
        ],
      );
    }
    if (ref.watch(shouldShowProBadgeProvider)) {
      // 프로 탑승권 수험생 칸 (닉네임을 아직 모르면 빈칸)
      final nickname =
          ref.watch(nicknameNotifierProvider).valueOrNull ??
          ref.watch(settingsDataProvider).valueOrNull?.nickname ??
          '';
      final proExpiresAt = ref.watch(knownPlanProvider)?.proExpiresAt;
      final isExtendSuggested = shouldSuggestProExtension(
        proExpiresAt == null ? null : daysUntilDate(proExpiresAt),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PassqlSectionGap(),
          PassqlSection(
            title: _passSectionTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileProPassCard(nickname: nickname),
                if (isExtendSuggested) ...[
                  const SizedBox(height: PassqlSpacing.lg),
                  const ProfileProExtendCard(),
                ],
                const SizedBox(height: PassqlSpacing.xs),
                const ProfilePlanManageRow(),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
