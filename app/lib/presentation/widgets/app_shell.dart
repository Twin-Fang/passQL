import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design/design.dart';
import 'ads/ad_native_strip_slot.dart';
import 'ads/interstitial_ad_preloader.dart';
import 'app_gate/recommended_update_prompter.dart';
import 'common/app_lifecycle_refresher.dart';
import 'notification/notification_permission_prompter.dart';
import '../providers/concept_providers.dart';

/// 하단 탭 쉘: 탭마다 화면 상태(스크롤·데이터)를 유지한다 (StatefulShellRoute).
/// extendBody 로 콘텐츠가 글래스 탭 바 뒤로 지나가게 한다.
/// 개념 탭은 이용 가능할 때만 보여서, 보이는 탭 순번 <-> 라우터 브랜치 번호를 매핑한다 (#577)
class AppShell extends ConsumerWidget {
  /// 탭 화면 묶음 (현재 탭 번호·탭 이동 담당)
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  // 라우터 브랜치 순서와 같은 탭 항목 (AppRoutes.tabRoots)
  static const _items = [
    PassqlTabItem(
      kind: PassqlTabIconKind.home,
      label: '홈',
    ),
    PassqlTabItem(
      kind: PassqlTabIconKind.concept,
      label: '개념',
    ),
    PassqlTabItem(
      kind: PassqlTabIconKind.questions,
      label: '문제',
    ),
    PassqlTabItem(
      kind: PassqlTabIconKind.community,
      label: '토론',
    ),
    PassqlTabItem(
      kind: PassqlTabIconKind.profile,
      label: '프로필',
    ),
  ];

  // 개념 탭 브랜치 번호
  static const int _conceptBranchIndex = 1;

  /// 보이는 탭의 브랜치 번호 목록 (개념 이용 불가면 개념 브랜치 제외)
  static List<int> visibleBranchIndexesOf({required bool isConceptVisible}) => [
    for (var branchIndex = 0; branchIndex < _items.length; branchIndex++)
      if (isConceptVisible || branchIndex != _conceptBranchIndex) branchIndex,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleBranchIndexes = visibleBranchIndexesOf(
      isConceptVisible: ref.watch(isConceptLearningAvailableProvider),
    );
    final visibleCurrentIndex = visibleBranchIndexes
        .indexOf(navigationShell.currentIndex)
        .clamp(0, visibleBranchIndexes.length - 1);
    // 다음 날 복귀하면 어제 세트·인사말이 남지 않게 갱신 (#483)
    return AppLifecycleRefresher(
      child: Scaffold(
        extendBody: true,
        // 탭 첫 진입 시 권장 업데이트 안내 1회 (#464)
        // 알림 권한 안내는 홈 첫 진입 후 1회 (앱 자체 시트 > 시스템 창)
        // 결과 화면 전면 광고는 탭 화면에 들어온 뒤 미리 불러 둠
        body: InterstitialAdPreloader(
          child: NotificationPermissionPrompter(
            child: RecommendedUpdatePrompter(child: navigationShell),
          ),
        ),
        // 탭 바 + 아래 한 줄 광고 띠(메인 탭 공통, 실패 시 높이 0). extendBody 라 본문 하단 여백에 띠 높이도 반영
        // 전체 화면(풀이·결과)이 셸을 덮으면 Navigator 가 셸을 offstage 로 둠 > 가려진 띠는 그려지지 않음
        bottomNavigationBar: AdNativeStripSlot(
          tabBar: PassqlTabBar(
            items: [
              for (final branchIndex in visibleBranchIndexes)
                _items[branchIndex],
            ],
            currentIndex: visibleCurrentIndex,
            // 지금 탭을 다시 누르면 그 탭의 첫 화면으로
            onTap: (visibleIndex) {
              final branchIndex = visibleBranchIndexes[visibleIndex];
              navigationShell.goBranch(
                branchIndex,
                initialLocation: branchIndex == navigationShell.currentIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 탭 화면 묶음: 모두 살아 있되 지금 탭만 보이고, 탭을 바꾸면 새 탭이 페이드로 나타난다
/// 위젯 구조를 탭 전환 전후로 같게 둬서 각 탭의 상태가 사라지지 않게 한다
class AppTabFadeStack extends StatefulWidget {
  const AppTabFadeStack({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<AppTabFadeStack> createState() => _AppTabFadeStackState();
}

class _AppTabFadeStackState extends State<AppTabFadeStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.fast,
    value: 1,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: PassqlMotion.curve,
  );

  @override
  void didUpdateWidget(AppTabFadeStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    if (PassqlMotion.isReduced(context)) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final (index, child) in widget.children.indexed)
          Offstage(
            offstage: index != widget.currentIndex,
            // 안 보이는 탭의 애니메이션·타이머는 멈춘다
            child: TickerMode(
              enabled: index == widget.currentIndex,
              child: FadeTransition(
                opacity: index == widget.currentIndex
                    ? _opacity
                    : const AlwaysStoppedAnimation(1),
                child: child,
              ),
            ),
          ),
      ],
    );
  }
}
