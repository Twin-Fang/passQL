// 홈 렌더 스모크 (#458 페이지 분리): 섹션 조합, 섹션별 실패 상태
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { screen } from "@testing-library/react";
import Home from "./Home";
import { renderPageForSmokeTest, stubApiResponses } from "../test/renderPageForSmokeTest";
import { useAuthStore } from "../stores/authStore";
import type { QuestionSummary } from "../types/api";
import { LATEST_TREND_BADGE_LABEL } from "../components/LatestTrendBadge";

const RECOMMENDED_QUESTION: QuestionSummary = {
  questionUuid: "r1",
  topicCode: "JOIN",
  topicName: "JOIN",
  difficulty: 2,
  executionMode: "EXECUTABLE",
  stemPreview: "주문 수 구하기",
  createdAt: "",
  isLatestTrend: true,
};

function renderHome() {
  return renderPageForSmokeTest(<Home />, { routePath: "/", initialPath: "/" });
}

describe("Home", () => {
  // 홈 조회는 로그인 토큰이 있을 때만 요청
  beforeEach(() => useAuthStore.setState({ accessToken: "test-access-token", memberUuid: "m1", nickname: "테스터" }));
  afterEach(() => vi.unstubAllGlobals());

  it("인사말·시험 일정·데일리 세트·학습 현황·통계·추천 문제를 그린다", async () => {
    stubApiResponses({
      "/home/greeting": { nickname: "테스터", message: "{nickname}님 반가워요\n둘째 줄", messageType: "GENERAL" },
      "/progress": { solvedCount: 12, correctRate: 0.5, streakDays: 3, readiness: null },
      "/progress/heatmap": { entries: [] },
      "/exam-schedules/selected": { examScheduleUuid: "e1", certType: "SQLD", round: 60, examDate: "2099-12-20", isSelected: true },
      "/daily-set/today": { questions: [RECOMMENDED_QUESTION], alreadyCompleted: false, correctCount: null },
      "/questions/recommendations": { questions: [RECOMMENDED_QUESTION] },
      "/meta/app-links": { androidUrl: "https://play.example/passql", iosUrl: "https://apps.example/passql" },
    });
    renderHome();
    expect(await screen.findByText("둘째 줄")).toBeInTheDocument();
    expect(await screen.findByText("SQLD 60회")).toBeInTheDocument();
    expect(await screen.findByText("1문제 도전하기")).toBeInTheDocument();
    expect(await screen.findByText("연속 3일")).toBeInTheDocument();
    expect(await screen.findByText("푼 문제")).toBeInTheDocument();
    expect(await screen.findByText("주문 수 구하기")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "추천 문제 새로고침" })).toBeInTheDocument();
    // 앱 배너: App Store 배지 링크, Play 비공개(IS_GOOGLE_PLAY_PUBLIC=false) > 준비 중 표시·Play 링크 없음 (#531)
    expect(await screen.findByRole("link", { name: "App Store에서 다운로드하기" })).toHaveAttribute("href", "https://apps.example/passql");
    expect(screen.getByRole("img", { name: "Android 출시 준비 중" })).toBeInTheDocument();
    expect(screen.queryByRole("link", { name: "Google Play에서 다운로드" })).not.toBeInTheDocument();
    // 최신 경향 추천 문제 배지·출제 경향 진입 카드 (#523)
    expect(screen.getByText(LATEST_TREND_BADGE_LABEL, { selector: "a[href='/questions/r1'] span" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /2026 SQLD 출제 경향/ })).toHaveAttribute("href", "/exam-trend");
  });

  it("API 가 실패하면 섹션마다 실패 안내와 재시도를 보여 주고 추천 문제는 숨긴다", async () => {
    stubApiResponses({});
    renderHome();
    expect(await screen.findByText("히트맵을 불러올 수 없습니다")).toBeInTheDocument();
    expect(await screen.findByText("학습 데이터를 불러올 수 없습니다")).toBeInTheDocument();
    expect(await screen.findAllByText("불러오지 못했어요")).toHaveLength(2);
    expect(screen.getAllByRole("button", { name: "재시도" })).toHaveLength(4);
    expect(screen.queryByText("AI 추천문제")).not.toBeInTheDocument();
  });
});
