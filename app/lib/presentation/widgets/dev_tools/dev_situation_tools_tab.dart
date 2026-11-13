import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/device_preferences.dart';
import '../../../core/storage/first_run_state_reset.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/utils/app_clock.dart';
import '../../../core/utils/date_format.dart';
import '../../design/design.dart';
import '../../providers/dev_situation_overrides.dart';
import '../../providers/learning_refresh.dart';
import '../../providers/plan_providers.dart';
import '../../providers/push_notification_providers.dart';
import '../lock_screen/lock_screen_intro_sheet.dart';
import 'dev_push_tools_section.dart';

/// 개발자 도구 상황 흉내 탭 (#819): 시험일 흉내, 날짜 넘기기, 처음 상태 다시 보기, 잠금화면(#990), 푸시 알림 테스트
/// 모두 앱 표시·기기 기록만 바꿈 (서버 데이터·서버 한도 그대로)
class DevSituationToolsTab extends ConsumerStatefulWidget {
  const DevSituationToolsTab({super.key});

  @override
  ConsumerState<DevSituationToolsTab> createState() =>
      _DevSituationToolsTabState();
}

class _DevSituationToolsTabState extends ConsumerState<DevSituationToolsTab> {
  // 기기 기록 되돌리기 뒤 안내 (실행 중 화면은 그대로라 재시작 필요)
  static const String _restartNotice = '앱을 완전히 종료한 뒤 다시 시작하세요';

  /// 처음 상태 묶음 마지막 동작 결과 한 줄
  String? _firstRunResultMessage;

  /// 날짜 넘기기·되돌리기 > 자정 지남과 같은 재조회 + 등급 사용량 다시 적용
  void _changeShiftedDays(void Function(DevShiftedDayCountNotifier) change) {
    change(ref.read(devShiftedDayCountProvider.notifier));
    refreshDateDependentData(ref.invalidate);
    ref.read(planProvider.notifier).reapplyDevOverrides();
  }

  /// 온보딩 다시 보기: 대기 기록 > 재시작 안내
  Future<void> _replayOnboarding() async {
    await FirstRunStateReset.markOnboardingPending();
    _showFirstRunResult('온보딩 대기로 바꿨어요. $_restartNotice');
  }

  /// 권한 안내 다시 보기: "나중에" 기록 삭제 > 재시작 안내
  Future<void> _replayPushPermissionPrompt() async {
    await ref.read(pushPermissionPromptStoreProvider).clearDeferral();
    _showFirstRunResult(
      '"나중에" 기록을 지웠어요. $_restartNotice (기기 권한을 이미 정했으면 안 떠요)',
    );
  }

  /// 첫 설치 상태로: 확인 > 판단 기록 삭제 > 재시작 안내 (다음 실행에 로그아웃)
  Future<void> _resetToFirstInstall() async {
    final isConfirmed = await showPassqlConfirmDialog(
      context,
      title: '첫 설치 상태로 되돌릴까요?',
      message: '다음 실행 때 로그인 세션이 지워져 로그인 화면부터 시작해요',
      confirmLabel: '되돌리기',
    );
    if (!isConfirmed) return;
    await FirstRunStateReset.resetFirstRunRecords();
    _showFirstRunResult('첫 실행 기록을 지웠어요. $_restartNotice');
  }

  /// 잠금화면 소개 기록 삭제 > 노출 조건 처음부터 (횟수·마지막 노출)
  Future<void> _resetLockScreenIntro() async {
    await DevicePreferences.remove(StorageKeys.lockScreenIntroShownCount);
    await DevicePreferences.remove(StorageKeys.lockScreenIntroLastShownAt);
    _showFirstRunResult('잠금화면 소개 기록을 지웠어요');
  }

  void _showFirstRunResult(String message) {
    if (mounted) setState(() => _firstRunResultMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    final examSimulation = ref.watch(devExamDdaySimulationProvider);
    final shiftedDayCount = ref.watch(devShiftedDayCountProvider);
    final appDateText = formatDottedDate(AppClock.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlGroupedSection(
          header: '시험일 흉내',
          footer:
              '홈 상단 D-day, 내 프로필 탑승권, 이용권 시트 문구에 반영 (선택한 시험이 없으면 가짜 SQLD 일정)',
          children: [
            for (final option in DevExamDdaySimulation.values)
              PassqlCheckRow(
                title: option.label,
                isSelected: examSimulation == option,
                onTap: () => ref
                    .read(devExamDdaySimulationProvider.notifier)
                    .select(option),
              ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.lg),
        PassqlGroupedSection(
          header: '날짜 넘기기 흉내',
          footer:
              '자정이 지난 것처럼 날짜별 데이터를 다시 받고 무료 사용량을 새 날(0)로 보여요. '
              '서버 한도, 오늘의 세트는 서버 날짜 그대로예요',
          children: [
            PassqlListRow(
              title: '앱 날짜',
              trailing: Text(
                shiftedDayCount == 0
                    ? appDateText
                    : '$appDateText (+$shiftedDayCount일)',
                style: PassqlTypography.footnote,
              ),
            ),
            PassqlListRow(
              title: '하루 넘기기',
              hasChevron: true,
              onTap: () =>
                  _changeShiftedDays((notifier) => notifier.shiftOneDay()),
            ),
            PassqlListRow(
              title: '원래 날짜로',
              subtitle: shiftedDayCount == 0 ? '지금 기기 날짜 그대로예요' : null,
              onTap: shiftedDayCount == 0
                  ? null
                  : () => _changeShiftedDays((notifier) => notifier.reset()),
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.lg),
        PassqlGroupedSection(
          header: '처음 상태 다시 보기',
          footer: _firstRunResultMessage ?? '기기 기록만 바꿔요. 앱을 다시 시작해야 반영돼요',
          children: [
            PassqlListRow(
              title: '온보딩 다시 보기',
              subtitle: '다음 실행에 로그인 상태면 온보딩부터',
              onTap: _replayOnboarding,
            ),
            PassqlListRow(
              title: '알림 권한 안내 다시 보기',
              subtitle: '"나중에" 7일 기록 삭제',
              onTap: _replayPushPermissionPrompt,
            ),
            PassqlListRow(
              title: '첫 설치 상태로',
              subtitle: '설치 표식, 첫 실행 기록 삭제 (다음 실행에 로그아웃)',
              isDestructive: true,
              onTap: _resetToFirstInstall,
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.lg),
        PassqlGroupedSection(
          header: '잠금화면 문제',
          footer: '강제 켜기는 앱 화면만 보여요. 실제 출제는 서버 스위치를 따라요',
          children: [
            PassqlCheckRow(
              title: '강제 켜기 (서버 스위치 무시)',
              isSelected: ref.watch(devLockScreenForcedProvider),
              onTap: () =>
                  ref.read(devLockScreenForcedProvider.notifier).toggle(),
            ),
            PassqlListRow(
              title: '소개 시트 바로 보기',
              hasChevron: true,
              onTap: () => showLockScreenIntroSheet(context),
            ),
            PassqlListRow(
              title: '소개 기록 지우기',
              subtitle: '다시 3문제 풀면 소개가 떠요',
              onTap: _resetLockScreenIntro,
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.lg),
        const DevPushToolsSection(),
      ],
    );
  }
}
