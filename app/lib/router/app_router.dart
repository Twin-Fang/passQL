import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/flows/daily_set_flow.dart';
import '../presentation/flows/question_flow.dart';
import '../presentation/pages/daily_set/daily_set_result_page.dart';
import '../presentation/pages/daily_set/leaderboard_page.dart';
import '../presentation/pages/feedback/feedback_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/questions/topic_list_page.dart';
import '../presentation/pages/questions/chapter_page.dart';
import '../presentation/pages/questions/question_detail_page.dart';
import '../presentation/pages/result/result_page.dart';
import '../presentation/pages/practice/practice_page.dart';
import '../presentation/pages/practice/practice_result_page.dart';
import '../presentation/pages/stats/stats_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/widgets/app_shell.dart';
import 'app_routes.dart';

// 루트 네비게이터 키 — 풀스크린 라우트(탭 바깥)에서 사용
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// 쉘 네비게이터 키 — 탭 내 이동에서 사용
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// 앱 전역 라우터.
///
/// - ShellRoute: 바텀 탭 4개 (홈/문제/통계/설정)
/// - 루트 라우트: 풀스크린 페이지 (챕터, 문제 상세, 결과, 연습)
abstract final class AppRouter {
  /// 로그인 여부. main 에서 인증 상태를 구독해 갱신하고, 값이 바뀌면 라우터가 redirect 를 다시 평가한다.
  static final ValueNotifier<bool> authenticated = ValueNotifier<bool>(false);

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    refreshListenable: authenticated,
    // 로그인 안 했으면 로그인 화면으로, 로그인 했는데 로그인 화면이면 홈으로 보낸다.
    redirect: (_, state) {
      final atLogin = state.matchedLocation == AppRoutes.login;
      if (!authenticated.value && !atLogin) return AppRoutes.login;
      if (authenticated.value && atLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      // 로그인
      GoRoute(
        path: AppRoutes.login,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const LoginPage(),
      ),

      // 탭 쉘
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: AppRoutes.questions,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: TopicListPage()),
          ),
          GoRoute(
            path: AppRoutes.stats,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StatsPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),

      // 풀스크린: 건의사항
      GoRoute(
        path: AppRoutes.feedback,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const FeedbackPage(),
      ),

      // 풀스크린: 챕터 플로우 (/questions/chapter?topic=CODE&topicName=NAME)
      // 반드시 /questions/:questionUuid 보다 먼저 정의 (정적 경로 우선)
      GoRoute(
        path: AppRoutes.questionChapter,
        parentNavigatorKey: _rootKey,
        builder: (_, state) {
          final params = state.uri.queryParameters;
          return ChapterPage(
            flow: TopicFlow(
              topicCode: params['topic'] ?? '',
              topicName: params['topicName'] ?? '문제 풀기',
            ),
          );
        },
      ),

      // 풀스크린: 오늘의 세트 풀이 / 결과 / 리더보드
      GoRoute(
        path: AppRoutes.dailySet,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ChapterPage(flow: DailySetFlow()),
      ),
      GoRoute(
        path: AppRoutes.dailySetResult,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => DailySetResultPage(extra: state.extra),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const LeaderboardPage(),
      ),

      // 풀스크린: 문제 상세 + 결과
      GoRoute(
        path: '/questions/:questionUuid',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => QuestionDetailPage(
          questionUuid: state.pathParameters['questionUuid']!,
        ),
        routes: [
          GoRoute(
            path: 'result',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => ResultPage(extra: state.extra),
          ),
        ],
      ),

      // 풀스크린: 연습 모드 + 연습/챕터 결과
      GoRoute(
        path: '/practice/:sessionId',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => PracticePage(
          sessionId: state.pathParameters['sessionId']!,
        ),
        routes: [
          GoRoute(
            path: 'result',
            parentNavigatorKey: _rootKey,
            builder: (_, state) =>
                PracticeResultPage(extra: state.extra),
          ),
        ],
      ),
    ],
  );
}
