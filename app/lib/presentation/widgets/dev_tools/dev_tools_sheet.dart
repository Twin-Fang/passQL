import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../core/config/app_build_flavor.dart';
import '../../../core/network/dio_client.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/session_reset.dart';
import '../ads/dev_ad_tools_section.dart';
import '../common/app_toast.dart';

/// 개발자 도구 시트 (#809): 빌드 상태, 등급 강제, 무료 한도 흉내, 광고 도구
/// 강제값·흉내는 앱 표시만 바꿈 (서버 데이터 그대로), 바꾸면 마지막 서버 등급에 바로 다시 적용
class DevToolsSheet extends ConsumerWidget {
  const DevToolsSheet({super.key});

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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        0,
        PassqlSpacing.md,
        PassqlSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlGroupedSection(
            header: '빌드 상태',
            children: [
              for (final (title, value) in _buildStateRows(ref))
                PassqlListRow(
                  title: title,
                  trailing: Text(value, style: PassqlTypography.footnote),
                ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          PassqlButton(
            label: '상태 전체 복사 (등급 응답 포함)',
            variant: PassqlButtonVariant.tinted,
            size: PassqlButtonSize.regular,
            onPressed: () => _copyStateDump(context, ref),
          ),
          const SizedBox(height: PassqlSpacing.lg),
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
            header: '무료 한도 흉내',
            footer: '흉내 중에는 결제 켜진 무료 회원으로 보이고, 광고 보너스는 서버 대신 흉내 단계만 넘어가요',
            children: [
              for (final option in DevLimitSimulation.values)
                PassqlCheckRow(
                  title: option.label,
                  isSelected: simulation == option,
                  onTap: () {
                    ref
                        .read(devLimitSimulationProvider.notifier)
                        .select(option);
                    ref.read(planProvider.notifier).reapplyDevOverrides();
                  },
                ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.lg),
          const DevAdToolsSection(),
        ],
      ),
    );
  }

  /// 빌드 상태 줄 5개: 빌드 종류, 광고 단위, 서버, 회원, 등급 한도
  static List<(String, String)> _buildStateRows(WidgetRef ref) {
    final knownPlan = ref.watch(knownPlanProvider);
    return [
      ('빌드 종류', AppBuildFlavor.isDevBuild ? '개발용 (APP_FLAVOR=dev)' : '디버그'),
      ('광고 단위', AdUnitIds.shouldUseTestAds ? '테스트' : '실제'),
      ('서버', _backendHostOf(dotenv.maybeGet(backendBaseUrlEnvKey))),
      ('회원', ref.watch(currentMemberUuidProvider) ?? '로그아웃'),
      (
        '오늘 랜덤',
        knownPlan == null
            ? '모름'
            : '${knownPlan.todayRandomSolvedCount} / '
                  '${knownPlan.effectiveTodayFreeLimit}',
      ),
    ];
  }

  /// 기본 주소 > 호스트만 (경로·쿼리 생략)
  static String _backendHostOf(String? backendBaseUrl) {
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) return '없음';
    return Uri.tryParse(backendBaseUrl)?.host ?? backendBaseUrl;
  }

  /// 상태 전체 > 클립보드 (앱 버전, 빌드, 회원, 강제값, 등급 응답 JSON)
  static Future<void> _copyStateDump(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final knownPlan = ref.read(knownPlanProvider);
    final stateDump = const JsonEncoder.withIndent('  ').convert({
      'appVersion': '${packageInfo.version}+${packageInfo.buildNumber}',
      'isDevBuild': AppBuildFlavor.isDevBuild,
      'isTestAds': AdUnitIds.shouldUseTestAds,
      'backendHost': _backendHostOf(dotenv.maybeGet(backendBaseUrlEnvKey)),
      'memberUuid': ref.read(currentMemberUuidProvider),
      'debugPlan': ref.read(debugPlanOverrideProvider)?.name,
      'limitSimulation': ref.read(devLimitSimulationProvider).name,
      'plan': knownPlan?.toJson(),
    });
    await Clipboard.setData(ClipboardData(text: stateDump));
    if (context.mounted) showAppToast(context, '상태를 복사했어요');
  }
}
