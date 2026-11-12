import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/device_preferences.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/push/push_messaging_client.dart';
import '../../../data/push/push_notification_service.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/push_notification_providers.dart';
import '../notification/notification_permission_flow.dart';

/// 홈 첫 방문 환영 안내 (#975): 기기에서 한 번만 짧은 시트로 띄움 (오늘의 세트·크레딧·AI 기능, 한 줄씩 차례로 떠오름)
/// 닫으면 알림 허용 안내로 이어짐 (#980)
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
    await showPassqlSheet<void>(
      context,
      builder: (sheetContext) => _HomeWelcomeGuideBody(
        hasCredits: ref.read(freeRemainingSolvesProvider) != null,
        isProLocked: ref.read(shouldShowProUiProvider),
        onStart: () => Navigator.of(sheetContext).pop(),
      ),
    );
    // 환영 시트를 닫으면 알림 허용을 바로 안내 (#980, 권한 미결정·나중에 후 7일 지났을 때만)
    if (mounted) await _promptNotificationPermissionIfUndecided();
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

/// 환영 안내 본문: 대표 아이콘이 톡 튀어나옴 > 제목 > 한 줄 세 개가 차례로 떠오름 > 시작하기
/// 한 줄 = 아이콘 + 짧은 문장 (설명 줄 없이 시트 높이를 줄임), 동작 줄이기면 바로 보임
class _HomeWelcomeGuideBody extends StatelessWidget {
  const _HomeWelcomeGuideBody({
    required this.hasCredits,
    required this.isProLocked,
    required this.onStart,
  });

  /// 크레딧이 적용되는 회원인가 (무료·결제 켜짐)
  final bool hasCredits;

  /// AI 해설·직접 실행이 이용권 기능으로 잠긴 회원인가
  final bool isProLocked;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final lines = [
      (icon: CupertinoIcons.square_list_fill, text: '오늘의 세트는 매일 새로 열려요'),
      if (hasCredits)
        (icon: CupertinoIcons.bolt_fill, text: '랜덤 풀기는 크레딧 1개로 1문제'),
      (
        icon: CupertinoIcons.sparkles,
        text: isProLocked ? 'PRO는 AI 해설과 SQL 직접 실행까지' : 'AI 해설과 SQL 직접 실행까지',
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
            // 대표 아이콘 (톡 튀어나옴)
            Center(
              child: PassqlPopIn(
                child: Container(
                  width: PassqlSize.sheetHeroCircle,
                  height: PassqlSize.sheetHeroCircle,
                  decoration: BoxDecoration(
                    color: colors.accentTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.hand_raised_fill,
                    size: PassqlIconSize.sheetHero,
                    color: colors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            PassqlReveal(
              index: 1,
              child: Semantics(
                header: true,
                child: Text(
                  '환영해요!',
                  textAlign: TextAlign.center,
                  style: PassqlTypography.title2.copyWith(color: colors.label),
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.md),
            // 한 줄씩 차례로 떠오름
            for (var index = 0; index < lines.length; index++)
              PassqlReveal(
                index: index + 2,
                child: _GuideLine(
                  icon: lines[index].icon,
                  text: lines[index].text,
                ),
              ),
            const SizedBox(height: PassqlSpacing.md),
            PassqlReveal(
              index: lines.length + 2,
              child: PassqlButton(label: '시작하기', onPressed: onStart),
            ),
          ],
        ),
      ),
    );
  }
}

/// 안내 한 줄: 강조색 아이콘 + 짧은 문장
class _GuideLine extends StatelessWidget {
  const _GuideLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: PassqlIconSize.lg, color: colors.accent),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: PassqlTypography.subheadline.copyWith(color: colors.label),
            ),
          ),
        ],
      ),
    );
  }
}
