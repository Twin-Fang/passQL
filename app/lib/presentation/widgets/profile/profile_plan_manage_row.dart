import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 프로필 이용권 자리 맨 아래 한 줄 (#863): 구매 내역·구매 복원·프로모션 코드는 계정·이용권 화면 한 곳에만 두고 여기는 진입만
class ProfilePlanManageRow extends StatelessWidget {
  const ProfilePlanManageRow({super.key});

  @override
  Widget build(BuildContext context) {
    return PassqlListRow(
      title: '이용권 관리',
      subtitle: '구매 내역 · 구매 복원 · 프로모션 코드',
      hasChevron: true,
      hasHorizontalPadding: false,
      onTap: () => context.push(AppRoutes.account),
    );
  }
}
