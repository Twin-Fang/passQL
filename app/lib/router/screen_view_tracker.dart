import 'package:go_router/go_router.dart';

import '../core/monitoring/app_analytics.dart';
import 'app_routes.dart';

/// 라우트 패턴(AppRoutes) > 분석 화면 이름. 경로 값(UUID 등)이 아니라 패턴 기준이라 개인 식별 값이 섞이지 않음
const Map<String, String> screenNameByRoutePattern = {
  AppRoutes.login: 'login',
  AppRoutes.legalPattern: 'legal',
  AppRoutes.home: 'home',
  AppRoutes.questions: 'topic_list',
  AppRoutes.stats: 'stats',
  AppRoutes.settings: 'settings',
  AppRoutes.feedback: 'feedback',
  AppRoutes.wrongNotes: 'wrong_notes',
  AppRoutes.dailySet: 'daily_set',
  AppRoutes.dailySetResult: 'daily_set_result',
  AppRoutes.leaderboard: 'leaderboard',
  AppRoutes.questionChapter: 'chapter',
  AppRoutes.questionDetailPattern: 'question_detail',
  '${AppRoutes.questionDetailPattern}/${AppRoutes.resultSubPath}':
      'question_result',
  AppRoutes.practicePattern: 'practice',
  '${AppRoutes.practicePattern}/${AppRoutes.resultSubPath}': 'practice_result',
};

/// 라우터 위치 변화 > 화면 조회 기록 (go·push·pop 공통, 같은 화면 연속은 1회)
/// 표에 없는 새 라우트는 패턴 문자열 그대로 기록
void trackScreenViews(GoRouter router, {AppAnalytics? analytics}) {
  String? lastScreenName;
  router.routerDelegate.addListener(() {
    if (router.routerDelegate.currentConfiguration.isEmpty) return;
    final routePattern = router.state.fullPath;
    if (routePattern == null || routePattern.isEmpty) return;
    final screenName = screenNameByRoutePattern[routePattern] ?? routePattern;
    if (screenName == lastScreenName) return;
    lastScreenName = screenName;
    (analytics ?? AppAnalytics.current).logScreenView(screenName);
  });
}
