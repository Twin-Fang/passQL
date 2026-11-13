import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../core/config/app_build_flavor.dart';
import '../../../core/config/env_keys.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/utils/app_clock.dart';
import '../../../core/utils/date_format.dart';
import '../../design/design.dart';
import '../../providers/dev_situation_overrides.dart';
import '../../providers/plan_providers.dart';
import '../../providers/session_reset.dart';
import 'dev_log_sheet.dart';

/// 개발자 도구 진단 탭 (#809·#819): 빌드 상태, 상태 전체 복사, 최근 로그·네트워크 오류 보기
class DevDiagnosticsTab extends ConsumerStatefulWidget {
  const DevDiagnosticsTab({super.key});

  @override
  ConsumerState<DevDiagnosticsTab> createState() => _DevDiagnosticsTabState();
}

class _DevDiagnosticsTabState extends ConsumerState<DevDiagnosticsTab> {
  /// 마지막 복사 결과 한 줄 (시트가 토스트를 가려 묶음 아래에 표시)
  String? _copyResultMessage;

  /// 상태 전체 > 클립보드 (앱 버전, 빌드, 회원, 강제값·흉내, 등급 응답 JSON)
  Future<void> _copyStateDump() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final knownPlan = ref.read(knownPlanProvider);
    final stateDump = const JsonEncoder.withIndent('  ').convert({
      'appVersion': '${packageInfo.version}+${packageInfo.buildNumber}',
      'isDevBuild': AppBuildFlavor.isDevBuild,
      'isTestAds': AdUnitIds.shouldUseTestAds,
      'backendHost': _backendHostOf(dotenv.maybeGet(EnvKeys.backendBaseUrl)),
      'memberUuid': ref.read(currentMemberUuidProvider),
      'debugPlan': ref.read(debugPlanOverrideProvider)?.name,
      'limitSimulation': ref.read(devLimitSimulationProvider).name,
      'examDdaySimulation': ref.read(devExamDdaySimulationProvider).name,
      'shiftedDayCount': AppClock.devShiftedDayCount,
      'plan': knownPlan?.toJson(),
    });
    await Clipboard.setData(ClipboardData(text: stateDump));
    if (mounted) setState(() => _copyResultMessage = '상태를 복사했어요');
  }

  /// 로그 시트 열기 (개발자 도구 시트 위에 한 겹 더)
  void _openLogSheet() {
    showPassqlSheet<void>(
      context,
      title: '최근 로그',
      builder: (_) => const DevLogSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentEntries = AppLogger.recentEntries;
    final apiFailureCount = recentEntries
        .where((entry) => entry.isApiFailure)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlGroupedSection(
          header: '빌드 상태',
          footer: _copyResultMessage,
          children: [
            for (final (title, value) in _buildStateRows())
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
          onPressed: _copyStateDump,
        ),
        const SizedBox(height: PassqlSpacing.lg),
        PassqlGroupedSection(
          header: '로그',
          footer:
              '최근 ${AppLogger.recentEntryCapacity}건까지 메모리에만 보관 (앱을 다시 켜면 비워짐)',
          children: [
            PassqlListRow(
              title: '로그 보기',
              subtitle:
                  '전체 ${recentEntries.length}건 | 네트워크 오류 $apiFailureCount건',
              hasChevron: true,
              onTap: _openLogSheet,
            ),
          ],
        ),
      ],
    );
  }

  /// 빌드 상태 줄 6개: 빌드 종류, 광고 단위, 서버, 회원, 등급 한도, 앱 날짜
  List<(String, String)> _buildStateRows() {
    final knownPlan = ref.watch(knownPlanProvider);
    final shiftedDayCount = ref.watch(devShiftedDayCountProvider);
    return [
      ('빌드 종류', AppBuildFlavor.isDevBuild ? '개발용 (APP_FLAVOR=dev)' : '디버그'),
      ('광고 단위', AdUnitIds.shouldUseTestAds ? '테스트' : '실제'),
      ('서버', _backendHostOf(dotenv.maybeGet(EnvKeys.backendBaseUrl))),
      ('회원', ref.watch(currentMemberUuidProvider) ?? '로그아웃'),
      (
        '오늘 랜덤',
        knownPlan == null
            ? '모름'
            : '${knownPlan.todayRandomSolvedCount} / '
                  '${knownPlan.effectiveTodayFreeLimit}',
      ),
      (
        '앱 날짜',
        shiftedDayCount == 0
            ? formatDottedDate(AppClock.now())
            : '${formatDottedDate(AppClock.now())} (+$shiftedDayCount일)',
      ),
    ];
  }

  /// 기본 주소 > 호스트만 (경로·쿼리 생략)
  static String _backendHostOf(String? backendBaseUrl) {
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) return '없음';
    return Uri.tryParse(backendBaseUrl)?.host ?? backendBaseUrl;
  }
}
