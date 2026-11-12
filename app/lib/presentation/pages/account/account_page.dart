import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/pro_ui_providers.dart';
import '../../widgets/account/account_info_section.dart';
import '../../widgets/account/account_pass_section.dart';
import '../../widgets/account/promo_code_section.dart';

/// 계정·이용권 관리 (#816, 프로필 계정 줄 `관리`에서 진입)
/// 내 계정(항상) > 이용권·프로모션 코드(결제 UI 대상일 때만) > 로그아웃·탈퇴는 설정으로
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBillingUiTarget = ref.watch(isBillingUiTargetProvider);
    return Scaffold(
      // 이용권 묶음이 없으면(결제 꺼짐) 제목도 계정만
      appBar: PassqlNavBar(
        title: isBillingUiTarget ? '계정·이용권' : '계정',
        leading: PassqlNavLeading.back,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PassqlSpacing.md),
        children: [
          const AccountInfoSection(),
          if (isBillingUiTarget) ...const [
            SizedBox(height: PassqlSpacing.xl),
            AccountPassSection(),
            SizedBox(height: PassqlSpacing.xl),
            PromoCodeSection(),
          ],
          const SizedBox(height: PassqlSpacing.xl),
          // 로그아웃·탈퇴는 설정 한 곳에만 둠 (확인 창·탈퇴 흐름 중복 방지)
          PassqlGroupedSection(
            footer: '로그아웃과 회원 탈퇴는 설정에 있어요',
            children: [
              PassqlListRow(
                title: '설정',
                hasChevron: true,
                onTap: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
