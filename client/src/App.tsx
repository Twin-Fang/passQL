import { lazy, Suspense } from "react";
import { createBrowserRouter, RouterProvider, Navigate, Outlet } from "react-router-dom";
import AppLayout from "./components/AppLayout";
import PageLoadingFallback from "./components/PageLoadingFallback";
// 첫 화면(홈·로그인)·오류 화면만 즉시 로딩, 나머지는 라우트별 청크 (#497)
import Home from "./pages/Home";
import Login from "./pages/Login";
import AuthCallback from "./pages/AuthCallback";
import RouteError from "./pages/RouteError";
import MaintenanceGate from "./components/MaintenanceGate";
import UnreadTitleSync from "./components/UnreadTitleSync";
import { isAuthenticated } from "./stores/authStore";

const CategoryCards = lazy(() => import("./pages/CategoryCards"));
const DailySet = lazy(() => import("./pages/DailySet"));
const DailySetResult = lazy(() => import("./pages/DailySetResult"));
const Leaderboard = lazy(() => import("./pages/Leaderboard"));
const PracticeSet = lazy(() => import("./pages/PracticeSet"));
const PracticeResult = lazy(() => import("./pages/PracticeResult"));
const QuestionDetail = lazy(() => import("./pages/QuestionDetail"));
const AnswerFeedback = lazy(() => import("./pages/AnswerFeedback"));
const RecommendationPractice = lazy(() => import("./pages/RecommendationPractice"));
const Stats = lazy(() => import("./pages/Stats"));
const MyPage = lazy(() => import("./pages/MyPage"));
const Notifications = lazy(() => import("./pages/Notifications"));
const Settings = lazy(() => import("./pages/Settings"));
const SettingsFeedback = lazy(() => import("./pages/SettingsFeedback"));

/** 인증 필수 가드 — 미로그인 시 /login으로 redirect */
function RequireAuth() {
  if (!isAuthenticated()) return <Navigate to="/login" replace />;
  // AppLayout 밖 전체화면 라우트의 청크 대기 (AppLayout 안은 자체 Suspense)
  return (
    <Suspense fallback={<PageLoadingFallback />}>
      <Outlet />
    </Suspense>
  );
}

/** 이미 로그인된 경우 /login 접근 시 홈으로 redirect */
function RedirectIfAuth() {
  return isAuthenticated() ? <Navigate to="/" replace /> : <Outlet />;
}

const router = createBrowserRouter([
  {
    // 모든 라우트를 감싸 렌더 예외·없는 경로를 기본 개발자 화면 대신 RouteError로 받는다 (#397)
    errorElement: <RouteError />,
    children: [
      // 로그인 페이지 — 인증 후 접근 시 홈으로 redirect
      {
        element: <RedirectIfAuth />,
        children: [
          { path: "login", element: <Login /> },
          // 소셜 인가 콜백 (카카오·네이버·GitHub, #509)
          { path: "auth/callback/:provider", element: <AuthCallback /> },
        ],
      },
      // 인증 필수 영역
      {
        element: <RequireAuth />,
        children: [
          {
            element: <AppLayout />,
            children: [
              { index: true, element: <Home /> },
              { path: "questions", element: <CategoryCards /> },
              { path: "stats", element: <Stats /> },
              { path: "mypage", element: <MyPage /> },
              { path: "notifications", element: <Notifications /> },
            ],
          },
          // AppLayout 밖: 전체화면 몰입형 화면 (문제 풀이는 집중 모드)
          {
            path: "questions/:questionUuid",
            element: <QuestionDetail />,
          },
          // 구 라우트 — /daily-set으로 redirect (북마크/외부 링크 호환)
          {
            path: "daily-challenge",
            element: <Navigate to="/daily-set" replace />,
          },
          {
            path: "daily-set",
            element: <DailySet />,
          },
          {
            path: "daily-set/result",
            element: <DailySetResult />,
          },
          {
            path: "leaderboard",
            element: <Leaderboard />,
          },
          {
            path: "questions/:questionUuid/result",
            element: <AnswerFeedback />,
          },
          {
            path: "practice/:sessionId",
            element: <PracticeSet />,
          },
          {
            path: "practice/:sessionId/result",
            element: <PracticeResult />,
          },
          // 홈 추천 문제 — DailyChallenge 패턴의 단건 풀이 모드
          {
            path: "recommendation/:questionUuid",
            element: <RecommendationPractice />,
          },
          // 설정 서브페이지 — 마이페이지 톱니바퀴 진입 (탭바 없는 몰입형)
          {
            path: "settings",
            element: <Settings />,
          },
          // 건의사항 서브페이지 — AppLayout 밖 독립 라우트 (탭바 없는 몰입형)
          {
            path: "settings/feedback",
            element: <SettingsFeedback />,
          },
        ],
      },
      // 없는 경로 — 로그인 여부와 무관하게 404 안내
      { path: "*", element: <RouteError notFound /> },
    ],
  },
]);

export default function App() {
  // 점검 중이면 라우터 전체를 점검 화면으로 대체 (#464)
  return (
    <MaintenanceGate>
      <UnreadTitleSync />
      <RouterProvider router={router} />
    </MaintenanceGate>
  );
}
