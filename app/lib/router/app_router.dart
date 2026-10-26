import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/community/community_models.dart';
import '../presentation/flows/daily_set_flow.dart';
import '../presentation/flows/question_flow.dart';
import '../presentation/flows/random_practice_flow.dart';
import '../presentation/pages/community/blocked_members_page.dart';
import '../presentation/pages/community/community_feed_page.dart';
import '../presentation/pages/community/community_question_page.dart';
import '../presentation/pages/daily_set/daily_set_result_page.dart';
import '../presentation/pages/daily_set/leaderboard_page.dart';
import '../presentation/pages/app_gate/force_update_page.dart';
import '../presentation/pages/app_gate/maintenance_page.dart';
import '../presentation/pages/feedback/feedback_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/legal/legal_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/notice/notice_detail_page.dart';
import '../presentation/pages/notice/notice_list_page.dart';
import '../presentation/pages/notification/notification_inbox_page.dart';
import '../presentation/pages/questions/topic_list_page.dart';
import '../presentation/pages/questions/chapter_page.dart';
import '../presentation/pages/questions/chapter_result_page.dart';
import '../presentation/pages/questions/question_detail_page.dart';
import '../presentation/pages/result/result_page.dart';
import '../presentation/pages/stats/stats_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/settings/wrong_notes_page.dart';
import '../presentation/widgets/app_shell.dart';
import 'app_launch_gate_routing.dart';
import 'app_routes.dart';
import 'push_link_routes.dart';
import 'questions_tab_view.dart';
import 'result_route_arguments.dart';

