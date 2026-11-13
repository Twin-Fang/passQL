import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../ads/dev_ad_tools_section.dart';

/// 개발자 도구 등급·결제 탭 (#809·#816): 등급 강제, 무료 한도 흉내(결제 켜짐 흉내 포함), 광고 도구
/// 바꾸면 마지막 서버 등급에 바로 다시 적용 (서버 요청 없음)
class DevPlanToolsTab extends ConsumerWidget {
  const DevPlanToolsTab({super.key});

  // 등급 강제 선택지 3개 (null = 서버값)
  static const List<(ProDebugPlan?, String)> _debugPlanOptions = [
    (null, '서버값 그대로'),
    (ProDebugPlan.free, '무료로 강제'),
    (ProDebugPlan.pro, '프로로 강제'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugPlan = ref.watch(debugPlanOverrideProvider);
    final simulation = ref.watch(devLimitSimulationProvider);
    final knownPlan = ref.watch(knownPlanProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlGroupedSection(
          header: '등급 강제',
          footer: '지금 등급(강제값 반영): ${knownPlan?.plan.name ?? '모름'}',
          children: [
            for (final (option, label) in _debugPlanOptions)
              PassqlCheckRow(
                title: label,
                isSelected: debugPlan == option,
                onTap: () {
                  ref.read(debugPlanOverrideProvider.notifier).select(option);
                  ref.read(planProvider.notifier).reapplyDevOverrides();
                },
              ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.lg),
        PassqlGroupedSection(
          header: '무료 한도 흉내 | 결제 켜짐 흉내',
          footer: '흉내 중에는 결제 켜진 무료 회원으로 보이고, 광고 보너스는 서버 대신 흉내 단계만 넘어가요',
          children: [
            for (final option in DevLimitSimulation.values)
              PassqlCheckRow(
                title: option.label,
                isSelected: simulation == option,
                onTap: () {
                  ref.read(devLimitSimulationProvider.notifier).select(option);
                  ref.read(planProvider.notifier).reapplyDevOverrides();
                },
              ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.lg),
        const DevAdToolsSection(),
      ],
    );
  }
}
