import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/device_preferences.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/push/push_messaging_client.dart';
import '../../../data/push/push_notification_service.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/push_notification_providers.dart';
import '../notification/notification_permission_flow.dart';

/// 홈 첫 방문 환영 안내 (#975, #1041): 기기에서 한 번만 짧은 시트로 띄움 (오늘 할 일 3단계, 차례로 떠오름)
/// 오늘의 세트 시작 > 세트로 이동, 둘러보기·닫기 > 알림 허용 안내로 이어짐 (#980)
/// 자리만 차지하지 않는 위젯 (홈 목록에 끼워 두면 첫 프레임 뒤 판정)
class HomeWelcomeGuideTrigger extends ConsumerStatefulWidget {
  const HomeWelcomeGuideTrigger({super.key});

  @override
  ConsumerState<HomeWelcomeGuideTrigger> createState() =>
      _HomeWelcomeGuideTriggerState();
}

class _HomeWelcomeGuideTriggerState
    extends ConsumerState<HomeWelcomeGuideTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOnce());
  }

  /// 본 적 없고 홈이 맨 위 화면일 때만 띄움 (다른 창이 떠 있으면 다음 방문으로 미룸)
  Future<void> _showOnce() async {
    final hasSeen =
        await DevicePreferences.readBool(StorageKeys.homeWelcomeGuideSeen) ??
        false;
    if (hasSeen || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    // 띄우기 전에 기록 (시트를 닫는 방법과 무관하게 한 번만)
    await DevicePreferences.writeBool(StorageKeys.homeWelcomeGuideSeen, true);
    if (!mounted) return;
    final isStartingDailySet = await showPassqlSheet<bool>(
      context,
      builder: (sheetContext) => _HomeWelcomeGuideBody(
        hasCredits: ref.read(freeRemainingSolvesProvider) != null,
        isProLocked: ref.read(shouldShowProUiProvider),
        onStartDailySet: () => Navigator.of(sheetContext).pop(true),
        onBrowse: () => Navigator.of(sheetContext).pop(false),
      ),
    );
    if (!mounted) return;
    // 세트를 고르면 바로 풀이로 (알림 안내는 학습 결과 뒤 기존 시점에)
    if (isStartingDailySet == true) {
      unawaited(context.push(AppRoutes.dailySet));
      return;
    }
    // 둘러보기·닫기면 알림 허용을 바로 안내 (#980, 권한 미결정·나중에 후 7일 지났을 때만)
    await _promptNotificationPermissionIfUndecided();
  }

  /// 알림 권한이 아직 결정되지 않았으면 안내 시트 (이미 허용·거부했으면 묻지 않음)
  Future<void> _promptNotificationPermissionIfUndecided() async {
    final permissionStatus = await ref
        .read(pushNotificationServiceProvider)
        .readPermissionStatus();
    if (permissionStatus != PushPermissionStatus.notDetermined || !mounted) {
      return;
    }
    if (!await ref.read(pushPermissionPromptStoreProvider).canPromptNow()) {
      return;
    }
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    await runNotificationPermissionPrompt(context, ref);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 환영 안내 본문 (#1041 B안): 3D 일러스트 팝 > 제목·한 줄 > 오늘 할 일 3단계(번호 원을 세로 선으로 이음, 차례로 떠오름)
/// > 오늘의 세트 시작하기 / 둘러볼게요. 2단계 문구는 해설 등급, 3단계는 크레딧 적용 여부로 바뀜
class _HomeWelcomeGuideBody extends StatelessWidget {
  const _HomeWelcomeGuideBody({
    required this.hasCredits,
    required this.isProLocked,
    required this.onStartDailySet,
    required this.onBrowse,
  });

  /// 크레딧이 적용되는 회원인가 (무료·결제 켜짐)
  final bool hasCredits;

  /// AI 해설·직접 실행이 이용권 기능으로 잠긴 회원인가
  final bool isProLocked;
  final VoidCallback onStartDailySet;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final steps = [
      const _WelcomeStep(title: '오늘의 세트 풀기', description: Text('매일 새 문제가 열려요')),
      _WelcomeStep(
        title: isProLocked ? '틀리면 정답 해설' : '틀리면 AI 해설',
        description: const Text('왜 틀렸는지 바로 봐요'),
      ),
      _WelcomeStep(
        title: '더 풀고 싶으면 랜덤 풀기',
        description: hasCredits
            ? const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '1문제에 '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: PassqlCreditIcon(),
                    ),
                    TextSpan(text: ' 크레딧 1개'),
                  ],
                ),
              )
            : const Text('토픽을 골라 원하는 만큼 풀어요'),
      ),
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          0,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 대표 3D 일러스트 (톡 튀어나옴)
            const Center(
              child: PassqlPopIn(child: PassqlWelcomeIllustration()),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlReveal(
              index: 1,
              child: Column(
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      '환영해요!',
                      textAlign: TextAlign.center,
                      style: PassqlTypography.title2.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.hairlineGap),
                  Text(
                    '이렇게 시작해요',
                    textAlign: TextAlign.center,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PassqlSpacing.md),
            // 단계 한 줄씩 차례로 떠오름 (마지막 줄만 아래 선 없음)
            for (var index = 0; index < steps.length; index++)
              PassqlReveal(
                index: index + 2,
                child: _WelcomeStepRow(
                  stepNumber: index + 1,
                  step: steps[index],
                  isFirst: index == 0,
                  isLast: index == steps.length - 1,
                ),
              ),
            const SizedBox(height: PassqlSpacing.md),
            PassqlReveal(
              index: steps.length + 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PassqlButton(
                    label: '오늘의 세트 시작하기',
                    onPressed: onStartDailySet,
                  ),
                  const SizedBox(height: PassqlSpacing.xs),
                  PassqlButton(
                    label: '둘러볼게요',
                    variant: PassqlButtonVariant.plain,
                    onPressed: onBrowse,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 오늘 할 일 한 단계: 굵은 제목 + 보조 설명 (설명은 크레딧 젬 같은 그림이 낄 수 있어 위젯)
class _WelcomeStep {
  const _WelcomeStep({required this.title, required this.description});

  final String title;
  final Widget description;
}

/// 단계 한 줄: 번호 원(첫 단계만 강조색 채움) + 세로 이음 선 | 제목 / 설명
class _WelcomeStepRow extends StatelessWidget {
  const _WelcomeStepRow({
    required this.stepNumber,
    required this.step,
    required this.isFirst,
    required this.isLast,
  });

  final int stepNumber;
  final _WelcomeStep step;
  final bool isFirst;
  final bool isLast;

  // 번호 원 지름, 이음 선 두께
  static const double _stepCircleSize = 32;
  static const double _connectorWidth = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 번호 원 + 아래 단계로 잇는 선
          Column(
            children: [
              Container(
                width: _stepCircleSize,
                height: _stepCircleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFirst ? colors.accent : colors.accentTint,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$stepNumber',
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: isFirst ? colors.onAccent : colors.accentText,
                  ),
                ),
              ),
              Expanded(
                child: isLast
                    ? const SizedBox.shrink()
                    : Container(
                        width: _connectorWidth,
                        color: colors.accentTint,
                      ),
              ),
            ],
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : PassqlSpacing.sm),
              child: Semantics(
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: PassqlTypography.subheadlineSemibold.copyWith(
                        color: colors.label,
                      ),
                    ),
                    DefaultTextStyle.merge(
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                      child: step.description,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
