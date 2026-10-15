import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../design/design.dart';

/// ShellRoute builder에서 사용하는 바텀 네비게이션 쉘.
///
/// 탭 선택 상태는 현재 라우트 경로로 결정한다 — 별도 상태 불필요.
/// extendBody 로 콘텐츠가 글래스 탭 바 뒤로 지나가게 한다.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _items = [
    PassqlTabItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: '홈',
    ),
    PassqlTabItem(
      icon: CupertinoIcons.book,
      activeIcon: CupertinoIcons.book_fill,
      label: '문제',
    ),
    PassqlTabItem(
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: '통계',
    ),
    PassqlTabItem(
      icon: CupertinoIcons.gear,
      activeIcon: CupertinoIcons.gear_solid,
      label: '설정',
    ),
  ];

  /// 현재 경로에서 탭 인덱스 결정. 매칭 없으면 0(홈) 반환.
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final tabIndex = AppRoutes.tabRoots.indexWhere(location.startsWith);
    return tabIndex < 0 ? 0 : tabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: PassqlTabBar(
        items: _items,
        currentIndex: _currentIndex(context),
        onTap: (index) => context.go(AppRoutes.tabRoots[index]),
      ),
    );
  }
}