// 루트 네비게이터 키 — 풀스크린 라우트(탭 바깥)에서 사용
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// 앱 전역 라우터.
///
/// - StatefulShellRoute: 바텀 탭 5개 (홈/문제/토론/통계/설정), 탭별 상태 유지
/// - 루트 라우트: 풀스크린 페이지 (챕터, 챕터 결과, 문제 상세, 결과)
abstract final class AppRouter {
  /// 로그인 여부. main 에서 인증 상태를 구독해 갱신하고, 값이 바뀌면 라우터가 redirect 를 다시 평가한다.
  static final ValueNotifier<bool> authenticated = ValueNotifier<bool>(false);

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    refreshListenable: Listenable.merge([
      authenticated,
      AppLaunchGateRouting.gate,
    ]),
    // 로그인 안 했으면 로그인 화면으로, 로그인 했는데 로그인 화면이면 홈으로 보낸다.
    redirect: (_, state) {
      // 점검·강제 업데이트 차단이 로그인보다 우선 (#464)
      final gateRedirect = AppLaunchGateRouting.redirectLocation(
        state.matchedLocation,
      );
      if (gateRedirect != null) return gateRedirect;
      if (AppLaunchGateRouting.isGateLocation(state.matchedLocation)) {
        return null;
      }
      final atLogin = state.matchedLocation == AppRoutes.login;
      // 약관은 가입 전에도 읽을 수 있어야 한다(App Store 5.1.1).
      if (state.matchedLocation.startsWith(AppRoutes.legalPrefix)) return null;
      if (!authenticated.value && !atLogin) return AppRoutes.login;
      if (authenticated.value && atLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      // 약관
      GoRoute(
        path: AppRoutes.legalPattern,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => LegalPage(
          typeValue: state.pathParameters[AppRoutes.legalTypeParameter]!,
        ),
      ),

      // 앱 시작 차단 화면
      GoRoute(
        path: AppRoutes.forceUpdate,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ForceUpdatePage(),
      ),
      GoRoute(
        path: AppRoutes.maintenance,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const MaintenancePage(),
      ),

      // 로그인: 로그인·로그아웃 redirect 로 탭 쉘과 맞바뀌는 화면이라 밀기 전환 없이 바로 바꾼다 (#672)
      GoRoute(
        path: AppRoutes.login,
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, _) => const NoTransitionPage(child: LoginPage()),
      ),

      // 탭 쉘: 탭마다 화면 상태를 유지하고 탭 전환은 페이드 (#495)
      // 쉘 진입(로그인 > 홈)도 밀기 전환 없이 바로 바꾼다 (#672)
      StatefulShellRoute(
        pageBuilder: (_, _, navigationShell) => NoTransitionPage(
          child: AppShell(navigationShell: navigationShell),
        ),
        navigatorContainerBuilder: (_, navigationShell, children) =>
            AppTabFadeStack(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.questions,
                pageBuilder: (_, state) => NoTransitionPage(
                  child: TopicListPage(
                    view: QuestionsTabView.fromQueryValue(
                      state.uri.queryParameters[AppRoutes.questionsViewQuery],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 토론 탭: 커뮤니티 피드 (#543, ?source= 로 시작 칩 지정)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.community,
                pageBuilder: (_, state) => NoTransitionPage(
                  child: CommunityFeedPage(
                    initialSource: CommunityFeedSource.fromServerValue(
                      state.uri.queryParameters[AppRoutes.communitySourceQuery],
                    ),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: StatsPage()),
              ),
            ],
          ),
        ],
      ),

      // 설정: 내 프로필 탭의 톱니바퀴로 여는 푸시 화면
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsPage(),
      ),

      // 풀스크린: 건의사항
      GoRoute(
        path: AppRoutes.feedback,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const FeedbackPage(),
      ),

      // 풀스크린: 알림함
      GoRoute(
        path: AppRoutes.notificationInbox,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const NotificationInboxPage(),
      ),

      // 풀스크린: 공지 목록·상세 (#529)
      GoRoute(
        path: AppRoutes.notices,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const NoticeListPage(),
      ),
      GoRoute(
        path: AppRoutes.noticeDetailPattern,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => NoticeDetailPage(
          noticeUuid: state.pathParameters[AppRoutes.noticeUuidParameter]!,
        ),
      ),

      // 옛 출제 경향 경로 > 문제 탭 '최신 경향' 보기 (#574)
      GoRoute(
        path: AppRoutes.examTrend,
        redirect: (_, _) => QuestionsTabView.latestTrend.location,
      ),

      // 풀스크린: 오답 노트 (문제 탭 오답 노트 바로가기에서 진입)
      GoRoute(
        path: AppRoutes.wrongNotes,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const WrongNotesPage(),
      ),

      // 풀스크린: 문제별 의견 (#525), 차단한 사용자 관리
      GoRoute(
        path: AppRoutes.communityQuestionPattern,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => CommunityQuestionPage(
          questionUuid: state.pathParameters[AppRoutes.questionUuidParameter]!,
        ),
      ),
      GoRoute(
        path: AppRoutes.blockedMembers,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BlockedMembersPage(),
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
              topicCode: params[AppRoutes.topicCodeQuery] ?? '',
              topicName: params[AppRoutes.topicNameQuery] ?? '문제 풀기',
              isLatestTrendOnly:
                  params[AppRoutes.latestTrendQuery] ==
                  AppRoutes.latestTrendQueryValue,
            ),
          );
        },
      ),

      // 풀스크린: 랜덤 풀기 풀이 (#576)
      GoRoute(
        path: AppRoutes.randomPractice,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ChapterPage(flow: RandomPracticeFlow()),
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
        builder: (_, state) => DailySetResultPage(
          outcome: ResultRouteArguments.dailySetOutcomeOf(state.extra),
        ),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const LeaderboardPage(),
      ),

      // 풀스크린: 문제 상세 + 결과
      GoRoute(
        path: AppRoutes.questionDetailPattern,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => QuestionDetailPage(
          questionUuid: state.pathParameters[AppRoutes.questionUuidParameter]!,
          isPushEntry: state.extra is PushEntryMarker,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.resultSubPath,
            parentNavigatorKey: _rootKey,
            builder: (_, state) => ResultPage(
              arguments: ResultRouteArguments.questionResultOf(state.extra),
            ),
          ),
        ],
      ),

      // 풀스크린: 챕터 결과 (챕터 화면을 대신해 열림)
      GoRoute(
        path: AppRoutes.chapterResult,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => ChapterResultPage(
          summary: ResultRouteArguments.chapterSummaryOf(state.extra),
        ),
      ),
    ],
  );
}
