import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/device_preferences.dart';
import '../../../core/storage/storage_keys.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';

/// 홈 첫 방문 환영 안내 (#975): 기기에서 한 번만 시트로 띄움 (오늘의 세트·크레딧·AI 기능 쓰는 법)
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
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.xs,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                '환영해요,\npassQL은 이렇게 써요',
                style: PassqlTypography.title2.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            _GuideRow(
              icon: CupertinoIcons.square_list_fill,
              title: '오늘의 세트',
              description: hasCredits
                  ? '매일 새 문제를 크레딧 없이 풀어요'
                  : '매일 새 문제로 실력을 확인해요',
            ),
            if (hasCredits)
              const _GuideRow(
                icon: CupertinoIcons.bolt_fill,
                title: '크레딧',
                description: '랜덤 풀기 1문제에 1개, 매일 새로 채워져요',
              ),
            _GuideRow(
              icon: CupertinoIcons.sparkles,
              title: 'AI 해설과 SQL 직접 실행',
              description: isProLocked
                  ? 'PRO에서 틀린 이유를 AI가 설명하고 보기를 실행해요'
                  : '틀린 이유를 AI가 설명하고 보기를 직접 실행해요',
            ),
            const SizedBox(height: PassqlSpacing.md),
            PassqlButton(label: '시작하기', onPressed: onStart),
          ],
        ),
      ),
    );
  }
}

/// 안내 한 줄: 아이콘 타일 + 이름 + 한 줄 설명 (설정 화면 행과 같은 모양)
class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return PassqlListRow(
      title: title,
      subtitle: description,
      leading: PassqlIconTile(icon: icon, color: context.passqlColors.accent),
      hasChevron: false,
      hasHorizontalPadding: false,
    );
  }
}
