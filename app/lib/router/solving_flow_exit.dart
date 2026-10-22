import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

// 풀이 흐름을 이루는 루트 라우트 경로 (문제 상세, 결과, 챕터, 챕터 결과, 오늘의 세트, 세트 결과)
// app_router.dart 의 해당 GoRoute.path 와 같은 상수를 쓴다.
const Set<String> _solvingFlowRoutePaths = {
  AppRoutes.questionDetailPattern,
  AppRoutes.resultSubPath,
  AppRoutes.questionChapter,
  AppRoutes.chapterResult,
  AppRoutes.dailySet,
  AppRoutes.dailySetResult,
};

/// 풀이 흐름 나가기: 흐름 시작 전 화면(문제 탭·홈·오답 노트 등)으로 pop, 시작 화면이 없으면 홈
/// 스택 맨 위의 흐름 화면 N개 > 그 아래 화면이 있으면 N개 pop, 없으면(딥링크 시작) 홈 이동
void leaveSolvingFlow(BuildContext context) {
  final routeMatches = GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.matches;

  // 맨 위에서부터 연속된 흐름 화면 수
  var solvingFlowScreenCount = 0;
  for (final match in routeMatches.reversed) {
    if (!_isSolvingFlowRoute(match.route)) break;
    solvingFlowScreenCount++;
  }

  // 흐름 화면이 아닌 곳에서 불렸거나 흐름이 스택 전부면 돌아갈 곳 없음
  final hasScreenBeforeFlow =
      solvingFlowScreenCount > 0 &&
      solvingFlowScreenCount < routeMatches.length;
  if (!hasScreenBeforeFlow) {
    context.go(AppRoutes.home);
    return;
  }

  // 흐름 화면 수만큼 한 번에 pop (결과 > 상세 > 시작 화면)
  var remainingPopCount = solvingFlowScreenCount;
  Navigator.of(
    context,
    rootNavigator: true,
  ).popUntil((_) => remainingPopCount-- <= 0);
}

bool _isSolvingFlowRoute(RouteBase route) =>
    route is GoRoute && _solvingFlowRoutePaths.contains(route.path);
